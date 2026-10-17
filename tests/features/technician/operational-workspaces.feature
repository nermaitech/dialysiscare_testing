Feature: Technician operational workspaces
  Technicians can review dialysis resources and validate session setup.

  Scenario: Search machine inventory with a known and unknown query
    Given I sign in as "technician"
    When I search machine inventory for a known and an unknown machine
    Then the known machine is shown and the unknown machine has no result

  Scenario: A technician cannot change machine status
    Given I sign in as "technician"
    When I try to change a test machine status
    Then the application rejects the change and leaves the machine listed

  Scenario: Filter dialyzers by status
    Given I sign in as "technician"
    When I filter dialyzers by active, retired, and damaged status
    Then the dialyzer list reflects the selected status

  Scenario: Require mandatory fields when adding a dialyzer during session setup
    Given I sign in as "technician"
    When I start a session and open the add-dialyzer form without required fields
    Then the dialyzer form remains open while required fields are missing

  Scenario: Filter sessions by lifecycle status
    Given I sign in as "technician"
    When I select each supported session status filter
    Then the session list reflects the selected status

  Scenario: Require session selections before advancing setup
    Given I sign in as "technician"
    When I continue new session setup without required selections
    Then session setup remains on its first step

  Scenario: Reject an unknown patient UHID during session setup
    Given I sign in as "technician"
    When I enter an unknown patient UHID in new session setup
    Then the session cannot advance with that UHID

  Scenario: Require clinical start data before starting dialysis
    Given I sign in as "technician"
    When I complete session allocation without entering start data
    Then the start button stays disabled until required clinical values are entered

  Scenario: Filter inventory and navigate the monthly calendar
    Given I sign in as "technician"
    When I filter inventory and view the prior month's calendar
    Then the filtered stock and calendar month boundary are displayed
