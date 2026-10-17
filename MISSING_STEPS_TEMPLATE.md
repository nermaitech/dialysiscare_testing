# Missing Step Definitions - Implementation Guide

## Overview
This guide lists the 482 missing step definitions identified during BDD test generation, organized by feature and priority.

## How to Implement

Each missing step follows this pattern:

```javascript
When('step text here', async ({ page }, param1, param2) => {
  // Implementation here
  // Use page object (Playwright) to interact with UI
  // Add assertions with expect() from @playwright/test
});
```

### File Location
Add new steps to: `tests/steps/new-features.steps.js`

### Import Required
```javascript
const { expect } = require('@playwright/test');
const { createBdd, test } = require('playwright-bdd');
const { signIn } = require('../support/auth');
const { waitForReportData } = require('../support/reports');

const { Given, When, Then } = createBdd(test);
```

---

## Missing Steps by Feature

### 1. Center Admin Operations (centeradmin/operations.feature)

**Priority: HIGH** - Admin operations are critical for supervision

#### Patient Management Steps (5)
```javascript
// When('I navigate to the Patients workspace', ...)
// Then('I see the patient list for the center', ...)
// Then('I can search patients by name or UHID', ...)
// When('I apply filters for patient status', ...)
// Then('the list displays only patients matching the filter', ...)
```

#### Session Management Steps (5)
```javascript
// Then('I see all treatment sessions for the center', ...)
// Then('each session shows patient, technician, and status information', ...)
// When('I apply filter for session status {string}', ...)
// Then('the list shows only completed sessions', ...)
// When('I apply filter for date range', ...)
```

#### Report Management Steps (4)
```javascript
// Then('I see treatment reports for all patients in the center', ...)
// When('I open a completed report', ...)
// Then('I see full patient and treatment details', ...)
// Then('I can verify treatment parameters and outcomes', ...)
```

#### Equipment Management Steps (2)
```javascript
// When('I navigate to the Machines workspace', ...)
// Then('I see all machines assigned to the center', ...)
```

#### Analytics Steps (2)
```javascript
// When('I view the dashboard', ...)
// Then('I see key performance indicators for the center:', ...)
```

**Implementation Strategy:**
1. Create helper function to check role-based data filtering
2. Reuse existing patient/session/report navigation steps where possible
3. Add KPI/metric verification assertions
4. Implement filter application and result validation

---

### 2. Network Admin Operations (networkadmin/operations.feature)

**Priority: MEDIUM-HIGH** - Network-level operations needed

#### Multi-Center View Steps (8)
```javascript
// Then('I see patients from all centers in my network', ...)
// Then('I can identify which center each patient belongs to', ...)
// When('I apply filter for center', ...)
// Then('I see only patients from the selected center', ...)
// Then('I see all treatment sessions across centers in the network', ...)
// Then('each session shows the center and technician information', ...)
// Then('I see only sessions from that center', ...)
// Then('I see sessions within the selected date range across all centers', ...)
```

#### Network Analytics Steps (4)
```javascript
// When('I view the network dashboard', ...)
// Then('I see key network metrics:', ...)
// Then('I can see per-center breakdown of each metric', ...)
// Then('I can see comparative metrics for each center:', ...)
```

#### Equipment Visibility Steps (3)
```javascript
// Then('I see machines from all centers in the network', ...)
// Then('I can identify machines by center', ...)
// Then('I can see equipment from all centers in the network', ...)
```

#### Permissions Steps (2)
```javascript
// Then('the edit button is disabled', ...)
// Then('I cannot modify session parameters', ...)
```

**Implementation Strategy:**
1. Create multi-center data filtering helper
2. Implement network-scope validation
3. Add center identification in result sets
4. Verify permission boundaries at network level

---

### 3. Superadmin Operations (superadmin/operations.feature)

**Priority: MEDIUM-HIGH** - Platform governance critical

