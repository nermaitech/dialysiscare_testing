const { expect } = require('@playwright/test');

const defaultPassword = 'Test@1234';
const credentialsByRole = {
  superadmin: { username: 'superadmin@test.com', password: defaultPassword },
  networkadmin: { username: 'networkadmin@test.com', password: defaultPassword },
  centeradmin: { username: 'vendor@test.com', password: defaultPassword },
  technician: { username: 'technician@test.com', password: defaultPassword },
  patient: { username: 'patient@test.com', password: defaultPassword },
};
const roles = Object.keys(credentialsByRole);

function getCredentials(role) {
  const credentials = credentialsByRole[role];
  if (!credentials) {
    throw new Error(`Unknown sign-in role "${role}". Expected one of: ${roles.join(', ')}.`);
  }

  const roleEnvPrefix = `DIALYSIS_${role.toUpperCase()}`;
  const useLegacyTechnicianCredentials = role === 'technician';
  return {
    username:
      process.env[`${roleEnvPrefix}_USER`] ??
      (useLegacyTechnicianCredentials ? process.env.DIALYSIS_TEST_USER : undefined) ??
      credentials.username,
    password:
      process.env[`${roleEnvPrefix}_PASSWORD`] ??
      (useLegacyTechnicianCredentials ? process.env.DIALYSIS_TEST_PASSWORD : undefined) ??
      credentials.password,
  };
}

const { username: testUser, password: testPassword } = getCredentials('technician');

async function signIn(page, role = 'technician') {
  const { username, password } = getCredentials(role);
  await page.goto('/login');
  const loginUrl = page.url();
  let loginDialogMessage;

  const dismissLoginDialog = async (dialog) => {
    loginDialogMessage = dialog.message();
    await dialog.dismiss();
  };
  page.on('dialog', dismissLoginDialog);

  await page.getByPlaceholder('Enter your email').fill(username);
  await page.getByPlaceholder('Enter your password').fill(password);
  await page.getByRole('button', { name: 'Sign In' }).click();

  try {
    await expect
      .poll(() => page.url() !== loginUrl || loginDialogMessage !== undefined, { timeout: 30_000 })
      .toBe(true);
  } finally {
    page.off('dialog', dismissLoginDialog);
  }

  expect(
    loginDialogMessage,
    loginDialogMessage ?? 'Expected sign-in to succeed and leave the login page.',
  ).toBeUndefined();
  await expect(page).not.toHaveURL(/\/login(?:[?#].*)?$/);
  await expect(page.getByRole('main')).toBeVisible();
}

module.exports = { getCredentials, signIn, testPassword, testUser };
