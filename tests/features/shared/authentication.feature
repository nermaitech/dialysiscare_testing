Feature: Authentication
  As a user of Dialysis Connect
  I want secure, role-aware sign-in
  So that I can access the correct workspace

  Scenario: View the sign-in controls and account links
    Given I am at the login page
    Then I see the sign-in form and recovery links

  Scenario: Reject a malformed email address
    Given I am at the login page
    When I submit a malformed email address
    Then the browser keeps me on the login page and marks the email invalid

  Scenario: Reject invalid credentials
    Given I am at the login page
    When I submit invalid credentials
    Then I see the invalid-credentials message and remain signed out

  Scenario Outline: Each configured role can sign in
    Given I sign in as "<role>"
    Then I see the "<dashboard>" dashboard

    Examples:
      | role         | dashboard          |
      | superadmin   | Dashboard Overview |
      | networkadmin | Dashboard Overview |
      | centeradmin  | Dashboard Overview |
      | technician   | Dashboard Overview |
      | patient      | Patient Dashboard  |

  Scenario: Logout prevents access to staff workspaces
    Given I sign in as "technician"
    When I log out
    Then I am redirected to login
    And I cannot reopen authenticated staff routes
