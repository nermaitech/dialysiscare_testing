@skip @unsupported
Feature: Data isolation and multi-tenant boundaries
  Data is properly isolated between centers and networks to prevent unauthorized access.

  Scenario: Patient data is isolated by center
    Given there are 2 centers: "Center A" and "Center B"
    And "Patient-A1" is assigned to "Center A"
    And "Patient-B1" is assigned to "Center B"
    When technician from "Center A" searches all patients
    Then only "Patient-A1" is visible
    And "Patient-B1" is not visible
    When technician from "Center B" searches all patients
    Then only "Patient-B1" is visible
    And "Patient-A1" is not visible

  Scenario: Session data respects center boundaries
    Given there are 2 centers: "Center A" and "Center B"
    And there is a session for "Patient-A1" in "Center A"
    And there is a session for "Patient-B1" in "Center B"
    When I sign in as technician from "Center A"
    And I navigate to Sessions workspace
    Then I see only sessions from "Center A"
    And sessions from "Center B" are not visible

  Scenario: Report data is isolated by center and patient
    Given there are reports created in "Center A" and "Center B"
    When I sign in as centeradmin from "Center A"
    And I navigate to Reports workspace
    Then I see only reports from "Center A"
    When I sign in as patient with UHID "PT-A-001"
    And I navigate to Reports
    Then I see only reports for "PT-A-001"
    And reports for other patients are not visible
    And reports from "Center B" are not visible

  Scenario: Equipment inventory is isolated by center
    Given center "Center A" has machine "M-A-001"
    And center "Center B" has machine "M-B-001"
    When technician from "Center A" searches machines
    Then only "M-A-001" is displayed
    And "M-B-001" is not visible
    When technician from "Center B" searches machines
    Then only "M-B-001" is displayed
    And "M-A-001" is not visible

  Scenario: Inventory management is scoped to assigned center
    Given I sign in as technician from "Center A"
    When I navigate to Inventory workspace
    Then I see only inventory for "Center A"
    And inventory from other centers is not visible

  Scenario: Technician assignment respects center boundaries
    Given I sign in as centeradmin from "Center A"
    When I view technician management
    Then I see only technicians assigned to "Center A"
    And technicians from "Center B" are not visible

  Scenario: Network admin can see multi-center data within network
    Given "Region 1" contains "Center A" and "Center B"
    And "Region 2" contains "Center C"
    When I sign in as networkadmin for "Region 1"
    And I navigate to consolidated patient view
    Then I see patients from "Center A" and "Center B"
    And patients from "Center C" (in different region) are not visible

  Scenario: Network admin cannot cross region boundaries
    Given I sign in as networkadmin for "Region 1"
    When I attempt to access data from "Region 2" via direct URL
    Then access is denied with a permission error
    And I am redirected to my authorized network view

  Scenario: Superadmin can view all data across all networks
    Given there are multiple networks with multiple centers each
    When I sign in as superadmin
    And I navigate to system-wide patient view
    Then I can view patients from all centers and networks
    When I navigate to system-wide report view
    Then I can view reports from all centers and networks

  Scenario: Patient data isolation regression - patient sees only own records
    Given there are multiple patients in the system
    When I sign in as "patient" with UHID "PT-TEST01"
    And I navigate to my reports
    Then every report displayed belongs to UHID "PT-TEST01"
    And no reports from other patients are visible
    And no other patient UHIDs appear in the report list

  Scenario: Session data cannot be cross-assigned between centers
    Given I sign in as technician from "Center A"
    When I create a session for a patient from "Center A"
    And I attempt to reassign the session to "Center B" via direct action
    Then the action is rejected with authorization error

  Scenario: Editing patient center assignment requires admin privilege
    Given I sign in as technician from "Center A"
    And there is a patient assigned to "Center A"
    When I attempt to modify the patient's center assignment
    Then the modification is denied with permission error
    When I sign in as centeradmin from "Center A"
    And I attempt to move the patient to "Center B"
    Then the operation is denied (center cannot be changed, or requires superadmin)

  Scenario: Archived data maintains isolation boundaries
    Given I sign in as technician from "Center A"
    When I view archived patient records
    Then I see only archived records from "Center A"
    And archived records from "Center B" are not visible

  Scenario: Data export respects user's authorized scope
    Given I sign in as centeradmin from "Center A"
    When I export patient list
    Then the export contains only patients from "Center A"
    And the export does not include patients from other centers
    When I sign in as networkadmin for "Region 1"
    And I export consolidated reports
    Then the export contains reports from all centers in "Region 1"
    And the export does not include data from other regions
