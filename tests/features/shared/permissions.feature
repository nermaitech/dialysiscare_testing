Feature: Role-based permissions and access control
  Users can only access resources and perform actions allowed by their role.

  @skip @unsupported
  Scenario: Technician cannot access another center's patients
    Given I sign in as "technician" assigned to "Test Center"
    When I navigate to the Patients workspace
    Then I see only patients assigned to "Test Center"
    When I attempt to access a patient from "Other Center" via direct URL
    Then access is denied with a permission error

  Scenario: Technician cannot modify patient created by another technician
    Given I sign in as "technician" assigned to "Test Center"
    And there is a patient "Other Tech Patient" created by another technician
    When I open the patient record
    Then the edit button is disabled
    And the delete button is disabled
    And only view access is available

  Scenario: Technician cannot delete report created by another technician
    Given I sign in as "technician" assigned to "Test Center"
    When I open a report created by another technician
    Then the delete button is disabled
    And only view and download options are available

  Scenario: Technician cannot access admin-only workspaces
    Given I sign in as "technician"
    When I attempt to visit the admin settings page via URL
    Then access is denied and I am redirected to dashboard
    When I attempt to visit the user management page
    Then access is denied

  @skip @unsupported
  Scenario: Center admin cannot access data from another center
    Given I sign in as "centeradmin" assigned to "Center A"
    When I navigate to the Patients workspace
    Then I see only patients from "Center A"
    When I attempt to access a patient from "Center B" via direct URL
    Then access is denied with a permission error
    When I attempt to view a session from "Center B"
    Then access is denied with a permission error

  Scenario: Center admin cannot view another center's reports
    Given I sign in as "centeradmin" assigned to "Center A"
    When I navigate to Reports workspace
    Then I see only reports from "Center A"
    When I attempt to access a report from "Center B" via direct URL
    Then access is denied with a permission error

  Scenario: Center admin cannot modify technician assignments across centers
    Given I sign in as "centeradmin" assigned to "Center A"
    When I open the technician management interface
    Then I see only technicians assigned to "Center A"
    When I attempt to reassign a technician from "Center B"
    Then the action is denied with a permission error

  @skip @unsupported
  Scenario: Network admin can view multi-center data but cannot modify individual records
    Given I sign in as "networkadmin" assigned to "Region 1"
    When I navigate to view patients across all centers in "Region 1"
    Then I see patients from all centers in the region
    When I attempt to edit a patient record directly
    Then the edit function is disabled
    And I can only view and monitor

  @skip @unsupported
  Scenario: Network admin cannot view data from another region
    Given I sign in as "networkadmin" assigned to "Region 1"
    When I attempt to access data from "Region 2" via direct URL
    Then access is denied with a permission error

  @skip @unsupported
  Scenario: Superadmin can access all data across all networks
    Given I sign in as "superadmin"
    When I navigate to view patients across all networks
    Then I can view patients from all centers
    When I navigate to view reports across all networks
    Then I can view reports from all centers
    When I navigate to view technicians across all networks
    Then I can view technicians from all centers

  @skip @unsupported
  Scenario: Superadmin can modify system-wide settings
    Given I sign in as "superadmin"
    When I navigate to system settings
    Then I can modify platform-wide configuration

  Scenario: Patient cannot access any staff workspaces
    Given I sign in as "patient"
    When I attempt to visit the /patients workspace
    Then access is denied and redirected to patient dashboard
    When I attempt to visit the /sessions workspace
    Then access is denied
    When I attempt to visit the /machines-management workspace
    Then access is denied
    When I attempt to visit the /technicians workspace
    Then access is denied

  Scenario: Technician cannot escalate own privileges
    Given I sign in as "technician"
    When I attempt to modify my own role to "centeradmin" via API or direct action
    Then the action is rejected with authorization error
    When I attempt to access center admin features
    Then access is denied

  Scenario: Permission denied error message does not leak sensitive information
    Given I sign in as "patient"
    When I attempt to access another patient's report
    Then I see a generic "Access Denied" message
    And the message does not reveal database IDs or system details
    And the message does not indicate whether the record exists

  Scenario: Logout immediately revokes all permissions
    Given I sign in as "technician"
    When I log out
    And I attempt to access the patients workspace via direct URL
    Then access is denied and I am redirected to login

  Scenario: Session timeout revokes permissions
    Given I sign in as "technician"
    When I wait for session timeout (if applicable)
    Then I cannot access authenticated pages
    And I am redirected to login
