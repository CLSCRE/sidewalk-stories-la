import win32com.client
import datetime

outlook = win32com.client.Dispatch("Outlook.Application")
calendar = outlook.GetNamespace("MAPI").GetDefaultFolder(9)  # 9 = olFolderCalendar

appointments = [
    {
        "subject": "Follow up on city outreach emails (sidewalks@lacity.org, dca.review, midcitywest)",
        "start": datetime.datetime(2026, 8, 3, 9, 0),
        "duration": 30,
        "body": "If no response received from the three city department emails sent on July 20, send follow up emails. Recipients: sidewalks@lacity.org, dca.review@lacity.org, outreach@midcitywest.org.",
        "categories": "Sidewalk Stories LA",
    },
    {
        "subject": "Submit Awesome Foundation LA application",
        "start": datetime.datetime(2026, 7, 25, 10, 0),
        "duration": 60,
        "body": "Apply online at awesomefoundation.org/en/chapters/la. One paragraph project description. No 501(c)(3) required. Target: $1,000 for first panel materials.",
        "categories": "Sidewalk Stories LA",
    },
    {
        "subject": "Attend Mid-City West Neighborhood Council meeting",
        "start": datetime.datetime(2026, 8, 10, 19, 0),
        "duration": 120,
        "body": "Attend board meeting to introduce Sidewalk Stories LA and pick up Community Improvement Grant application. Check outreach@midcitywest.org for exact date and location.",
        "categories": "Sidewalk Stories LA",
    },
    {
        "subject": "Deadline: Confirm 501(c)(3) or identify fiscal sponsor",
        "start": datetime.datetime(2026, 8, 15, 9, 0),
        "duration": 30,
        "body": "Decision point: file standalone 501(c)(3) or secure fiscal sponsor. Required before submitting CCF, LA County Arts, and DCA grants. See Fiscal-Sponsor-Scenario.md.",
        "categories": "Sidewalk Stories LA",
    },
    {
        "subject": "Deadline: Submit CCF Responsive Grant LOI",
        "start": datetime.datetime(2026, 8, 30, 10, 0),
        "duration": 120,
        "body": "Draft and submit California Community Foundation responsive grant letter of inquiry. Need 501(c)(3) or fiscal sponsor agreement. Attach One-Page-Funder-Prospectus and project budget.",
        "categories": "Sidewalk Stories LA",
    },
    {
        "subject": "Check LA County Arts Commission + DCA grant cycles",
        "start": datetime.datetime(2026, 8, 30, 14, 0),
        "duration": 60,
        "body": "Check lacountyarts.org and culturela.org for 2026-2027 grant calendars. Draft applications if cycles are open. Need 501(c)(3) or fiscal sponsor.",
        "categories": "Sidewalk Stories LA",
    },
    {
        "subject": "Deadline: Submit Weingart Foundation LOI",
        "start": datetime.datetime(2026, 9, 30, 10, 0),
        "duration": 120,
        "body": "Draft and submit Weingart Foundation letter of inquiry. Youth and community improvement focus. Southern California. Submit via weingartfdn.org online portal.",
        "categories": "Sidewalk Stories LA",
    },
    {
        "subject": "Walk Fairfax/Melrose corridor: sponsorship pitch + photo damaged panels",
        "start": datetime.datetime(2026, 8, 5, 10, 0),
        "duration": 120,
        "body": "Walk the pilot neighborhood with Sponsorship-Pitch.pdf. Target 5 local businesses (restaurants, coffee shops, real estate agents). Also photograph specific damaged sidewalk panels near 7951 Blackburn Ave for the app pilot.",
        "categories": "Sidewalk Stories LA",
    },
    {
        "subject": "AARP Community Challenge 2027 cycle opens (watch for announcement)",
        "start": datetime.datetime(2027, 1, 15, 9, 0),
        "duration": 60,
        "body": "AARP Community Challenge typically opens in January. Sidewalk repair for seniors is a strong fit. Target: $2,500 to $15,000. Fast turnaround. Apply at aarp.org/livable-communities/community-challenge/.",
        "categories": "Sidewalk Stories LA",
    },
]

for appt_data in appointments:
    appt = outlook.CreateItem(1)  # 1 = olAppointmentItem
    appt.Subject = appt_data["subject"]
    appt.Start = appt_data["start"].strftime("%m/%d/%Y %H:%M")
    appt.Duration = appt_data["duration"]
    appt.Body = appt_data["body"]
    appt.Categories = appt_data.get("categories", "")
    appt.ReminderSet = True
    appt.ReminderMinutesBeforeStart = 1440  # 24 hours before
    appt.Save()
    print(f"Created: {appt_data['subject']} on {appt_data['start'].strftime('%Y-%m-%d')}")

print(f"\nCreated {len(appointments)} calendar entries in Outlook.")
