Feature: Superadmin platform navigation
  A superadmin reviews available platform operations.

  Scenario: Navigate operational workspaces and technician administration
    Given I sign in as "superadmin"
    Then I see the "Dashboard Overview" dashboard
    When I navigate to every operational workspace
    Then each workspace displays its expected page heading
    And I can open the technician administration entry
