Feature: Center admin operations and oversight
  A center admin can view, monitor, and manage center-specific operations.

  Scenario: Center admin views and filters patient list
    Given I sign in as "centeradmin"
    When I navigate to the Patients workspace
    Then I see the patient list for the center
    And I can search patients by name or UHID
    When I apply filters for patient status
    Then the list displays only patients matching the filter

  Scenario: Center admin views all treatment sessions for the center
    Given I sign in as "centeradmin"
    When I navigate to the Sessions workspace
    Then I see all treatment sessions for the center
    And each session shows patient, technician, and status information
    When I apply filter for session status "Completed"
    Then the list shows only completed sessions
    When I apply filter for date range
    Then the list shows sessions within the selected date range

  Scenario: Center admin reviews and validates treatment reports
    Given I sign in as "centeradmin"
    When I navigate to the Reports workspace
    Then I see treatment reports for all patients in the center
    When I open a completed report
    Then I see full patient and treatment details
    And I can verify treatment parameters and outcomes
    When I apply filters for date range or patient
    Then the filtered reports are displayed correctly

  Scenario: Center admin can view equipment status and utilization
    Given I sign in as "centeradmin"
    When I navigate to the Machines workspace
    Then I see all machines assigned to the center
    And each machine shows current status (Available, In-Use, Maintenance, Offline)
    When I navigate to the Dialyzers workspace
    Then I see all dialyzers for the center
    And each dialyzer shows status and expiry information

  Scenario: Center admin manages technician assignments
    Given I sign in as "centeradmin"
    When I navigate to the technician administration interface
    Then I see all technicians assigned to the center
    When I open a technician's profile
    Then I can view their assignment status and schedule

  Scenario: Center admin views center performance analytics
    Given I sign in as "centeradmin"
    When I view the dashboard
    Then I see key performance indicators for the center:
      | KPI                        | Value      |
      | Total Patients             | (number)   |
      | Sessions This Month        | (number)   |
      | Average Treatment Duration | (duration) |
      | Equipment Utilization      | (percent)  |

  Scenario: Center admin can filter sessions by technician
    Given I sign in as "centeradmin"
    When I navigate to Sessions and apply filter for technician "Technician-A"
    Then I see only sessions conducted by that technician
    And I can verify technician performance and load

  Scenario: Center admin cannot modify treatment data retroactively
    Given I sign in as "centeradmin"
    When I open a completed treatment session
    Then the start time, end time, and readings are read-only
    And I cannot modify the treatment parameters

  Scenario: Center admin can review patient demographics and medical info
    Given I sign in as "centeradmin"
    When I open a patient record
    Then I see patient demographics:
      | Field           | Value        |
      | Name            | (displayed)  |
      | UHID            | (displayed)  |
      | DOB/Age         | (displayed)  |
      | Blood Type      | (displayed)  |
      | Address         | (displayed)  |

  Scenario: Center admin can generate center reports
    Given I sign in as "centeradmin"
    When I navigate to Reports
    And I click to generate a new report
    Then I see options to:
      | Option              |
      | Select date range   |
      | Select patient(s)   |
      | Choose report type  |
      | Export format       |
    When I select the report parameters and generate
    Then the report is created successfully

  Scenario: Center admin views inventory consumption and stock
    Given I sign in as "centeradmin"
    When I navigate to Inventory
    Then I see medicine and equipment stock levels
    And I can view consumption over time
    When I apply calendar date filter
    Then I can see inventory history for specific dates
