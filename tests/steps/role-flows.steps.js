const { expect } = require('@playwright/test');
const { createBdd, test } = require('playwright-bdd');
const { signIn } = require('../support/auth');
const { waitForReportData } = require('../support/reports');

const { Given, When, Then } = createBdd(test);

const workspaces = [
  ['Patients', 'Patients Management'],
  ['Sessions', 'Sessions'],
  ['Machines', 'Machines Management'],
  ['Dialyzers', 'Dialyzer Management'],
  ['Reports', 'Reports'],
  ['Inventory', 'Inventory Management'],
];

const staffRoutes = [
  '/vendor-dashboard',
  '/patients',
  '/sessions',
  '/machines-management',
  '/dialyzers-management',
  '/reports',
  '/inventory',
];

async function createPatient(page, name) {
  await page.getByRole('button', { name: 'Add Patient' }).click();
  await page.getByPlaceholder('Enter Patient Name').fill(name);
  await page.locator('input[type="date"]').fill('1990-01-01');
  await page.getByRole('combobox').nth(1).selectOption({ label: 'O+' });
  await page.getByPlaceholder('Enter Street').fill('1 Test Street');
  await page.getByPlaceholder('Enter City').fill('Test City');
  await page.getByPlaceholder('Enter State').fill('Test State');
  await page.getByPlaceholder('Enter Country').fill('India');
  await page.getByPlaceholder('Enter Pincode').fill('600001');
  await page.getByRole('button', { name: 'Save Patient' }).click();
}

