Feature: Comprehensive data validation
  User input is validated to ensure data quality and system integrity.

  Scenario: Email validation accepts valid formats
    Given I am at the login page
    When I enter valid email format "test@example.com"
    Then the email field passes validation
    When I enter valid email format "user+tag@domain.co.uk"
    Then the email field passes validation

  Scenario: Email validation rejects invalid formats
    Given I am at the login page
    When I enter invalid email "missing@domain"
    Then the email field fails validation with appropriate error
    When I enter invalid email "@nodomain.com"
    Then the email field fails validation
    When I enter invalid email "spaces in@email.com"
    Then the email field fails validation

  Scenario: Patient name validation rejects invalid characters
    Given I sign in as "technician"
    When I navigate to create a new patient
    And I enter patient name with invalid characters "Patient<script>"
    Then the name field shows validation error
    When I enter patient name "Patient/Name"
    Then the name field shows validation error
    When I enter patient name with emoji "Patient 😀"
    Then the name field shows validation error

  Scenario: Patient name validation accepts valid characters
    Given I sign in as "technician"
    When I navigate to create a new patient
    And I enter patient name "John Smith"
    Then the name validation passes
    When I enter patient name "María García"
    Then the name validation passes
    When I enter patient name "O'Brien"
    Then the name validation passes
    When I enter patient name "Jean-Pierre"
    Then the name validation passes

  Scenario: Date of birth validation enforces reasonable limits
    Given I sign in as "technician"
    When I navigate to create a new patient
    And I enter date of birth "2030-01-01" (future date)
    Then the date field shows validation error indicating future date not allowed
    When I enter date of birth "1800-01-01" (very old)
    Then the date field shows validation error or warning for extreme age
    When I enter date of birth "1990-05-15"
    Then the date field passes validation
    And age is calculated correctly as expected value

  Scenario: Phone number validation accepts and rejects formats
    Given I sign in as "technician"
    When I navigate to create a new patient
    And I enter phone number "1234567890" (10 digits)
    Then the phone field passes validation
    When I enter phone number "+1-234-567-8900" (formatted international)
    Then the phone field passes validation
    When I enter phone number "abc" (letters only)
    Then the phone field shows validation error
    When I enter phone number "123" (too short)
    Then the phone field shows validation error

  @skip @unsupported
  Scenario: Treatment parameter validation enforces numeric ranges
    Given I sign in as "technician"
    When I record an hourly reading with:
      | Parameter  | Value | Expected |
      | Blood Flow | 400   | Accept   |
      | Blood Flow | 0     | Reject   |
      | Blood Flow | 9999  | Reject   |
    Then blood flow values outside range are rejected

  @skip @unsupported
  Scenario: Vital signs validation enforces reasonable ranges
    Given I sign in as "technician"
    When I record vital signs for hourly reading:
      | Vital Sign   | Value | Expected |
      | Systolic BP  | 150   | Accept   |
      | Systolic BP  | 60    | Reject   |
      | Systolic BP  | 300   | Reject   |
      | Heart Rate   | 75    | Accept   |
      | Heart Rate   | 200   | Reject   |
      | Temperature  | 36.5  | Accept   |
      | Temperature  | 43    | Reject   |
    Then vital signs outside reasonable ranges are rejected

  Scenario: Required field validation prevents form submission
    Given I sign in as "technician"
    When I navigate to create a new patient form
    And I leave all fields empty
    And I attempt to submit the form
    Then the form is not submitted
    And validation errors appear for all required fields

  Scenario: Pincode format validation for different countries
    Given I sign in as "technician"
    When I create a patient with country "India"
    And I enter pincode "600001" (6 digits)
    Then the pincode passes validation
    When I enter pincode "60000" (5 digits)
    Then the pincode shows validation error
    When I select country "USA"
    And I enter zip code "12345" (5 digits)
    Then the zip code passes validation

  Scenario: Dropdown selection requires valid choice
    Given I sign in as "technician"
    When I navigate to create a new patient
    And I leave the blood type dropdown unselected
    And I attempt to submit the form
    Then the form is not submitted
    And validation error indicates blood type is required

  Scenario: Date range validation in filters
    Given I sign in as "technician"
    When I navigate to Reports with date filter
    And I set date range with end date before start date
    Then the system shows validation error
    When I set valid date range with start before end
    Then the date range is accepted

  Scenario: Search field accepts and sanitizes input
    Given I sign in as "technician"
    When I search for patient with query "O'Brien"
    Then the search returns correct results
    When I search with special characters "test#123"
    Then the search is sanitized and returns safe results
    When I search with extremely long query (1000+ characters)
    Then the search is truncated or rejected with message

  Scenario: Numeric field validation prevents non-numeric input
    Given I sign in as "technician"
    When I enter machine number in field "abc123"
    Then the field shows validation error for non-numeric
    When I enter machine number "12345"
    Then the entry is accepted

  Scenario: Password validation enforces security requirements
    Given I am at the login page
    When I enter password "weak"
    Then validation error indicates password requirements
    When I enter password "StrongPass123!"
    Then password passes validation requirements

  Scenario: URL parameter validation prevents injection attacks
    Given I sign in as "technician"
    When I attempt to access a patient via URL with parameter "patient_id=<script>"
    Then the parameter is sanitized and either rejected or safe
    When I access patient via valid URL parameter "patient_id=123"
    Then the patient is displayed correctly

  Scenario: File upload validation for export/import operations
    Given I sign in as "technician"
    When I attempt to upload a file with unsupported format ".exe"
    Then the upload is rejected with error message
    When I upload supported format ".csv"
    Then the file is accepted for processing
    When I upload extremely large file (>100MB)
    Then the upload is rejected with size limit message
