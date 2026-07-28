/**
 * Sidewalk Stories LA - Panel report store
 * localStorage primary + optional remote POST. Shared by report-panel.html and /app/*
 */
(function (global) {
  const STORAGE_KEY = "ssla_panel_reports_v1";
  const cfg = () => global.SSLA_PANEL_CONFIG || {};

  function uid() {
    return "pnl_" + Date.now().toString(36) + "_" + Math.random().toString(36).slice(2, 8);
  }

  function loadAll() {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      const list = raw ? JSON.parse(raw) : [];
      return Array.isArray(list) ? list : [];
    } catch (e) {
      console.warn("panel-store load failed", e);
      return [];
    }
  }

  function saveAll(list) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
    try {
      global.dispatchEvent(new CustomEvent("ssla-panels-updated", { detail: { count: list.length } }));
    } catch (_) {}
  }

  function list(filterStatus) {
    const all = loadAll().sort((a, b) => (b.createdAt || "").localeCompare(a.createdAt || ""));
    if (!filterStatus || filterStatus === "all") return all;
    return all.filter((r) => r.status === filterStatus);
  }

  function get(id) {
    return loadAll().find((r) => r.id === id) || null;
  }

  function upsert(report) {
    const all = loadAll();
    const i = all.findIndex((r) => r.id === report.id);
    if (i >= 0) all[i] = report;
    else all.unshift(report);
    saveAll(all);
    return report;
  }

  function updateStatus(id, status, note) {
    const r = get(id);
    if (!r) return null;
    r.status = status;
    r.updatedAt = new Date().toISOString();
    if (note != null) r.adminNote = note;
    return upsert(r);
  }

  function remove(id) {
    saveAll(loadAll().filter((r) => r.id !== id));
  }

  function clearAll() {
    saveAll([]);
  }

  function exportJson() {
    return JSON.stringify(loadAll(), null, 2);
  }

  function exportCsv() {
    const rows = list();
    const headers = [
      "id","createdAt","status","name","email","phone","address","neighborhood",
      "lat","lng","damage","notes","source"
    ];
    const esc = (v) => {
      const s = v == null ? "" : String(v);
      if (/[",\n]/.test(s)) return '"' + s.replace(/"/g, '""') + '"';
      return s;
    };
    const lines = [headers.join(",")];
    rows.forEach((r) => {
      lines.push(headers.map((h) => esc(r[h])).join(","));
    });
    return lines.join("\n");
  }

  /** Compress image file to data URL JPEG */
  function compressImage(file) {
    const c = cfg();
    const maxEdge = c.maxPhotoEdge || 1280;
    const quality = c.jpegQuality || 0.72;
    return new Promise((resolve, reject) => {
      if (!file || !file.type || !file.type.startsWith("image/")) {
        resolve(null);
        return;
      }
      const reader = new FileReader();
      reader.onerror = () => reject(new Error("Could not read image"));
      reader.onload = () => {
        const img = new Image();
        img.onerror = () => reject(new Error("Invalid image"));
        img.onload = () => {
          let { width, height } = img;
          const scale = Math.min(1, maxEdge / Math.max(width, height));
          width = Math.round(width * scale);
          height = Math.round(height * scale);
          const canvas = document.createElement("canvas");
          canvas.width = width;
          canvas.height = height;
          const ctx = canvas.getContext("2d");
          ctx.drawImage(img, 0, 0, width, height);
          resolve(canvas.toDataURL("image/jpeg", quality));
        };
        img.src = reader.result;
      };
      reader.readAsDataURL(file);
    });
  }

  async function reverseGeocode(lat, lng) {
    // Nominatim - polite use, no key. Fail soft.
    try {
      const url =
        "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=" +
        encodeURIComponent(lat) +
        "&lon=" +
        encodeURIComponent(lng);
      const res = await fetch(url, {
        headers: { Accept: "application/json" }
      });
      if (!res.ok) return null;
      const data = await res.json();
      return data.display_name || null;
    } catch (e) {
      console.warn("reverse geocode failed", e);
      return null;
    }
  }

  async function postRemote(report) {
    const c = cfg();
    const results = { formspree: null, webhook: null };

    const payload = {
      formType: "panel-report",
      id: report.id,
      name: report.name,
      email: report.email,
      phone: report.phone || "",
      address: report.address || "",
      neighborhood: report.neighborhood || "",
      lat: report.lat,
      lng: report.lng,
      damage: report.damage || "",
      notes: report.notes || "",
      status: report.status,
      createdAt: report.createdAt,
      source: report.source || "web",
      // omit giant photo from webhook by default unless small
      hasPhoto: !!report.photoDataUrl
    };

    if (c.webhookUrl) {
      try {
        const res = await fetch(c.webhookUrl, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(payload)
        });
        results.webhook = { ok: res.ok, status: res.status };
      } catch (e) {
        results.webhook = { ok: false, error: String(e) };
      }
    }

    if (c.formspreeEndpoint) {
      try {
        const fd = new FormData();
        fd.append("_subject", "New cracked panel report - Sidewalk Stories LA");
        fd.append("form-type", "panel-report");
        Object.keys(payload).forEach((k) => {
          if (payload[k] != null) fd.append(k, String(payload[k]));
        });
        // Formspree cannot take huge dataURLs reliably; skip photo or attach note
        if (report.photoDataUrl && report.photoDataUrl.length < 900000) {
          fd.append("photo_note", "Photo attached as data URL length " + report.photoDataUrl.length);
        } else if (report.photoDataUrl) {
          fd.append("photo_note", "Photo saved in admin app local store (too large for email).");
        }
        const res = await fetch(c.formspreeEndpoint, {
          method: "POST",
          body: fd,
          headers: { Accept: "application/json" }
        });
        results.formspree = { ok: res.ok, status: res.status };
      } catch (e) {
        results.formspree = { ok: false, error: String(e) };
      }
    }

    return results;
  }

  /**
   * Create a report from a plain object (after compressImage done by caller)
   */
  async function submit(fields) {
    const now = new Date().toISOString();
    const report = {
      id: uid(),
      createdAt: now,
      updatedAt: now,
      status: "new",
      name: (fields.name || "").trim(),
      email: (fields.email || "").trim(),
      phone: (fields.phone || "").trim(),
      address: (fields.address || "").trim(),
      neighborhood: (fields.neighborhood || "").trim(),
      lat: fields.lat != null && fields.lat !== "" ? Number(fields.lat) : null,
      lng: fields.lng != null && fields.lng !== "" ? Number(fields.lng) : null,
      damage: (fields.damage || "").trim(),
      notes: (fields.notes || "").trim(),
      photoDataUrl: fields.photoDataUrl || null,
      source: fields.source || "web",
      adminNote: "",
      remote: null
    };

    if (!report.name || !report.email) {
      throw new Error("Name and email are required.");
    }
    if (report.lat == null && !report.address) {
      throw new Error("Add a street address or use your location.");
    }

    upsert(report);
    try {
      report.remote = await postRemote(report);
      upsert(report);
    } catch (e) {
      console.warn("remote post issue", e);
    }
    return report;
  }

  global.SSLAPanelStore = {
    list,
    get,
    upsert,
    updateStatus,
    remove,
    clearAll,
    exportJson,
    exportCsv,
    compressImage,
    reverseGeocode,
    submit,
    STORAGE_KEY
  };
})(window);
