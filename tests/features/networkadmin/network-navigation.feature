Feature: Network admin navigation
  A network admin reviews operational workspaces available to their role.

  Scenario: Navigate operational workspaces and technician administration
    Given I sign in as "networkadmin"
    Then I see the "Dashboard Overview" dashboard
    When I navigate to every operational workspace
    Then each workspace displays its expected page heading
    And I can open the technician administration entry
