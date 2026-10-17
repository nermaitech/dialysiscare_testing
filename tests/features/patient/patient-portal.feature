Feature: Patient portal
  A patient can review personal dialysis information without entering staff areas.

  Scenario: View patient dashboard and reports
    Given I sign in as "patient"
    Then I see the patient dashboard and its session and report summaries
    When I open patient reports
    Then the reports page is displayed

  Scenario Outline: Patient cannot visit a staff-only route
    Given I sign in as "patient"
    When I visit the staff-only route "<route>"
    Then access is denied with the role-based message

    Examples:
      | route                |
      | /patients            |
      | /sessions            |
      | /machines-management |
      | /technicians         |

  Scenario: View and download a report for the signed-in patient
    Given I sign in as "patient"
    When I open and download a report for the test patient's UHID
    Then the report details identify the signed-in patient's UHID and a PDF is downloaded

  Scenario: Patient reports contain only the signed-in patient's records
    Given I sign in as "patient"
    When I view all patient report records
    Then every report belongs to the signed-in patient's UHID
