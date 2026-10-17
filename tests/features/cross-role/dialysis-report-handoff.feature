Feature: Dialysis report handoff
  A report created for one test session can be traced from technician to patient.

  @staging @serial
  Scenario: Complete dialysis and hand the report to the patient
    Given I sign in as "technician"
    When I complete a test dialysis session and record its report
    Then the completed report is visible to the center administrator and patient
    And the patient can download the report
