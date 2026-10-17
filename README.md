# Dialysis Connect Playwright tests

Executable Gherkin feature files are organized by role and workflow under
`tests/features/`. Their step definitions are in `tests/steps/`, with shared
authentication and reporting helpers in `tests/support/`. `playwright-bdd`
generates native Playwright specs into `tests/.features-gen/` before execution.
See [ROLE_SCENARIOS.md](./tests/ROLE_SCENARIOS.md) for coverage and known
product/staging gaps.

The technician-to-patient E2E uses the dedicated `PT-TEST01` fixture and the
available treatment, report, and patient workflows; use only an authorized test
deployment and account. Patient and report lifecycle scenarios create, edit,
and delete test records. The machine status permission check does not change
machine state.

The current staging patient report list exposes records with multiple patient
IDs. The patient report-scope test deliberately remains a normal failing
authorization regression until the app returns only the authenticated patient's
records. The patient PDF download check also did not receive a browser download
event during the latest staging run. Admin tests cover the workspaces observed
in the UI; product-specific cross-network/center data scope is not asserted
without documented policy and safe representative accounts.

This repository has no Dialysis Connect application source, so isolated
component and backend unit tests cannot be authored here. Browser-level
component contracts (form controls, validation, and feedback), functional
workspace behavior, and cross-role E2E are covered by Playwright. Add isolated
component/unit suites alongside the application source when it is available.

## Setup

```powershell
npm install
npx playwright install chromium
```

## Run the test suite

```powershell
npm run test:e2e
```

`npm run test:bdd:generate` generates Playwright specs from Gherkin without
executing them. Scenarios with missing step implementations are marked fixme
and reported as skipped; they are not treated as passing tests. Implement and
verify their steps before removing the fixme status. `npm run test:e2e`
generates and executes the scenarios. Each run writes Allure results to
`allure-results/` and generates the Allure HTML report at `allure-report/`,
including when one or more tests fail. No Playwright HTML or list reporter is
enabled. Open the report with
`npm run allure:open`, or open `allure-report/index.html` directly. Tests run
in parallel; Playwright selects its worker count automatically based on the
available CPU capacity.

Authenticated tests use the role accounts configured in
`tests/support/auth.js`. Override an individual role with
`DIALYSIS_<ROLE>_USER` and `DIALYSIS_<ROLE>_PASSWORD` (for example,
`DIALYSIS_PATIENT_USER`). The legacy `DIALYSIS_TEST_USER` and
`DIALYSIS_TEST_PASSWORD` variables continue to override the technician account.
In PowerShell, configure them for the current terminal session and run the tests:

```powershell
$env:DIALYSIS_TEST_USER = "your-test-user"
$env:DIALYSIS_TEST_PASSWORD = "your-test-password"
$env:DIALYSIS_PATIENT_USER = "your-patient-test-user"
$env:DIALYSIS_PATIENT_PASSWORD = "your-patient-test-password"
npm run test:e2e
```

Use an authorized test account and do not commit credentials. The authenticated
test submits the login form to the configured app. To target another deployment,
set `PLAYWRIGHT_BASE_URL` before running the tests.
