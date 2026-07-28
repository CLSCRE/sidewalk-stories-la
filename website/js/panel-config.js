/**
 * Sidewalk Stories LA - Panel Reporter config
 * Edit these values to wire live backends. App works offline with localStorage even if all are blank.
 */
window.SSLA_PANEL_CONFIG = {
  // Optional: Formspree endpoint for email copies of reports (multipart photo).
  // Example: "https://formspree.io/f/xxxxxxxx"
  formspreeEndpoint: "",

  // Optional: Google Apps Script / Make.com / n8n webhook that accepts JSON POST.
  webhookUrl: "",

  // Backup Google Form (always available)
  googleFormUrl: "https://docs.google.com/forms/d/1JMVj2oDDDO1RTxgYqG8_KZ1rADkjvbi8vvEiVhZUK6c/viewform",

  // Admin unlock PIN for /app/admin.html (change this)
  adminPin: "sidewalk2026",

  // Brand / program
  orgName: "Sidewalk Stories LA",
  notifyEmail: "trevor@sidewalkstoriesla.org",

  // Max photo dimension before store (keeps localStorage sane)
  maxPhotoEdge: 1280,
  jpegQuality: 0.72
};
