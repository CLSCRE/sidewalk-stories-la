import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

wb = openpyxl.load_workbook('Sidewalk_Mosaic_Nonprofit_Financial_Model.xlsx')

# Create Pilot Scenario tab
ws_pilot = wb.create_sheet('Pilot Scenario - Year 1')

# Title
ws_pilot['A1'] = 'Sidewalk Stories LA — Pilot Scenario Year 1 (10 Panels)'
ws_pilot['A1'].font = Font(bold=True, size=14)

# Headers
headers = ['', 'Month 1', 'Month 2', 'Month 3', 'Month 4', 'Month 5', 'Month 6', 'Month 7', 'Month 8', 'Month 9', 'Month 10', 'Month 11', 'Month 12', 'Year 1 Total']
for col, val in enumerate(headers, 1):
    cell = ws_pilot.cell(row=3, column=col, value=val)
    cell.font = Font(bold=True)
    cell.fill = PatternFill(start_color='DDEBF7', end_color='DDEBF7', fill_type='solid')

# Program Volume
ws_pilot['A4'] = 'PROGRAM VOLUME'
ws_pilot['A4'].font = Font(bold=True)
ws_pilot['A5'] = 'Panels completed this month'
# Ramp: 1 panel per month for first 3, then 1-2 alternating to reach 10 total
panels = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0]
for i, p in enumerate(panels, 2):
    ws_pilot.cell(row=5, column=i, value=p)
ws_pilot.cell(row=5, column=14, value='=SUM(B5:M5)')

ws_pilot['A6'] = 'Of which, sponsored panels (50%)'
sponsored = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0, 0]
for i, s in enumerate(sponsored, 2):
    ws_pilot.cell(row=6, column=i, value=s)
ws_pilot.cell(row=6, column=14, value='=SUM(B6:M6)')

# Revenue
ws_pilot['A8'] = 'REVENUE'
ws_pilot['A8'].font = Font(bold=True)

ws_pilot['A9'] = 'Individual donations'
# Ramp from $250/mo to $750/mo
donations = [250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 750]
for i, d in enumerate(donations, 2):
    ws_pilot.cell(row=9, column=i, value=d)
ws_pilot.cell(row=9, column=14, value='=SUM(B9:M9)')

ws_pilot['A10'] = 'Sponsorship revenue ($750/panel)'
sponsors = [375, 375, 375, 375, 375, 375, 375, 375, 375, 375, 0, 0]
for i, s in enumerate(sponsors, 2):
    ws_pilot.cell(row=10, column=i, value=s)
ws_pilot.cell(row=10, column=14, value='=SUM(B10:M10)')

ws_pilot['A11'] = 'Grant revenue'
# Q2 grant $5K, Q4 grant $10K
grants = [0, 0, 0, 5000, 0, 0, 0, 0, 0, 0, 0, 10000]
for i, g in enumerate(grants, 2):
    ws_pilot.cell(row=11, column=i, value=g)
ws_pilot.cell(row=11, column=14, value='=SUM(B11:M11)')

ws_pilot['A12'] = 'Events / merchandise'
events = [0, 0, 0, 0, 0, 250, 250, 250, 250, 250, 250, 250]
for i, e in enumerate(events, 2):
    ws_pilot.cell(row=12, column=i, value=e)
ws_pilot.cell(row=12, column=14, value='=SUM(B12:M12)')

ws_pilot['A13'] = 'Total revenue'
ws_pilot['A13'].font = Font(bold=True)
for col in range(2, 15):
    ws_pilot.cell(row=13, column=col, value=f'=SUM({get_column_letter(col)}9:{get_column_letter(col)}12)')

# Costs
ws_pilot['A15'] = 'COSTS'
ws_pilot['A15'].font = Font(bold=True)

ws_pilot['A16'] = 'Panel variable cost ($2,700/panel)'
for i, p in enumerate(panels, 2):
    ws_pilot.cell(row=16, column=i, value=p * 2700)
ws_pilot.cell(row=16, column=14, value='=SUM(B16:M16)')

ws_pilot['A17'] = 'Fixed operating cost'
# Reduced: $850/mo (bookkeeping $300 + insurance $250 + hosting $200 + marketing $100)
fixed = [850] * 12
for i, f in enumerate(fixed, 2):
    ws_pilot.cell(row=17, column=i, value=f)
ws_pilot.cell(row=17, column=14, value='=SUM(B17:M17)')

ws_pilot['A18'] = 'One-time startup cost (Month 1 only)'
ws_pilot['B18'] = 1500
for col in range(3, 14):
    ws_pilot.cell(row=18, column=col, value=0)
ws_pilot.cell(row=18, column=14, value='=SUM(B18:M18)')

ws_pilot['A19'] = 'Total costs'
ws_pilot['A19'].font = Font(bold=True)
for col in range(2, 15):
    ws_pilot.cell(row=19, column=col, value=f'={get_column_letter(col)}16+{get_column_letter(col)}17+{get_column_letter(col)}18')

# Net
ws_pilot['A21'] = 'NET'
ws_pilot['A21'].font = Font(bold=True)

ws_pilot['A22'] = 'Net monthly cash flow'
for col in range(2, 15):
    ws_pilot.cell(row=22, column=col, value=f'={get_column_letter(col)}13-{get_column_letter(col)}19')

ws_pilot['A23'] = 'Cumulative cash position'
ws_pilot['B23'] = '=B22'
for col in range(3, 15):
    ws_pilot.cell(row=23, column=col, value=f'={get_column_letter(col-1)}23+{get_column_letter(col)}22')