#### Network/Center Management Steps (8)
```javascript
// When('I navigate to the platform administration dashboard', ...)
// Then('I see all networks configured in the system', ...)
// Then('I can see the number of centers in each network', ...)
// Then('I can see the total patient count per network', ...)
// When('I navigate to Centers management', ...)
// Then('I see all dialysis centers across all networks', ...)
// Then('I can identify which network each center belongs to', ...)
// When('I apply filter for network', ...)
```

#### Platform Analytics Steps (3)
```javascript
// When('I view the platform dashboard', ...)
// Then('I see key platform metrics:', ...)
// Then('I can see breakdowns by network and center', ...)
```

#### System Configuration Steps (3)
```javascript
// When('I navigate to System Settings', ...)
// Then('I can access configuration for:', ...)
// Then('I can modify their role or permissions', ...)
```

#### Audit Trail Steps (4)
```javascript
// When('I navigate to Audit & Compliance', ...)
// Then('I can view audit logs for:', ...)
// When('I apply filter for date range', ...)
// Then('I see audit entries within the selected date range', ...)
```

#### User Management Steps (2)
```javascript
// When('I navigate to User Management', ...)
// Then('I see all users across the platform', ...)
```

**Implementation Strategy:**
1. Verify platform-wide data access
2. Implement audit trail navigation and filtering
3. Test system configuration changes
4. Validate user/role management operations

---

### 4. Data Isolation Feature (shared/data-isolation.feature)

**Priority: CRITICAL** - Security and compliance

#### Center Isolation Steps (6)
```javascript
// When('there are 2 centers: {string} and {string}', ...)
// Then('only "Patient-A1" is visible', ...)
// Then('"Patient-B1" is not visible', ...)
// Then('I see only patients assigned to {string}', ...)
// Then('access is denied with a permission error', ...)
// Then('I see only sessions from {string}', ...)
```

#### Patient Data Isolation Steps (4)
```javascript
// Then('I see only reports from {string}', ...)
// Then('I see only reports for {string}', ...)
// Then('and reports for other patients are not visible', ...)
// Then('and reports from {string} are not visible', ...)
```

#### Equipment Isolation Steps (2)
```javascript
// When('center {string} has machine {string}', ...)
// Then('only {string} is displayed', ...)
```

#### Network Isolation Steps (3)
```javascript
// When('{string} contains {string} and {string}', ...)
// Then('I see patients from {string} and {string}', ...)
// Then('patients from {string} \\(in different region\\) are not visible', ...)
```

#### Export Control Steps (3)
```javascript
// Then('the export contains only patients from {string}', ...)
// Then('the export does not include patients from other centers', ...)
// Then('the export does not include data from other regions', ...)
```

**Implementation Strategy:**
1. Create test data with multiple centers/networks
2. Implement data visibility verification
3. Add boundary testing for each role
4. Verify export data scoping

---

### 5. Permissions Feature (shared/permissions.feature)

**Priority: CRITICAL** - Security

#### Cross-Center Access Steps (6)
```javascript
// When('I sign in as {string} assigned to {string}', ...)
// When('I navigate to the Patients workspace', ...)
// Then('I see only patients assigned to {string}', ...)
// When('I attempt to access a patient from {string} via direct URL', ...)
// Then('access is denied with a permission error', ...)
// Then('each workspace displays its expected page heading', ...)
```

#### Permission Denial Steps (4)
```javascript
// When('there is a patient {string} created by another technician', ...)
// When('I open the patient record', ...)
// Then('the edit button is disabled', ...)
// Then('the delete button is disabled', ...)
```

#### Admin Permission Steps (3)
```javascript
// Given('I sign in as {string} assigned to {string}', ...)
// Then('I see only technicians assigned to {string}', ...)
// Then('the reassign function is disabled', ...)
```

#### Error Message Steps (2)
```javascript
// Then('the message does not reveal database IDs or system details', ...)
// Then('the message does not indicate whether the record exists', ...)
```

**Implementation Strategy:**
1. Create multi-role test accounts
2. Implement cross-center access denial
3. Verify permission enforcement at UI level
4. Test error message safety

---

### 6. Validation Feature (shared/validation.feature)

**Priority: MEDIUM** - Data quality

