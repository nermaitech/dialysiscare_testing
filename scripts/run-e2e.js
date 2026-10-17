const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const projectRoot = path.resolve(__dirname, '..');

const resultsDirectory = path.join(projectRoot, 'allure-results');
fs.rmSync(resultsDirectory, { recursive: true, force: true });

function run(scriptPath, args) {
  const result = spawnSync(process.execPath, [scriptPath, ...args], {
    cwd: projectRoot,
    stdio: 'inherit',
  });

  if (result.error) {
    console.error(`Unable to run ${scriptPath}: ${result.error.message}`);
    return 1;
  }

  return result.status === null ? 1 : result.status;
}

const bddExitCode = run(
  path.join(projectRoot, 'node_modules', 'playwright-bdd', 'dist', 'cli', 'index.js'),
  ['test'],
);
const testExitCode = bddExitCode || run(
  path.join(projectRoot, 'node_modules', 'playwright', 'cli.js'),
  ['test'],
);
const reportExitCode = run(
  path.join(projectRoot, 'node_modules', 'allure-commandline', 'bin', 'allure'),
  ['generate', 'allure-results', '--clean', '-o', 'allure-report'],
);

process.exitCode = testExitCode || reportExitCode;
