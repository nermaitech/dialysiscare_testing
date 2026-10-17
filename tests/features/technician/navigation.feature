Feature: Technician navigation
  A technician navigates the daily dialysis care workspaces.

  Scenario: Navigate operational workspaces
    Given I sign in as "technician"
    Then I see the "Dashboard Overview" dashboard
    When I navigate to every operational workspace
    Then each workspace displays its expected page heading
    And I do not see the technician administration entry

  Scenario: Use dashboard analytics and workspace shortcuts
    Given I sign in as "technician"
    When I use dashboard analytics ranges and summary shortcuts
    Then each shortcut opens its corresponding workspace
