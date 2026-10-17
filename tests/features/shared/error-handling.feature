@skip @unsupported
Feature: Error handling and recovery
  The system handles errors gracefully and allows users to recover from failures.

  Scenario: Network timeout during patient search displays helpful message
    Given I sign in as "technician"
    When I navigate to Patients workspace
    And the network experiences a timeout during patient list load
    Then the system displays a user-friendly error message
    And a "Retry" button is available
    When I click Retry
    Then the patient list loads successfully

  Scenario: Session creation failure leaves form in recoverable state
    Given I sign in as "technician"
    When I navigate to create a new session
    And I enter all required information
    And the system fails during session save
    Then the form remains populated with my entries
    And an error message explains what failed
    When I click Retry
    Then the session is created with the saved data

  Scenario: Report generation failure notifies user and allows retry
    Given I sign in as "technician"
    When I attempt to generate a treatment report
    And the report generation fails
    Then the system displays an error notification
    And I can click "Retry" to attempt again
    When I retry
    Then the report is generated successfully

  Scenario: Equipment unavailability during session shows clear message
    Given I sign in as "technician"
    When I create a new session
    And I select a machine
    And another technician takes the machine offline before I confirm
    Then the system detects the machine is no longer available
    And displays a message "Machine is no longer available"
    And suggests alternative machines or to retry

  Scenario: Concurrent edit conflict shows conflict resolution UI
    Given I sign in as "technician"
    When I open a patient record for editing
    And another technician edits the same record
    And I attempt to save my changes
    Then the system detects the conflict
    And shows a conflict resolution dialog
    And displays the conflicting changes
    And provides options to:
      | Option        |
      | Keep my changes |
      | Accept their changes |
      | View both versions |

  Scenario: Permission denied displays appropriate message without leaking info
    Given I sign in as "patient"
    When I attempt to access another patient's record
    Then I see a generic "Access Denied" error
    And the message does not reveal whether the record exists
    And no sensitive system information is shown

  Scenario: Database constraint violation shows user-friendly error
    Given I sign in as "technician"
    When I attempt to create a duplicate patient with same UHID
    Then the system rejects the creation
    And displays message "Patient with this UHID already exists"
    And does not show database error details

  Scenario: Form submission timeout allows retry
    Given I sign in as "technician"
    When I submit a form for creating a patient
    And the request times out (>30 seconds)
    Then the system shows timeout error
    And provides "Retry" option
    When I click Retry
    Then the form is resubmitted

  Scenario: Session timeout redirects to login gracefully
    Given I sign in as "technician"
    When I am idle for the session timeout period (if configured)
    And I attempt to perform an action
    Then I'm redirected to login page
    And a message explains "Your session has expired. Please log in again."

  Scenario: Partial data entry is recovered on navigation error
    Given I sign in as "technician"
    When I start creating a treatment session
    And I fill in several fields
    And navigation error occurs (page crash/refresh)
    Then upon recovery, I see option to restore previous entry
    When I click restore
    Then all previously entered data is recovered

  Scenario: Upload failure shows detailed status
    Given I sign in as "technician"
    When I upload a large file for import
    And the upload fails at 75% progress
    Then the system shows upload progress indicator stopped
    And displays specific error (network, size, format, etc.)
    And allows retry from beginning

  Scenario: API call failure with retry logic
    Given I sign in as "technician"
    When I perform an action that calls backend API
    And the API call fails with temporary error
    Then the system automatically retries (with exponential backoff)
    And displays "Retrying..." indicator
    When the retry succeeds
    Then the operation completes successfully

  Scenario: Graceful degradation when optional service unavailable
    Given I sign in as "technician"
    When I navigate to dashboard
    And an optional analytics service is unavailable
    Then the page loads without analytics
    And other components work normally
    And a notification indicates "Analytics temporarily unavailable"

  Scenario: Duplicate form submission is prevented
    Given I sign in as "technician"
    When I submit a form to create a patient
    And I double-click or rapidly click Submit button
    Then only one submission is processed
    And the button is disabled during submission
    And user sees "Processing..." indicator

  Scenario: Long-running operation shows progress indication
    Given I sign in as "centeradmin"
    When I export a large report (1000+ records)
    And the export takes >5 seconds
    Then a progress bar or spinning indicator is shown
    And I can see estimated completion time
    And I have option to cancel the operation

  Scenario: Offline detection and queuing for later sync
    Given I sign in as "technician" on a mobile device
    When network connection is lost
    And I attempt to save a patient record
    Then the system detects offline state
    And shows "Offline - Will sync when connection restored"
    And queues the action locally
    When network connection is restored
    Then the queued action is automatically synced

  Scenario: Error recovery from corrupted data display
    Given I sign in as "centeradmin"
    When a report with corrupted data is accessed
    Then instead of crashing, the system shows partial data with warning:
      | Display |
      | "Some data could not be displayed due to formatting error" |
      | Available data is shown |
      | "Contact support if issue persists" |

  Scenario: Fallback to read-only mode during system maintenance
    Given I sign in as "technician"
    When the system enters maintenance mode
    Then I can still view data in read-only mode
    And create/edit/delete operations show "System is under maintenance"
    And I'm notified of expected maintenance completion time