# Notes
ws_pilot['A25'] = 'Notes:'
ws_pilot['A25'].font = Font(bold=True, italic=True)
ws_pilot['A26'] = 'This pilot scenario replaces the original 48-panel Year 1 plan. Program ramps to 10 panels across 10 months.'
ws_pilot['A27'] = 'Fixed costs reduced by eliminating the part-time coordinator and trimming admin/marketing budgets.'
ws_pilot['A28'] = 'Startup costs reduced to $1,500 (self-filed 501(c)(3), DIY branding).'
ws_pilot['A29'] = 'Grant revenue assumes one $5K Q2 community arts grant and one $10K Q4 youth development grant.'

# Format currency cells
for row in range(5, 24):
    for col in range(2, 15):
        cell = ws_pilot.cell(row=row, column=col)
        if cell.value is not None:
            cell.number_format = '$#,##0'

# Adjust column widths
for col in range(1, 15):
    ws_pilot.column_dimensions[get_column_letter(col)].width = 14
ws_pilot.column_dimensions['A'].width = 40

# Create Grant Detail tab
ws_grant = wb.create_sheet('Grant Detail')

ws_grant['A1'] = 'Sidewalk Stories LA — Grant Detail & Pipeline'
ws_grant['A1'].font = Font(bold=True, size=14)

# Headers
grant_headers = ['Funder', 'Tier', 'Focus Area', 'Typical Award', 'Target Ask', 'Deadline', 'Status', 'Probability', 'Notes']
for col, val in enumerate(grant_headers, 1):
    cell = ws_grant.cell(row=3, column=col, value=val)
    cell.font = Font(bold=True)
    cell.fill = PatternFill(start_color='DDEBF7', end_color='DDEBF7', fill_type='solid')

grants_data = [
    ['Awesome Foundation LA', '1', 'Community projects', '$1,000', '$1,000', 'Rolling (monthly)', 'Not yet applied', 'High', 'No 501(c)(3) required. Great for first panel materials.'],
    ['Neighborhood Council Grant', '1', 'Local improvement', '$2,500', '$2,500', 'Varies by council', 'Not yet applied', 'High', 'Need pilot neighborhood selected.'],
    ['Local Business Sponsors (5)', '4', 'Corporate sponsorship', '$750/panel', '$3,750', 'Ongoing', 'Not yet approached', 'High', 'Logo on mosaic, social content, press mention.'],
    ['AARP Community Challenge', '3', 'Livability / seniors', '$10,000', '$10,000', 'Annual cycle (opens early year)', 'Not yet applied', 'Medium', 'Strong fit: sidewalk safety for seniors.'],
    ['LA County Arts Commission', '1', 'Public art / youth arts', '$10,000', '$10,000', 'Check quarterly cycles', 'Not yet applied', 'Medium', 'Directly funds public art in neighborhoods.'],
    ['City of LA DCA', '1', 'Public art / youth', '$10,000', '$10,000', 'Check annual cycle', 'Not yet applied', 'Medium', 'DCA funds public art in the right of way.'],
    ['California Community Foundation', '1', 'Arts / civic engagement', '$15,000', '$15,000', 'Responsive grants (quarterly)', 'Not yet applied', 'Medium', 'CCF funds LA County neighborhood improvement.'],
    ['Weingart Foundation', '1', 'Youth / community', '$25,000', '$25,000', 'Check guidelines', 'Not yet applied', 'Medium', 'Explicitly funds programs improving neighborhoods for youth.'],
    ['National Endowment for the Arts', '2', 'Public art / community', '$10,000', '$15,000', 'Annual cycle', 'Not yet applied', 'Low-Medium', 'Requires 501(c)(3) status or fiscal sponsor.'],
    ['Surdna Foundation', '2', 'Creative placemaking', '$25,000', '$25,000', 'Check guidelines', 'Not yet applied', 'Low-Medium', 'Funds youth shaping built environment.'],
    ['Jewish Federation of Greater LA', '4', 'Jewish community / youth', '$10,000', '$10,000', 'Check annual cycle', 'Not yet applied', 'Medium', 'If Jewish youth participate, strong fit.'],
    ['Safe Sidewalks LA Rebate', '3', 'Cost offset / homeowner', '$10,000', '$10,000', 'Ongoing', 'Researching', 'Medium', 'Homeowner rebate, not direct nonprofit revenue.'],
]

for row_idx, row_data in enumerate(grants_data, 4):
    for col_idx, val in enumerate(row_data, 1):
        ws_grant.cell(row=row_idx, column=col_idx, value=val)

# Format columns
ws_grant.column_dimensions['A'].width = 30
ws_grant.column_dimensions['B'].width = 8
ws_grant.column_dimensions['C'].width = 20
ws_grant.column_dimensions['D'].width = 16
ws_grant.column_dimensions['E'].width = 14
ws_grant.column_dimensions['F'].width = 22
ws_grant.column_dimensions['G'].width = 18
ws_grant.column_dimensions['H'].width = 12
ws_grant.column_dimensions['I'].width = 45

# Summary
ws_grant['A18'] = 'Pipeline Summary'
ws_grant['A18'].font = Font(bold=True, size=12)
ws_grant['A19'] = 'Total Year 1 Grant + Sponsor Target:'
ws_grant['B19'] = '=SUM(E4:E15)'
ws_grant['B19'].number_format = '$#,##0'
ws_grant['A20'] = 'Less Conservative Estimate (60% of target):'
ws_grant['B20'] = '=B19*0.6'
ws_grant['B20'].number_format = '$#,##0'

wb.save('Sidewalk_Mosaic_Nonprofit_Financial_Model.xlsx')
print("Excel model updated successfully with Pilot Scenario and Grant Detail tabs.")
