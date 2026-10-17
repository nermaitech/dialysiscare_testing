@skip @unsupported
Feature: Superadmin platform operations and governance
  A superadmin can view and manage platform-wide operations across all networks and centers.

  Scenario: Superadmin views all networks in the platform
    Given I sign in as "superadmin"
    When I navigate to the platform administration dashboard
    Then I see all networks configured in the system
    And I can see the number of centers in each network
    And I can see the total patient count per network

  Scenario: Superadmin views all centers across all networks
    Given I sign in as "superadmin"
    When I navigate to Centers management
    Then I see all dialysis centers across all networks
    And I can identify which network each center belongs to
    When I apply filter for network
    Then I see only centers in that network

  Scenario: Superadmin views consolidated patient data across all networks
    Given I sign in as "superadmin"
    When I navigate to the Patients workspace
    Then I see patients from all centers across all networks
    And I can identify which center and network each patient belongs to
    When I apply filter for network
    Then I see only patients from that network
    When I apply filter for center
    Then I see only patients from that center

  Scenario: Superadmin views platform-wide treatment sessions
    Given I sign in as "superadmin"
    When I navigate to the Sessions workspace
    Then I see all treatment sessions across the entire platform
    And I can filter by network, center, or technician
    When I apply filter for date range
    Then I see sessions within the selected date range across all networks

  Scenario: Superadmin views consolidated platform analytics
    Given I sign in as "superadmin"
    When I view the platform dashboard
    Then I see key platform metrics:
      | Metric                    | Value        |
      | Total Networks            | (number)     |
      | Total Centers             | (number)     |
      | Total Patients            | (number)     |
      | Total Technicians         | (number)     |
      | Sessions This Year        | (number)     |
      | Platform Utilization      | (percent)    |
    And I can see breakdowns by network and center

  Scenario: Superadmin manages system configuration and settings
    Given I sign in as "superadmin"
    When I navigate to System Settings
    Then I can access configuration for:
      | Setting Category         |
      | User roles and permissions |
      | System parameters        |
      | Integration settings     |
      | Audit and compliance     |
      | Email and notifications  |

  Scenario: Superadmin can manage user roles and permissions
    Given I sign in as "superadmin"
    When I navigate to User Management
    Then I see all users across the platform
    And I can see their role assignments
    When I view a user's details
    Then I can modify their role or permissions
    And the changes apply across the entire platform

  Scenario: Superadmin can access platform audit trail
    Given I sign in as "superadmin"
    When I navigate to Audit & Compliance
    Then I can view audit logs for:
      | Log Type              |
      | User login/logout     |
      | Data access           |
      | Data modifications    |
      | Permission changes    |
      | System configuration  |
    When I apply filter for date range
    Then I see audit entries within the selected date range
    When I search for specific user or action
    Then relevant audit entries are displayed

  Scenario: Superadmin can generate platform compliance reports
    Given I sign in as "superadmin"
    When I navigate to Compliance Reporting
    And I click to generate a new compliance report
    Then I can select:
      | Option              |
      | Report type         |
      | Date range          |
      | Networks/Centers    |
      | Export format       |
    When I generate the report
    Then the report includes platform-wide compliance data

  Scenario: Superadmin views equipment inventory across entire platform
    Given I sign in as "superadmin"
    When I navigate to Machines workspace
    Then I see machines from all centers across all networks
    And I can see utilization across the platform
    When I apply filter for machine status
    Then I see machines matching that status across the platform

  Scenario: Superadmin can deactivate or restrict user access platform-wide
    Given I sign in as "superadmin"
    When I navigate to User Management
    And I select a user
    Then I can deactivate the user account
    And the user is immediately logged out and cannot re-login
    And all their sessions are terminated

  Scenario: Superadmin cannot accidentally lock themselves out
    Given I sign in as "superadmin"
    When I navigate to my own user account
    Then I cannot delete or fully deactivate my own account
    And the delete/deactivate buttons are disabled for my account

  Scenario: Superadmin views API usage and integration health
    Given I sign in as "superadmin"
    When I navigate to Integrations
    Then I can see active integrations with the platform
    And I can view API usage statistics
    And I can see integration health status

  Scenario: Superadmin can manage network administrators
    Given I sign in as "superadmin"
    When I navigate to User Management
    And I filter for "Network Admin" role
    Then I see all network admins across platforms
    When I select a network admin
    Then I can modify their assigned network or permissions
