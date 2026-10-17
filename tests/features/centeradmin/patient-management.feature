Feature: Center admin patient management
  Center administrators manage patient records within their assigned center.

  Scenario: Create, view, edit, and delete a dedicated patient record
    Given I sign in as "centeradmin"
    When I create the dedicated patient record "BDD Lifecycle Patient"
    Then I can view the new patient record
    When I edit the dedicated patient record to "BDD Lifecycle Patient Updated"
    Then I can view the updated patient record
    When I delete the dedicated patient record "BDD Lifecycle Patient Updated"
    Then the dedicated patient record is no longer listed
