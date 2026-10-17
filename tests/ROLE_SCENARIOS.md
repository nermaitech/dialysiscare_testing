# Role-based BDD scenario coverage

## Scope and evidence

Executable Gherkin features are organized by role in `tests/features/`, with
step definitions in `tests/steps/role-flows.steps.js`. `playwright-bdd`
generates native Playwright tests into the ignored `tests/.features-gen/`
directory. Run `npm run test:bdd:generate` to generate specs or
`npm run test:e2e` to generate and execute them with Allure reporting.

Scenarios are based on the available Dialysis Connect staging UI and cover
browser-visible form contracts, functional workspace behavior, and E2E
workflows. This repository does not contain application source, so isolated
React/component or backend unit tests cannot be added here.

## Scenario inventory

| Role / surface | Scenario coverage |
|---|---|
| Shared authentication | Sign-in controls and recovery links; malformed email; invalid credentials; successful sign-in for all five roles; logout and authenticated-route protection. |
| Superadmin, networkadmin, centeradmin, technician | Dashboard and navigation across Patients, Sessions, Machines, Dialyzers, Reports, Inventory, and the Technician entry; center identity; technician analytics and dashboard shortcuts. |
| Technician - Patients | Search known/missing patient; required-field and name validation; date-of-birth age calculation; patient list viewing. |
| Center admin - Patients | Dedicated test patient create, view, edit, and delete lifecycle. |
| Technician - Sessions | Status filters; required setup selections; unknown UHID rejection; hourly-reading required time; treatment start/end flow and end-treatment boundary/error validations in the cross-role workflow. Setup allocation and completed-session checks require center-scoped test data. |
| Technician - Machines and Dialyzers | Machine search and denied status change; dialyzer status filters; add-dialyzer required-field validation during session setup. |
| Technician - Reports | Search, view patient/treatment details, filters, create-form navigation, edit/cancel, delete, PDF download, and export. |
| Technician - Inventory | Medicine/equipment filtering, stock values, calendar navigation, and previous-month boundary. |
| Patient | Dashboard/reports navigation; direct staff-route denial; own-report view and PDF download; report-to-UHID isolation regression. |
| Technician → centeradmin → patient | Complete a test dialysis treatment, create its report, verify the same report under centeradmin and patient accounts, and download as patient. |

## Coverage review

Patient create/edit/delete and report edit/delete are exercised only against
test records. The technician-to-patient E2E carries the generated report ID
across roles and is serial because machine/session data is shared. Other
workspace CRUD actions are not invented where the observed UI exposes no
supported action. The staging UI observed here does not expose a tenant/center
administration workspace, user-management screen, appointment booking, or
session edit/delete actions. Admin data-scope rules still require product
requirements and representative cross-network/center fixture accounts.

Known staging regressions are kept as assertions: patient report results have
previously included multiple UHIDs, patient PDF actions have not consistently
emitted browser downloads, and report loading/filter rendering is intermittent.
The expected tests fail explicitly rather than treating incomplete loading as
success.

## Execution dependencies

- Set role-specific `DIALYSIS_<ROLE>_USER` and
  `DIALYSIS_<ROLE>_PASSWORD` variables when the local defaults are not
  provisioned in the target deployment.
- The shared patient fixture must have an active dialyzer and an available
  machine/technician assigned to the test center.
- Patient edit/delete controls are available to center admins, not the
  technician account; the dedicated CRUD lifecycle runs as center admin.
- Technician session setup and completed-session checks skip with a clear
  reason when the account has no assigned technician/machine or no matching
  center-scoped session.
- The treatment E2E skips with a clear reason if its selected machine becomes
  busy; a skip does not validate treatment completion or report handoff.
- The end-to-end session scenario creates or resumes a test session and
  generates a report. Run it only against an authorized test environment and
  test account.
- Allure is the only configured Playwright reporter.

## Latest validation

BDD generation succeeds without ambiguous step definitions. Focused checks
after the latest changes passed for technician navigation and the center-admin
patient CRUD lifecycle. Technician session-management checks passed for the
unknown-UHID and status-filter scenarios; setup allocation and completed
session-action scenarios were skipped because the current technician account
had no center-scoped technician assignment or completed session. The latest
full-suite result (173 scenarios: 34 passed, 37 failed, 102 skipped) predates
these focused fixes and should not be treated as the current full-suite result.
