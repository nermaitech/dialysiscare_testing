@skip @unsupported
Feature: Network admin operations and multi-center oversight
  A network admin can view and monitor operations across multiple centers in their network.

  Scenario: Network admin views consolidated patient data across centers
    Given I sign in as "networkadmin"
    When I navigate to the Patients workspace
    Then I see patients from all centers in my network
    And I can identify which center each patient belongs to
    When I apply filter for center
    Then I see only patients from the selected center

  Scenario: Network admin views network-wide treatment sessions
    Given I sign in as "networkadmin"
    When I navigate to the Sessions workspace
    Then I see all treatment sessions across centers in the network
    And each session shows the center and technician information
    When I apply filter for specific center
    Then I see only sessions from that center
    When I apply filter for date range
    Then I see sessions within the selected date range across all centers

  Scenario: Network admin reviews consolidated treatment reports
    Given I sign in as "networkadmin"
    When I navigate to the Reports workspace
    Then I see all treatment reports across centers in the network
    And I can identify which center each report belongs to
    When I apply filter for center "Center A"
    Then I see only reports from "Center A"
    When I generate a network-wide report
    Then the report includes data from all centers in consolidated view

  Scenario: Network admin views network-wide performance analytics
    Given I sign in as "networkadmin"
    When I view the network dashboard
    Then I see key network metrics:
      | Metric                   | Value       |
      | Total Centers            | (number)    |
      | Total Patients Across    | (number)    |
      | Total Sessions This Year | (number)    |
      | Network Utilization      | (percent)   |
    And I can see per-center breakdown of each metric

  Scenario: Network admin views equipment inventory across centers
    Given I sign in as "networkadmin"
    When I navigate to Machines workspace
    Then I see machines from all centers in the network
    And I can identify machines by center
    When I apply filter for machine status "Maintenance"
    Then I see only machines in maintenance across the network

  Scenario: Network admin can identify equipment sharing opportunities
    Given I sign in as "networkadmin"
    When I view the consolidated equipment inventory
    Then I can see which equipment is available at each center
    And I can identify centers with excess capacity
    And I can identify centers with shortages

  Scenario: Network admin cannot directly modify patient or session data
    Given I sign in as "networkadmin"
    When I open a patient record
    Then the edit button is disabled
    And the delete button is disabled
    When I open a treatment session
    Then I cannot modify session parameters
    And I can only view and monitor

  Scenario: Network admin cannot access other networks' data
    Given I sign in as "networkadmin" assigned to "Network A"
    When I attempt to access data from "Network B"
    Then access is denied with a permission error
    And I am redirected to my authorized network view

  Scenario: Network admin can approve or escalate issues across centers
    Given I sign in as "networkadmin"
    When I navigate to flagged or escalated items
    Then I see issues from all centers in the network
    And I can add comments or approvals
    And the center admin is notified of the action

  Scenario: Network admin can view and compare center performance
    Given I sign in as "networkadmin"
    When I navigate to performance analytics dashboard
    Then I can see comparative metrics for each center:
      | Metric                    | Center A | Center B | Center C |
      | Avg Treatment Duration    | (value)  | (value)  | (value)  |
      | Session Completion Rate   | (value)  | (value)  | (value)  |
      | Equipment Utilization     | (value)  | (value)  | (value)  |

  Scenario: Network admin can generate network-wide compliance reports
    Given I sign in as "networkadmin"
    When I navigate to Reports and select "Generate Network Report"
    Then I can choose:
      | Option          |
      | Date range      |
      | Report type     |
      | Centers to include |
      | Export format   |
    When I generate the report
    Then the report includes consolidated data from all selected centers

  Scenario: Network admin views technician distribution across centers
    Given I sign in as "networkadmin"
    When I navigate to technician management
    Then I see technicians from all centers in the network
    And I can identify which center each technician belongs to
    When I apply filter for center
    Then I see only technicians from that center
