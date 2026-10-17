Feature: Technician report management
  Technicians review, export, and manage test treatment reports.

  Scenario: Search reports by known and unknown identifiers
    Given I sign in as "technician"
    When I search reports for a known and an unknown report
    Then the known report is shown and the unknown report has no result

  Scenario: View patient and treatment details for a report
    Given I sign in as "technician"
    When I open a report for the test patient
    Then I see the patient's information and dialysis details

  Scenario: Open report filters
    Given I sign in as "technician"
    When I open report filters
    Then the report filter controls are displayed

  Scenario: Open the report-generation form
    Given I sign in as "technician"
    When I open the new report form
    Then the report-generation form is displayed

  Scenario: Download a report as PDF
    Given I sign in as "technician"
    When I download a test patient's report as PDF
    Then a PDF file is downloaded

  Scenario: Export reports
    Given I sign in as "technician"
    When I export reports
    Then a supported report file is downloaded

  Scenario: Edit and delete a test report
    Given I sign in as "technician"
    When I edit a report for the test patient and cancel the edit
    Then the report remains available for viewing
    When I delete that test report
    Then the deleted test report is no longer listed