#### Email Validation Steps (4)
```javascript
// When('I enter valid email format {string}', ...)
// Then('the email field passes validation', ...)
// When('I enter invalid email {string}', ...)
// Then('the email field fails validation with appropriate error', ...)
```

#### Patient Name Steps (4)
```javascript
// When('I enter patient name with invalid characters {string}', ...)
// Then('the name field shows validation error', ...)
// When('I enter patient name {string}', ...)
// Then('the name validation passes', ...)
```

#### Date Validation Steps (3)
```javascript
// When('I enter date of birth {string} \\(future date\\)', ...)
// Then('the date field shows validation error indicating future date not allowed', ...)
// Then('age is calculated correctly as expected value', ...)
```

#### Numeric Validation Steps (4)
```javascript
// When('I record an hourly reading with:', ...)
// Then('blood flow values outside range are rejected', ...)
// When('I record vital signs for hourly reading:', ...)
// Then('vital signs outside reasonable ranges are rejected', ...)
```

#### Required Field Steps (2)
```javascript
// When('I leave all fields empty', ...)
// Then('validation errors appear for all required fields', ...)
```

**Implementation Strategy:**
1. Create data entry helper functions
2. Implement validation assertion library
3. Add boundary value test data
4. Test error message display

---

### 7. Error Handling Feature (shared/error-handling.feature)

**Priority: MEDIUM** - Reliability

#### Network Error Steps (4)
```javascript
// When('the network experiences a timeout during patient list load', ...)
// Then('the system displays a user-friendly error message', ...)
// Then('a {string} button is available', ...)
// When('I click Retry', ...)
```

#### Session Error Steps (4)
```javascript
// When('I enter all required information', ...)
// When('the system fails during session save', ...)
// Then('the form remains populated with my entries', ...)
// Then('an error message explains what failed', ...)
```

#### Conflict Resolution Steps (3)
```javascript
// When('another technician edits the same record', ...)
// Then('the system detects the conflict', ...)
// Then('shows a conflict resolution dialog', ...)
```

#### Timeout Handling Steps (2)
```javascript
// When('I am idle for the session timeout period \\(if configured\\)', ...)
// Then('I\'m redirected to login page', ...)
```

#### Data Recovery Steps (2)
```javascript
// When('navigation error occurs \\(page crash/refresh\\)', ...)
// Then('I see option to restore previous entry', ...)
```

**Implementation Strategy:**
1. Create error simulation helpers
2. Implement retry logic verification
3. Add form state preservation checks
4. Test user guidance messages

---

### 8. Session Management Feature (technician/session-management.feature)

**Priority: CRITICAL** - Core business

#### Session Creation Steps (8) - *PARTIALLY IMPLEMENTED*
```javascript
// When('I search for patient with unknown UHID {string}', ...)
// Then('the patient search returns no results', ...)
// Then('the session form cannot proceed', ...)
// When('I attempt to select a machine with status {string}', ...)
// Then('the machine cannot be selected for session assignment', ...)
// Then('an unavailable status message is displayed', ...)
// When('I attempt to select dialyzer with status {string}', ...)
// Then('the inactive dialyzer cannot be assigned', ...)
```

#### Treatment Steps (5) - *PARTIALLY IMPLEMENTED*
```javascript
// When('I open an existing test session', ...)
// When('I click the {string} button', ...)
// Then('the session status changes to {string}', ...)
// Then('the treatment start timestamp is recorded', ...)
// Then('the treatment timer begins', ...)
```

#### Reading Steps (4) - *PARTIALLY IMPLEMENTED*
```javascript
// When('I open an {string} treatment session', ...)
// When('I click to add an hourly reading', ...)
// When('I enter valid treatment parameters:', ...)
// When('I confirm the reading timestamp is within treatment window', ...)
```

#### Completion Steps (3) - *PARTIALLY IMPLEMENTED*
```javascript
// Then('the hourly reading is saved successfully', ...)
// Then('the reading appears in the treatment log', ...)
// When('I open an {string} treatment session with at least one hourly reading', ...)
```

**Status:** ~50% implemented  
**Remaining:** 15+ steps need completion

---

