const { expect } = require('@playwright/test');

async function waitForReportData(page) {
  await expect
    .poll(
      async () => {
        const rows = await page.getByRole('row').allInnerTexts();
        return rows.length > 1 && !rows.some((row) => row.includes('Loading reports...'));
      },
      { timeout: 12_000 },
    )
    .toBe(true);
}

module.exports = { waitForReportData };