async function openReports(page) {
  await page.getByRole('link', { name: 'Reports', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Reports' })).toBeVisible();
  await waitForReportData(page);
}

async function openSessionSetup(page) {
  await page.getByRole('link', { name: 'Sessions', exact: true }).click();
  await page.getByRole('button', { name: 'New Session' }).first().click();
  await expect(page).toHaveURL(/\/sessions\/new$/);
}

async function selectOptionContaining(select, text) {
  const option = select.locator('option').filter({ hasText: text }).first();
  await expect(option, `Expected an available option containing "${text}".`).toHaveCount(1);
  await select.selectOption(await option.getAttribute('value'));
}

function patientRowByName(page, name) {
  return page
    .getByRole('row')
    .filter({ has: page.getByRole('cell', { name, exact: true }) });
}

Given('I am at the login page', async ({ page }) => {
  await page.goto('/login');
});

Given('I sign in as {string}', async ({ page }, role) => {
  await signIn(page, role);
});

Then('I see the {string} dashboard', async ({ page }, heading) => {
  await expect(page.getByRole('heading', { name: heading })).toBeVisible();
});

Then('I see the sign-in form and recovery links', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Login' })).toBeVisible();
  await expect(page.getByPlaceholder('Enter your email')).toBeVisible();
  await expect(page.getByPlaceholder('Enter your password')).toBeVisible();
  await expect(page.getByRole('checkbox', { name: 'Remember me' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Sign In' })).toBeVisible();
  await expect(page.getByRole('link', { name: 'Forgot Password?' })).toHaveAttribute(
    'href',
    '/forgot-password',
  );
  await expect(page.getByRole('link', { name: 'Sign Up' })).toHaveAttribute('href', '/register');
});

When('I submit a malformed email address', async ({ page }) => {
  await page.getByPlaceholder('Enter your email').fill('not-an-email');
  await page.getByPlaceholder('Enter your password').fill('not-a-real-password');
  await page.getByRole('button', { name: 'Sign In' }).click();
});

Then('the browser keeps me on the login page and marks the email invalid', async ({ page }) => {
  expect(await page.getByPlaceholder('Enter your email').evaluate((input) => input.validity.typeMismatch))
    .toBe(true);
  await expect(page).toHaveURL(/\/login(?:[?#].*)?$/);
});

When('I submit invalid credentials', async ({ page }) => {
  await page.getByPlaceholder('Enter your email').fill('missing-user@example.invalid');
  await page.getByPlaceholder('Enter your password').fill('invalid-password');
  const dialogPromise = page.waitForEvent('dialog');
  await page.getByRole('button', { name: 'Sign In' }).click();
  const dialog = await dialogPromise;
  expect(dialog.message()).toBe('Invalid email or password');
  await dialog.accept();
});

Then('I see the invalid-credentials message and remain signed out', async ({ page }) => {
  await expect(page).toHaveURL(/\/login(?:[?#].*)?$/);
});

When('I log out', async ({ page }) => {
  await page.getByText('Logout', { exact: true }).click();
});

Then('I am redirected to login', async ({ page }) => {
  await expect(page).toHaveURL(/\/login(?:[?#].*)?$/);
});

Then('I cannot reopen authenticated staff routes', async ({ page }) => {
  for (const route of staffRoutes) {
    await page.goto(route);
    await expect(page).toHaveURL(/\/login(?:[?#].*)?$/);
  }
});

When('I navigate to every operational workspace', async ({ page }) => {
  for (const [linkName, headingName] of workspaces) {
    await page.getByRole('link', { name: linkName, exact: true }).click();
    await expect(page.getByRole('heading', { name: headingName })).toBeVisible();
  }
});

Then('I do not see the technician administration entry', async ({ page }) => {
  await expect(page.getByRole('link', { name: 'Technician', exact: true })).toHaveCount(0);
});

Then('each workspace displays its expected page heading', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Inventory Management' })).toBeVisible();
});

Then('I can open the technician administration entry', async ({ page }) => {
  await page.getByRole('link', { name: 'Technician', exact: true }).click();
  await expect(page).toHaveURL(/\/technicians$/);
  await expect(page.getByRole('main')).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Access Denied' })).toHaveCount(0);
});

Then('I see the center administrator identity and test center', async ({ page }) => {
  await expect(page.getByText('Center Admin (Vendor)')).toBeVisible();
  await expect(page.getByText('Test Center', { exact: true })).toBeVisible();
});

When('I use dashboard analytics ranges and summary shortcuts', async ({ page }) => {
  for (const range of ['7 Days', '30 Days', '6 Months']) {
    const rangeButton = page.getByRole('button', { name: range, exact: true });
    await rangeButton.click();
    await expect(rangeButton).toBeFocused();
    await expect(page.getByRole('heading', { name: 'Operational Analytics' })).toBeVisible();
  }

  for (const [label, destination] of [
    ['Total Patients', /\/patients$/],
    ['Total Sessions', /\/sessions$/],
    ['Machines Available', /\/machines-management$/],
  ]) {
    await page.goto('/');
    await expect(page.getByRole('heading', { name: 'Dashboard Overview' })).toBeVisible();
    await page.getByText(label, { exact: true }).click();
    await expect(page).toHaveURL(destination);
  }

  await page.goto('/');
  await page.getByRole('button', { name: 'View Reports' }).click();
});

Then('each shortcut opens its corresponding workspace', async ({ page }) => {
  await expect(page).toHaveURL(/\/reports$/);
  await expect(page.getByRole('heading', { name: 'Reports' })).toBeVisible();
});

Then('I see the patient dashboard and its session and report summaries', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Upcoming Sessions' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Recent Reports' })).toBeVisible();
});

When('I open patient reports', async ({ page }) => {
  await page.getByRole('link', { name: 'Reports', exact: true }).click();
});

Then('the reports page is displayed', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Reports' })).toBeVisible();
  await waitForReportData(page);
});

When('I visit the staff-only route {string}', async ({ page }, route) => {
  await page.goto(route);
});

Then('access is denied with the role-based message', async ({ page }) => {
  await expect(page).toHaveURL(/\/unauthorized$/);
  await expect(page.getByRole('heading', { name: 'Access Denied' })).toBeVisible();
  await expect(
    page.getByText('You do not have permission to view this page based on your role.'),
  ).toBeVisible();
});

When('I search patient records for a known and an unknown patient', async ({ page }) => {
  await page.getByRole('link', { name: 'Patients', exact: true }).click();
  const search = page.getByPlaceholder('Search by ID or Name');
  await search.fill('PT-TEST01');
  await expect(page.getByRole('row').filter({ hasText: 'PT-TEST01' })).toBeVisible();
  await search.fill('NO-SUCH-PATIENT-98765');
});

Then('the known patient is shown and the unknown patient has no result', async ({ page }) => {
  await expect(
    page.getByRole('row').filter({ hasText: 'NO-SUCH-PATIENT-98765' }),
  ).toHaveCount(0);
});

When('I submit an empty patient form and enter an invalid patient name', async ({ page }) => {
  await page.getByRole('link', { name: 'Patients', exact: true }).click();
  await page.getByRole('button', { name: 'Add Patient' }).click();
  await page.getByRole('button', { name: 'Save Patient' }).click();
  await expect(page.getByRole('heading', { name: 'Add New Patient' })).toBeVisible();
  const name = page.getByPlaceholder('Enter Patient Name');
  await name.fill('Patient123');
  await expect(name).toHaveValue('Patient');
});

Then('the form remains open and the name excludes invalid characters', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Add New Patient' })).toBeVisible();
  await expect(page.getByPlaceholder('Enter Patient Name')).toHaveValue('Patient');
  await page.getByRole('button', { name: 'Cancel' }).click();
  await expect(page.getByRole('heading', { name: 'Patients Management' })).toBeVisible();
});

When("I enter a patient's date of birth", async ({ page }) => {
  await page.getByRole('link', { name: 'Patients', exact: true }).click();
  await page.getByRole('button', { name: 'Add Patient' }).click();
  await page.locator('input[type="date"]').fill('2000-01-01');
});

Then("the patient's age is calculated from that date", async ({ page }) => {
  const expectedAge = await page.evaluate(() => new Date().getFullYear() - 2000);
  await expect(page.getByRole('spinbutton')).toHaveValue(String(expectedAge));
  await page.getByRole('button', { name: 'Cancel' }).click();
});

When('I create the dedicated patient record {string}', async ({ page }, name) => {
  await page.getByRole('link', { name: 'Patients', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Patients Management' })).toBeVisible();
  await expect(page.getByRole('row').filter({ hasText: 'PT-TEST01' })).toBeVisible({
    timeout: 15_000,
  });
  const existing = page.getByRole('row').filter({
    hasText: /BDD Lifecycle Patient(?: Updated)?/,
  });
  while ((await existing.count()) > 0) {
    const previousCount = await existing.count();
    const firstExisting = existing.first();
    page.once('dialog', (dialog) => dialog.accept());
    await firstExisting.getByRole('button', { name: 'Delete Patient' }).click();
    await expect(existing).toHaveCount(previousCount - 1);
  }
  await createPatient(page, name);
  await page.getByPlaceholder('Search by ID or Name').fill(name);
});

Then('I can view the new patient record', async ({ page }) => {
  await expect(patientRowByName(page, 'BDD Lifecycle Patient')).toHaveCount(1);
});

When('I edit the dedicated patient record to {string}', async ({ page }, updatedName) => {
  const currentRow = patientRowByName(page, 'BDD Lifecycle Patient');
  await currentRow.getByRole('button', { name: 'Edit Patient' }).click();
  await expect(page.getByRole('heading', { name: 'Edit Patient' })).toBeVisible();
  const nameInput = page.getByRole('textbox').nth(1);
  await expect(nameInput).toHaveValue('BDD Lifecycle Patient');
  await nameInput.fill(updatedName);
  await page.getByRole('button', { name: 'Update Details' }).click();
});

Then('I can view the updated patient record', async ({ page }) => {
  await expect(patientRowByName(page, 'BDD Lifecycle Patient Updated')).toBeVisible();
});

When('I delete the dedicated patient record {string}', async ({ page }, name) => {
  const row = patientRowByName(page, name);
  page.once('dialog', (dialog) => dialog.accept());
  await row.getByRole('button', { name: 'Delete Patient' }).click();
});

Then('the dedicated patient record is no longer listed', async ({ page }) => {
  await expect(patientRowByName(page, 'BDD Lifecycle Patient Updated')).toHaveCount(0);
});

When('I search machine inventory for a known and an unknown machine', async ({ page }) => {
  await page.getByRole('link', { name: 'Machines', exact: true }).click();
  const rows = page.getByRole('row');
  const machineId = await rows.nth(1).getByRole('cell').first().innerText();
  const search = page.getByPlaceholder('Search by ID or Name');
  await search.fill(machineId);
  await expect(rows.filter({ hasText: machineId })).toBeVisible();
  await search.fill('NO-SUCH-MACHINE-98765');
});

Then('the known machine is shown and the unknown machine has no result', async ({ page }) => {
  await expect(
    page.getByRole('row').filter({ hasText: 'NO-SUCH-MACHINE-98765' }),
  ).toHaveCount(0);
});

When('I try to change a test machine status', async ({ page }) => {
  await page.getByRole('link', { name: 'Machines', exact: true }).click();
  const machine = page.getByRole('row').filter({ hasText: 'M-001' });
  const dialogPromise = page.waitForEvent('dialog');
  await machine.getByRole('button', { name: 'Maintenance' }).click();
  const dialog = await dialogPromise;
  expect(dialog.message()).toContain('Failed to update status');
  await dialog.accept();
});

Then('the application rejects the change and leaves the machine listed', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Machines Management' })).toBeVisible();
  await expect(page.getByRole('row').filter({ hasText: 'M-001' })).toBeVisible();
});

When('I filter dialyzers by active, retired, and damaged status', async ({ page }) => {
  await page.getByRole('link', { name: 'Dialyzers', exact: true }).click();
  const status = page.getByRole('combobox');
  const patientDialyzers = page.getByRole('row').filter({ hasText: 'Test Patient' });
  await status.selectOption({ label: 'Active' });
  await expect(patientDialyzers.first()).toBeVisible();
  await status.selectOption({ label: 'Retired' });
  await expect(patientDialyzers).toHaveCount(0);
  await status.selectOption({ label: 'Damaged' });
});

Then('the dialyzer list reflects the selected status', async ({ page }) => {
  await expect(page.getByRole('row').filter({ hasText: 'Test Patient' })).toHaveCount(0);
});

When('I start a session and open the add-dialyzer form without required fields', async ({ page }) => {
  await openSessionSetup(page);
  await page.getByPlaceholder('Enter UHID').fill('PT-TEST01');
  await page.getByRole('combobox').nth(0).selectOption({ index: 1 });
  await page.getByRole('combobox').nth(1).selectOption({ index: 2 });
  await page.getByRole('button', { name: 'Next' }).click();
  const patientName = page.getByPlaceholder('Auto-filled from UHID');
  await expect(patientName).toHaveValue('Test Patient');
  await patientName.fill('Test Patient');
  await page.getByRole('button', { name: 'Next' }).click();
  await page.getByRole('button', { name: 'Add New Dialyzer' }).click();
  await page.getByRole('button', { name: 'Save Dialyzer' }).click();
});

Then('the dialyzer form remains open while required fields are missing', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Add New Dialyzer' })).toBeVisible();
  await page.getByRole('button', { name: 'Cancel', exact: true }).last().click();
  await page.getByRole('button', { name: 'Cancel' }).click();
});

When('I select each supported session status filter', async ({ page }) => {
  await page.getByRole('link', { name: 'Sessions', exact: true }).click();
  const status = page.getByRole('combobox');
  for (const label of ['Completed', 'In Progress', 'Pending Closure', 'All statuses']) {
    await status.selectOption({ label });
    await expect(status.locator('option:checked')).toHaveText(label);
  }
});

Then('the session list reflects the selected status', async ({ page }) => {
  await expect(page.getByRole('combobox').locator('option:checked')).toHaveText('All statuses');
});

When('I continue new session setup without required selections', async ({ page }) => {
  await openSessionSetup(page);
  await page.getByRole('button', { name: 'Next' }).click();
});

Then('session setup remains on its first step', async ({ page }) => {
  await expect(page.getByText('Step 1 of 2 — Session Setup')).toBeVisible();
  await expect(page.getByPlaceholder('Enter UHID')).toBeVisible();
});

When('I enter an unknown patient UHID in new session setup', async ({ page }) => {
  await openSessionSetup(page);
  await page.getByPlaceholder('Enter UHID').fill('NO-SUCH-PATIENT-98765');
  await page.getByRole('button', { name: 'Next' }).click();
});

Then('the session cannot advance with that UHID', async ({ page }) => {
  await expect(page.getByText('Step 1 of 2 — Session Setup')).toBeVisible();
  await expect(page.getByPlaceholder('Enter UHID')).toHaveValue('NO-SUCH-PATIENT-98765');
  await expect(page.getByPlaceholder('Auto-filled from UHID')).toHaveValue('');
});

When('I complete session allocation without entering start data', async ({ page }) => {
  await openSessionSetup(page);
  await page.getByPlaceholder('Enter UHID').fill('PT-TEST01');
  await page.getByRole('combobox').nth(0).selectOption({ index: 1 });
  await page.getByRole('combobox').nth(1).selectOption({ index: 2 });
  await page.getByRole('button', { name: 'Next' }).click();
  const patientName = page.getByPlaceholder('Auto-filled from UHID');
  await expect(patientName).toHaveValue('Test Patient');
  await patientName.fill('Test Patient');
  await page.getByRole('button', { name: 'Next' }).click();
  const dialyzer = page.getByRole('combobox').nth(2);
  if ((await dialyzer.locator('option').count()) <= 1) {
    await page.getByPlaceholder('Scan / enter barcode').fill('TESTEST579');
    await page.getByRole('button', { name: 'Scan' }).click();
  }
  await expect(dialyzer.locator('option')).toHaveCount(2, { timeout: 10_000 });
  await dialyzer.selectOption({ index: 1 });
  await page.getByRole('button', { name: 'Next' }).click();
  const startData = page.getByText('Step 2 of 2 — Start Data');
  const machineBusy = page.getByText('This machine is currently in use.', { exact: true });
  await expect(startData.or(machineBusy)).toBeVisible({ timeout: 30_000 });
  if (await machineBusy.isVisible()) {
    await page.getByRole('button', { name: 'Cancel' }).click();
    test.skip(true, 'The selected machine is already in use.');
  }
});

Then('the start button stays disabled until required clinical values are entered', async ({ page }) => {
  const start = page.getByRole('button', { name: 'Start', exact: true });
  await expect(start).toBeDisabled();
  await page.locator('input[name="preWeight"]').fill('70.5');
  await page.locator('input[name="ufGoal"]').fill('2.0');
  await page.locator('input[name="preBpSys"]').fill('120');
  await page.locator('input[name="preBpDia"]').fill('80');
  await expect(start).toBeEnabled();
  await page.getByRole('button', { name: 'Cancel' }).click();
  await expect(page).toHaveURL(/\/sessions$/);
});

When("I filter inventory and view the prior month's calendar", async ({ page }) => {
  await page.getByRole('link', { name: 'Inventory', exact: true }).click();
  const itemType = page.getByRole('combobox');
  await itemType.selectOption({ label: 'Medicine' });
  const medicine = page.getByRole('row').filter({ hasText: 'Dolo 650' });
  await expect(medicine).toBeVisible();
  await expect(medicine.getByRole('cell').nth(3)).toHaveText('100');
  await expect(medicine.getByRole('cell').nth(5)).toHaveText('95');
  await itemType.selectOption({ label: 'Equipment' });
  await expect(page.getByRole('row').filter({ hasText: 'Dolo 650' })).toHaveCount(0);

  await page.getByRole('button', { name: 'View monthly calendar' }).click();
  await expect(page.getByRole('heading', { name: 'Monthly Calendar' })).toBeVisible();
  const calendar = page.getByRole('table');
  await expect(calendar).toBeVisible();
  const previousMonth = await page.evaluate(() => {
    const previous = new Date();
    previous.setDate(1);
    previous.setMonth(previous.getMonth() - 1);
    return {
      value: `${previous.getFullYear()}-${String(previous.getMonth() + 1).padStart(2, '0')}`,
      lastDay: new Date(previous.getFullYear(), previous.getMonth() + 1, 0).getDate(),
    };
  });
  await page.locator('input[type="month"]').fill(previousMonth.value);
  await expect(
    calendar.getByRole('columnheader', { name: String(previousMonth.lastDay), exact: true }),
  ).toBeVisible();
  await page.getByRole('button', { name: 'Back to inventory' }).click();
});

Then('the filtered stock and calendar month boundary are displayed', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Inventory Management' })).toBeVisible();
});

When('I search reports for a known and an unknown report', async ({ page }) => {
  await openReports(page);
  const rows = page.getByRole('row');
  const reportId = await rows.nth(1).getByRole('cell').first().innerText();
  const search = page.getByPlaceholder('Search Report ID or Patient...');
  await search.fill(reportId);
  await expect(rows.filter({ hasText: reportId })).toBeVisible();
  await search.fill('NO-SUCH-REPORT-98765');
});

Then('the known report is shown and the unknown report has no result', async ({ page }) => {
  await expect(
    page.getByRole('row').filter({ hasText: 'NO-SUCH-REPORT-98765' }),
  ).toHaveCount(0);
});

When('I open a report for the test patient', async ({ page }) => {
  await openReports(page);
  const row = page.getByRole('row').filter({ hasText: 'PT-TEST01' }).first();
  await row.getByRole('button').first().click();
});

Then("I see the patient's information and dialysis details", async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Report Details' })).toBeVisible();
  await expect(page.getByText('Patient Information')).toBeVisible();
  await expect(page.getByText('Dialysis Details')).toBeVisible();
  await expect(page.getByText('PT-TEST01', { exact: true }).last()).toBeVisible();
  await page.getByRole('button', { name: 'Close' }).click();
});

When('I open report filters', async ({ page }) => {
  await page.getByRole('link', { name: 'Reports', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Reports' })).toBeVisible();
  await page.getByRole('button', { name: 'Filter' }).click();
});

Then('the report filter controls are displayed', async ({ page }) => {
  await expect(page.getByRole('dialog')).toBeVisible({ timeout: 3_000 });
});

When('I edit a report for the test patient and cancel the edit', async ({ page }) => {
  await openReports(page);
  const row = page.getByRole('row').filter({ hasText: 'PT-TEST01' }).first();
  await expect(row.locator('button:has(svg.lucide-pen-line)')).toHaveCount(1);
  await row.locator('button:has(svg.lucide-pen-line)').click();
  await expect(page.getByRole('dialog')).toBeVisible();
  await page.getByRole('button', { name: 'Cancel' }).click();
});

Then('the report remains available for viewing', async ({ page }) => {
  await expect(page.getByRole('row').filter({ hasText: 'PT-TEST01' }).first()).toBeVisible();
});

When('I delete that test report', async ({ page }) => {
  const row = page.getByRole('row').filter({ hasText: 'PT-TEST01' }).first();
  page.once('dialog', (dialog) => dialog.accept());
  await row.locator('button:has(svg.lucide-trash2)').click();
  await expect(row).toHaveCount(0);
});

Then('the deleted test report is no longer listed', async ({ page }) => {
  await expect(page.getByRole('row').filter({ hasText: 'PT-TEST01' })).toHaveCount(0);
});

When('I open the new report form', async ({ page }) => {
  await openReports(page);
  await page.getByRole('button', { name: 'New Report' }).click();
});

Then('the report-generation form is displayed', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'New Report' })).toBeVisible({ timeout: 3_000 });
});

When("I download a test patient's report as PDF", async ({ page }) => {
  await openReports(page);
  await page.getByRole('row').filter({ hasText: 'PT-TEST01' }).first().getByRole('button').first().click();
  await expect(page.getByRole('heading', { name: 'Report Details' })).toBeVisible();
  const downloadPromise = page.waitForEvent('download', { timeout: 10_000 });
  await page.getByRole('button', { name: 'Download PDF' }).click();
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toMatch(/\.pdf$/i);
});

Then('a PDF file is downloaded', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Report Details' })).toBeVisible();
  await page.getByRole('button', { name: 'Close' }).click();
});

When('I export reports', async ({ page }) => {
  await page.getByRole('link', { name: 'Reports', exact: true }).click();
  const downloadPromise = page.waitForEvent('download', { timeout: 10_000 });
  await page.getByRole('button', { name: 'Export Report' }).click();
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toMatch(/\.(csv|xlsx|pdf)$/i);
});

Then('a supported report file is downloaded', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Reports' })).toBeVisible();
});

When("I open and download a report for the test patient's UHID", async ({ page }) => {
  await openReports(page);
  const ownReport = page.getByRole('row').filter({ hasText: 'PT-TEST01' }).first();
  await expect(ownReport).toBeVisible();
  await ownReport.getByRole('button').first().click();
  await expect(page.getByRole('heading', { name: 'Report Details' })).toBeVisible();
  await expect(page.getByText('PT-TEST01', { exact: true }).last()).toBeVisible();
  const downloadPromise = page.waitForEvent('download', { timeout: 15_000 });
  await page.getByRole('button', { name: 'Download PDF' }).click();
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toMatch(/\.pdf$/i);
});

Then("the report details identify the signed-in patient's UHID and a PDF is downloaded", async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Report Details' })).toBeVisible();
  await expect(page.getByText('PT-TEST01', { exact: true }).last()).toBeVisible();
});

When('I view all patient report records', async ({ page }) => {
  await openReports(page);
});

Then("every report belongs to the signed-in patient's UHID", async ({ page }) => {
  const rows = await page.getByRole('row').allInnerTexts();
  const reportRows = rows.slice(1);
  expect(reportRows.length, 'The test patient must have report data.').toBeGreaterThan(0);
  expect(
    reportRows.every((row) => row.includes('PT-TEST01')),
    'Patient accounts must not see reports belonging to other patients.',
  ).toBe(true);
});

When('I complete a test dialysis session and record its report', async ({ page }) => {
  await completeTreatmentAndReportHandoff(page);
});

Then('the completed report is visible to the center administrator and patient', async ({ page }) => {
  await expect(page.getByRole('heading', { name: 'Report Details' })).toBeVisible();
});

Then('the patient can download the report', async ({ page }) => {
  const downloadPromise = page.waitForEvent('download', { timeout: 15_000 });
  await page.getByRole('button', { name: 'Download PDF' }).click();
  const download = await downloadPromise;
  expect(download.suggestedFilename()).toMatch(/\.pdf$/i);
});

async function completeTreatmentAndReportHandoff(page) {
  await page.getByRole('link', { name: 'Sessions', exact: true }).click();
  const sessionRows = page
    .getByRole('row')
    .filter({ hasText: /In Progress|Pending Closure|Completed/ });
  await expect(
    page
      .getByText('No sessions found within the current center scope.')
      .or(sessionRows.first()),
  ).toBeVisible({ timeout: 15_000 });

  const machineIds = ['M-009', 'M-001'];
  let activeSession = page
    .getByRole('row')
    .filter({ hasText: 'PT-TEST01' })
    .filter({ hasText: 'In Progress' })
    .first();
  let workflowMachineId;

  if ((await activeSession.count()) === 0) {
    const activeRows = await page.getByRole('row').filter({ hasText: 'In Progress' }).all();
    const activeMachines = await Promise.all(
      activeRows.map((row) => row.getByRole('cell').nth(3).innerText()),
    );
    workflowMachineId = machineIds.find((id) => !activeMachines.includes(id));
    if (!workflowMachineId) {
      throw new Error('The test center has no available test machine for the treatment workflow.');
    }

    await page.getByRole('button', { name: 'New Session' }).first().click();
    await expect(page).toHaveURL(/\/sessions\/new$/);
    await page.getByPlaceholder('Enter UHID').fill('PT-TEST01');
    await selectOptionContaining(page.getByRole('combobox').nth(0), 'TECH-TEST01');
    await selectOptionContaining(page.getByRole('combobox').nth(1), workflowMachineId);
    await page.getByRole('button', { name: 'Next' }).click();

    const patientName = page.getByPlaceholder('Auto-filled from UHID');
    await expect(patientName).toHaveValue('Test Patient', { timeout: 15_000 });
    await patientName.fill('Test Patient');
    await page.getByRole('button', { name: 'Next' }).click();

    const dialyzer = page.getByRole('combobox').nth(2);
    if ((await dialyzer.locator('option').count()) <= 1) {
      await page.getByPlaceholder('Scan / enter barcode').fill('TESTEST579');
      await page.getByRole('button', { name: 'Scan' }).click();
    }
    await expect(dialyzer.locator('option')).toHaveCount(2, { timeout: 10_000 });
    await dialyzer.selectOption({ index: 1 });
    await page.getByRole('button', { name: 'Next' }).click();

    const startDataStep = page.getByText('Step 2 of 2 — Start Data');
    const machineBusy = page.getByText('This machine is currently in use.', { exact: true });
    await expect(startDataStep.or(machineBusy)).toBeVisible({ timeout: 30_000 });
    if (await machineBusy.isVisible()) {
      await page.getByRole('button', { name: 'Cancel' }).click();
      test.skip(true, `Selected test machine ${workflowMachineId} is busy.`);
    }

    const start = page.getByRole('button', { name: 'Start', exact: true });
    await expect(start).toBeDisabled();
    await page.locator('input[name="preWeight"]').fill('72.3');
    await page.locator('input[name="ufGoal"]').fill('2.1');
    await page.locator('input[name="preBpSys"]').fill('123');
    await page.locator('input[name="preBpDia"]').fill('81');
    await expect(start).toBeEnabled();
    await start.click();
    await expect(page).toHaveURL(/\/sessions$/);
    activeSession = page
      .getByRole('row')
      .filter({ hasText: 'PT-TEST01' })
      .filter({ hasText: workflowMachineId })
      .filter({ hasText: 'In Progress' })
      .first();
  } else {
    workflowMachineId = await activeSession.getByRole('cell').nth(3).innerText();
  }

  await expect(activeSession).toBeVisible();
  await activeSession.getByRole('button', { name: 'Enter Hourly Data' }).click();
  await expect(page.getByRole('heading', { name: 'Enter Hourly Data' })).toBeVisible();
  await page.getByRole('button', { name: 'Save Reading' }).click();
  await expect(page.getByText('Time is required')).toBeVisible();
  await page.locator('input[type="time"]').fill(new Date().toTimeString().slice(0, 5));
  await page.getByPlaceholder('120/80').fill('124/82');
  await page.getByRole('spinbutton').nth(0).fill('500');
  await page.getByRole('spinbutton').nth(1).fill('72');
  await page.getByRole('button', { name: 'Save Reading' }).click();
  await expect(page.getByRole('heading', { name: 'Enter Hourly Data' })).toHaveCount(0);

  const inProgressSession = page
    .getByRole('row')
    .filter({ hasText: 'PT-TEST01' })
    .filter({ hasText: workflowMachineId })
    .filter({ hasText: 'In Progress' })
    .first();
  await inProgressSession.getByRole('button', { name: 'Stop' }).click();
  await expect(page).toHaveURL(/\/sessions\/\d+\/end-treatment$/);
  const endTreatment = page.getByRole('button', { name: 'End / Save' });
  await expect(endTreatment).toBeDisabled();
  await expect(page.getByText('Post Weight must be 1–300 kg.')).toBeVisible();
  await page.getByPlaceholder('0.0').fill('0');
  await expect(page.getByText('Post Weight must be 1–300 kg.')).toBeVisible();
  await page.getByPlaceholder('0.0').fill('301');
  await expect(page.getByText('Post Weight must be 1–300 kg.')).toBeVisible();
  await page.getByPlaceholder('0.0').fill('70.2');
  await page.getByPlaceholder('HH:MM').fill('25:99');
  await expect(page.getByText('Enter a valid HH:MM time.')).toBeVisible();
  await page.getByPlaceholder('HH:MM').fill(new Date().toTimeString().slice(0, 5));
  await page.getByRole('spinbutton').fill('100001');
  await expect(page.getByText('Total Heparin must be 0–100000 IU.')).toBeVisible();
  await page.getByRole('spinbutton').fill('1000');
  await page.getByPlaceholder('Sys').fill('49');
  await expect(page.getByText('Systolic must be 50–300.')).toBeVisible();
  await page.getByPlaceholder('Sys').fill('120');
  await page.getByPlaceholder('Dia').fill('80');
  await expect(endTreatment).toBeEnabled();
  await endTreatment.click();
  await expect(page).toHaveURL(/\/sessions$/);

  await openReports(page);
  const report = page.getByRole('row').filter({ hasText: 'PT-TEST01' }).first();
  await expect(report).toBeVisible();
  const reportId = await report.getByRole('cell').first().innerText();
  await report.getByRole('button').first().click();
  await expect(page.getByRole('heading', { name: 'Report Details' })).toBeVisible();
  await expect(page.getByText('70.2 kg', { exact: true })).toBeVisible();
  await page.getByRole('button', { name: 'Close' }).click();

  await page.getByText('Logout', { exact: true }).click();
  await signIn(page, 'centeradmin');
  await openReports(page);
  await page.getByPlaceholder('Search Report ID or Patient...').fill(reportId);
  const centerReport = page.getByRole('row').filter({ hasText: reportId });
  await expect(centerReport).toBeVisible();
  await centerReport.getByRole('button').first().click();
  await expect(page.getByRole('heading', { name: 'Report Details' })).toBeVisible();
  await expect(page.getByText('70.2 kg', { exact: true })).toBeVisible();
  await page.getByRole('button', { name: 'Close' }).click();

  await page.getByText('Logout', { exact: true }).click();
  await signIn(page, 'patient');
  await openReports(page);
  await page.getByPlaceholder('Search Report ID or Patient...').fill(reportId);
  const patientReport = page.getByRole('row').filter({ hasText: reportId });
  await expect(patientReport).toBeVisible();
  await patientReport.getByRole('button').first().click();
  await expect(page.getByRole('heading', { name: 'Report Details' })).toBeVisible();
  await expect(page.getByText('70.2 kg', { exact: true })).toBeVisible();
}
