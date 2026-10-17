Feature: Technician session management
  A technician creates and manages dialysis treatment sessions.

  Scenario: Valid patient and available equipment advance session setup
    Given I sign in as "technician"
    When I navigate to the Sessions workspace
    And I click to create a new session
    And I search and select patient "PT-TEST01"
    And I select the assigned technician
    And I select an available machine
    And I continue to patient details
    And I confirm the patient details
    And I select an active dialyzer
    Then session setup advances to start data

  Scenario: Session creation rejects unknown patient UHID
    Given I sign in as "technician"
    When I navigate to the Sessions workspace
    And I click to create a new session
    And I search for patient with unknown UHID "INVALID-9999"
    Then the patient search returns no results
    And the session form cannot proceed

  @skip @unsupported
  Scenario: Session creation rejects unavailable machine
    Given I sign in as "technician"
    When I navigate to the Sessions workspace
    And I click to create a new session
    And I search and select patient "PT-TEST01"
    And I attempt to select a machine with status "In-Use"
    Then the machine cannot be selected for session assignment
    And an unavailable status message is displayed

  @skip @unsupported
  Scenario: Session creation rejects inactive dialyzer
    Given I sign in as "technician"
    When I navigate to the Sessions workspace
    And I click to create a new session
    And I search and select patient "PT-TEST01"
    And I select an available machine
    And I attempt to select dialyzer with status "Inactive"
    Then the inactive dialyzer cannot be assigned
    And a validation message indicates dialyzer status requirement

  @skip @unsupported
  Scenario: Start dialysis treatment and record initial data
    Given I sign in as "technician"
    When I open an existing test session
    And I click the "Start Treatment" button
    Then the session status changes to "In Progress"
    And the treatment start timestamp is recorded
    And the treatment timer begins

  @skip @unsupported
  Scenario: Record hourly reading with required treatment parameters
    Given I sign in as "technician"
    When I open an "In Progress" treatment session
    And I click to add an hourly reading
    And I enter valid treatment parameters:
      | Parameter        | Value      |
      | Blood Flow       | 250        |
      | UF Rate          | 500        |
      | Systolic BP      | 150        |
      | Diastolic BP     | 90         |
      | Heart Rate       | 75         |
      | Temperature      | 36.5       |
    And I confirm the reading timestamp is within treatment window
    Then the hourly reading is saved successfully
    And the reading appears in the treatment log

  @skip @unsupported
  Scenario: End treatment and transition to completed state
    Given I sign in as "technician"
    When I open an "In Progress" treatment session with at least one hourly reading
    And I click the "End Treatment" button
    And I confirm the end treatment action
    Then the session status changes to "Completed"
    And the treatment end timestamp is recorded
    And the total treatment duration is calculated

  @skip @unsupported
  Scenario: Session end validation rejects missing hourly readings
    Given I sign in as "technician"
    When I open a treatment session with zero hourly readings
    And I attempt to end the treatment
    Then the system displays an error message
    And the error indicates that at least one hourly reading is required
    And the session remains in "In Progress" state

  @skip @unsupported
  Scenario: Treatment end timestamp must be after start timestamp
    Given I sign in as "technician"
    When I open a treatment session started at "10:00 AM"
    And I attempt to end treatment at "09:30 AM"
    Then the system rejects the end time
    And an error message indicates the end time must be after start time
    And the session remains in "In Progress" state

  @skip @unsupported
  Scenario: Hourly reading timestamp must be within treatment window
    Given I sign in as "technician"
    When I open a treatment session started at "10:00 AM"
    And I attempt to add an hourly reading with timestamp "11:30 AM"
    And the treatment has not yet ended at "11:00 AM"
    Then the hourly reading is accepted
    When I attempt to add an hourly reading with future timestamp "12:30 PM" (future beyond treatment end)
    Then the system rejects the reading timestamp
    And an error indicates the timestamp is beyond the treatment window

  @skip @unsupported
  Scenario: Search sessions by patient UHID
    Given I sign in as "technician"
    When I navigate to the Sessions workspace
    And I search for sessions with patient UHID "PT-TEST01"
    Then the sessions list displays all sessions for that patient
    And each session shows the correct patient information

  Scenario: Filter sessions by status
    Given I sign in as "technician"
    When I navigate to the Sessions workspace
    And I apply filter for status "Completed"
    Then the sessions list shows only completed sessions
    When I apply filter for status "In Progress"
    Then the sessions list shows only in-progress sessions
    When I clear all filters
    Then all sessions are displayed

  Scenario: Completed sessions have no active treatment actions
    Given I sign in as "technician"
    When I open a treatment session with status "Completed"
    Then a completed session has no active treatment actions