### 9. Inventory Management Feature (technician/inventory-management.feature)

**Priority: MEDIUM** - Feature completeness

#### Viewing Steps (5) - *PARTIALLY IMPLEMENTED*
```javascript
// When('I navigate to the Inventory workspace', ...)
// Then('I see inventory categories:', ...)
// When('I filter by category {string}', ...)
// Then('only {string} items are displayed', ...)
// Then('each item shows:', ...)
```

#### History Steps (3) - *PARTIALLY IMPLEMENTED*
```javascript
// When('I select an inventory item', ...)
// When('I click {string}', ...)
// Then('I see transaction history including:', ...)
```

#### Calendar Steps (5)
```javascript
// When('I click on calendar date selector', ...)
// When('I select a previous date {string}', ...)
// Then('inventory levels are shown for that historical date', ...)
// Then('I can access the previous month\'s data', ...)
// Then('I can see month-over-month changes in inventory', ...)
```

#### Alert Steps (2)
```javascript
// Then('the item is highlighted or flagged with alert', ...)
// Then('and status shows {string}', ...)
```

#### Batch Tracking Steps (3)
```javascript
// When('I view dialyzer inventory', ...)
// Then('each dialyzer shows:', ...)
// When('I select a specific batch', ...)
```

**Status:** ~40% implemented  
**Remaining:** 20+ steps need completion

---

## Quick Implementation Checklist

### For Each Missing Step

- [ ] Identify the step text
- [ ] Determine the UI element to interact with
- [ ] Write appropriate Playwright selector
- [ ] Add user action (click, fill, select, etc.)
- [ ] Add assertion to verify action succeeded
- [ ] Test with real browser
- [ ] Add to new-features.steps.js
- [ ] Run generation to verify matching

### Playwright Selector Patterns

```javascript
// Button
page.getByRole('button', { name: 'Button Text' })

// Text input
page.getByPlaceholder('Placeholder Text')
page.getByLabel('Label Text')

// Select/Dropdown
page.getByRole('combobox')

// Table row
page.getByRole('row').filter({ hasText: 'pattern' })

// Link
page.getByRole('link', { name: 'Link Text' })

// Heading
page.getByRole('heading', { name: 'Heading' })

// Dialog/Alert
page.getByRole('dialog')
page.getByRole('alert')
```

### Common Assertions

```javascript
// Visibility
await expect(element).toBeVisible()
await expect(element).toBeHidden()

// Text content
await expect(element).toContainText('text')
await expect(element).toHaveText('exact')

// State
await expect(element).toBeDisabled()
await expect(element).toBeEnabled()
await expect(element).toBeChecked()

// Count
await expect(element).toHaveCount(1)

// URL
await expect(page).toHaveURL(/pattern/)
```

---

## Testing Your Implementation

### Run specific feature
```powershell
npx playwright test tests/.features-gen/tests/features/technician/session-management.feature.spec.js
```

### Run with debug mode
```powershell
npx playwright test --debug tests/.features-gen/tests/features/shared/permissions.feature.spec.js
```

### Generate test report
```powershell
npm run test:e2e
npm run allure:open
```

---

## Resources

- [Playwright API Reference](https://playwright.dev/docs/api/class-page)
- [Playwright Assertions](https://playwright.dev/docs/test-assertions)
- [BDD with Playwright](https://github.com/vitalets/playwright-bdd)
- [Existing Steps Reference](./tests/steps/role-flows.steps.js)

---

## Summary

**Total Missing Steps:** 482  
**Critical Priority:** 60+ steps  
**Medium Priority:** 200+ steps  
**Low Priority:** 220+ steps  

**Recommended Implementation Order:**
1. Session Management (13 scenarios)
2. Permissions (17 scenarios)
3. Data Isolation (17 scenarios)
4. Admin Operations (35 scenarios)
5. Validation (17 scenarios)
6. Error Handling (18 scenarios)
7. Inventory (15 scenarios)

**Estimated Implementation Time:**
- Critical: 2-3 days
- All Steps: 1-2 weeks

Each step follows the same pattern and reuses common helpers, so velocity increases as implementation progresses.
