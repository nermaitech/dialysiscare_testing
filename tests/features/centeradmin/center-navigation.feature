Feature: Center admin navigation
  A center admin reviews operations for the test center.

  Scenario: Navigate operational workspaces and technician administration
    Given I sign in as "centeradmin"
    Then I see the "Dashboard Overview" dashboard
    When I navigate to every operational workspace
    Then each workspace displays its expected page heading
    And I can open the technician administration entry

  Scenario: Confirm the center administrator identity and center
    Given I sign in as "centeradmin"
    Then I see the center administrator identity and test center
