Feature: Technician patient management
  A technician manages patient test records used for dialysis care.

  Scenario: Search for known and unknown patients
    Given I sign in as "technician"
    When I search patient records for a known and an unknown patient
    Then the known patient is shown and the unknown patient has no result

  Scenario: Validate required patient fields and patient name input
    Given I sign in as "technician"
    When I submit an empty patient form and enter an invalid patient name
    Then the form remains open and the name excludes invalid characters

  Scenario: Derive patient age from date of birth
    Given I sign in as "technician"
    When I enter a patient's date of birth
    Then the patient's age is calculated from that date
