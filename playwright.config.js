const { defineConfig } = require('@playwright/test');
const { defineBddConfig } = require('playwright-bdd');

const testDir = defineBddConfig({
  features: 'tests/features/**/*.feature',
  steps: 'tests/steps/**/*.js',
  outputDir: 'tests/.features-gen',
  missingSteps: 'skip-scenario',
});

module.exports = defineConfig({
  testDir,
  fullyParallel: true,
  timeout: 180_000,
  reporter: [
    [
      'allure-playwright',
      {
        resultsDir: 'allure-results',
        detail: true,
        suiteTitle: true,
        environmentInfo: {
          Roles: 'Super Admin, Network Admin, Center Admin, Technician, Patient',
          BaseURL: process.env.PLAYWRIGHT_BASE_URL || 'https://dialysiscare.nermaiapps.in',
        },
      },
    ],
  ],
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL || 'https://dialysiscare.nermaiapps.in',
    browserName: 'chromium',
    headless: false,
  },
});
