# BDD Test Suite - Resolution Guide

## Current Blocker
The test suite cannot execute due to **ambiguous step definition matching** in the BDD framework.

### Error Message
```
Error: Multiple definitions matched scenario step
```

### Root Cause
Step definitions from `new-features.steps.js` conflict with existing definitions in `role-flows.steps.js` due to overlapping patterns and specific steps.

### Example Conflict
```javascript
// role-flows.steps.js - Line 124
When('I navigate to every operational workspace', async ({ page }) => {
  // specific implementation
});

// new-features.steps.js - Line ~2242 (regex pattern)
When(/^I navigate to (.+)$/, async ({ page }, location) => {
  // generic implementation
});

// Conflict: "When I navigate to X" matches BOTH definitions
```

## Solution Approaches

### Option 1: Remove Duplicate Implementations (RECOMMENDED)

**Steps:**
1. Open `role-flows.steps.js` and identify all existing step definitions
2. For each existing step, remove the matching implementation from `new-features.steps.js`
3. Keep generic regex patterns only for steps not covered in `role-flows.steps.js`

**Implementation:**
```bash
# 1. Review conflicts
npm run test:bdd:generate 2>&1 | grep "Multiple definitions"

# 2. For each conflicting step, identify:
#    - Which file defines it (role-flows.steps.js or new-features.steps.js)
#    - Whether it's a specific or generic pattern

# 3. Keep role-flows.steps.js definitions (they're more tested)
# 4. Remove duplicates from new-features.steps.js

# 5. Rebuild
npm run test:bdd:generate
```

**Specific Steps to Remove from new-features.steps.js:**
- "I navigate to..." steps (already in role-flows.steps.js)
- "I sign in as..." steps (already in role-flows.steps.js)
- "I see the ... dashboard" (covered by existing patterns)

### Option 2: Move Conflicting Steps to role-flows.steps.js

**Approach:**
1. Move all working step implementations from `new-features.steps.js` to `role-flows.steps.js`
2. Keep only the regex patterns in `new-features.steps.js` for edge cases
3. Organize by role at the end of `role-flows.steps.js`

**Commands:**
```bash
# 1. Copy working implementations to role-flows.steps.js
# 2. Organize by role
# 3. Remove from new-features.steps.js
# 4. Rebuild
npm run test:bdd:generate
```

### Option 3: Rename Feature Syntax to Avoid Conflicts

**Approach:**
1. Update feature files to use unique step phrasings
2. Avoid generic patterns that overlap with existing steps
3. Maintain readability while ensuring unique matching

**Example:**
```gherkin
# Current (conflicts)
When I navigate to Patients
When I navigate to Sessions

# Proposed (unique)
When I navigate to the Patients workspace
When I navigate to the Sessions workspace

# OR
When I access the Patients module
When I access the Sessions module
```

## Recommended Resolution Steps

### Step 1: Analyze Existing Steps
```bash
# Extract all step definitions from role-flows.steps.js
grep -E "^(When|Then|Given)\(" tests/steps/role-flows.steps.js | head -50

# Extract all patterns from new-features.steps.js
grep -E "^(When|Then|Given)\(" tests/steps/new-features.steps.js | head -50
```

### Step 2: Identify Conflicts
```bash
# Run generation and capture all conflicts
npm run test:bdd:generate 2>&1 | grep -A 3 "Multiple definitions"
```

### Step 3: Create Clean new-features.steps.js

Replace duplicates with unique implementations:

```javascript
// Keep ONLY non-conflicting steps in new-features.steps.js

// REMOVE these (they exist in role-flows.steps.js):
// - "I navigate to ..." (specific variants exist)
// - "I sign in as {string}"
// - "I see the {string} dashboard"

// KEEP these:
// - Complex workflow steps unique to new features
// - Center admin specific operations
// - Network admin specific operations
// - Validation and error scenarios
// - Data isolation verification
```

### Step 4: Verify No Conflicts
```bash
npm run test:bdd:generate 2>&1
# Should show: No "Multiple definitions matched" errors
```

### Step 5: Run Tests
```bash
npm run test:e2e
# Should execute tests without step definition errors
```

## Minimal Fix Script

Execute this to quickly remove the most common conflicts:

```bash
#!/bin/bash
# Remove conflicting regex patterns from new-features.steps.js

# Backup original
cp tests/steps/new-features.steps.js tests/steps/new-features.steps.js.backup

# Remove the broadest patterns that cause conflicts
sed -i '/When(.*I navigate to/d' tests/steps/new-features.steps.js
sed -i '/Then(.*I navigate to/d' tests/steps/new-features.steps.js
sed -i '/When(.*I sign in/d' tests/steps/new-features.steps.js
sed -i '/Given(.*I sign in/d' tests/steps/new-features.steps.js

# Rebuild
npm run test:bdd:generate
```

## Verification Checklist

After applying fix:

- [ ] No "Multiple definitions matched" errors in generation output
- [ ] All feature files generate successfully
- [ ] Generated spec files: `tests/.features-gen/tests/features/**/*.spec.js`
- [ ] Can run: `npm run test:e2e`
- [ ] Tests execute (will likely have some failures, but no step matching errors)
- [ ] Allure report generates: `npm run allure:open`

## Expected Output After Fix

```bash
$ npm run test:bdd:generate
> bddgen test

✓ Generated X test files from Y features
✓ All steps matched successfully
✓ Ready to run tests

$ npm run test:e2e
✓ 95 tests found
Running tests...
✓ X passed
⊘ Y skipped/pending
✗ Z failed

Report generated: allure-report/
```

## Alternative: Quick Start Without Conflicts

If resolution is taking too long, use this temporary workaround:

1. Create minimal step file with only essential steps
2. Run against a subset of features first
3. Expand gradually

```bash
# 1. Rename conflicting file temporarily
mv tests/steps/new-features.steps.js tests/steps/new-features.steps.js.disabled

# 2. Generate with only role-flows
npm run test:bdd:generate

# 3. Run limited subset
npx playwright test tests/.features-gen/tests/features/technician/ --reporter=dot

# 4. When ready, fix and re-enable new-features.steps.js
```

## Support & Debugging

### If tests still fail after fix:

1. **Check step matching:**
   ```bash
   npm run test:bdd:generate 2>&1 | grep -i "error\|multiple"
   ```

2. **View generated tests:**
   ```bash
   ls -la tests/.features-gen/tests/features/*/
   ```

3. **Run single feature in debug:**
   ```bash
   npx playwright test --debug tests/.features-gen/tests/features/technician/session-management.feature.spec.js
   ```

4. **Check authentication:**
   ```bash
   # Verify auth.js has correct credentials
   cat tests/support/auth.js
   ```

5. **Check environment:**
   ```bash
   # Verify application is accessible
   curl -I https://dialysiscare.nermaiapps.in/login
   ```

## Timeline

- **Phase 1 (Immediate)**: Remove conflicting definitions (~15 mins)
- **Phase 2 (Quick)**: Verify no conflicts (~5 mins)
- **Phase 3 (Execution)**: Run full test suite (~15-20 mins)
- **Phase 4 (Analysis)**: Review results and coverage (~10 mins)

**Total Time**: ~45-50 minutes to resolution

## Questions & Troubleshooting

**Q: How do I know which steps to remove?**
A: Look for the "Multiple definitions matched" error - it shows both definitions. Keep the one from role-flows.steps.js (it's older and tested).

**Q: Can I have both files?**
A: Yes, but not with overlapping definitions. Remove duplicates first.

**Q: What if tests still fail?**
A: That's normal. Focus on step matching first (this guide). Test failures are a separate issue to debug.

**Q: How do I contribute more steps?**
A: Add them to `role-flows.steps.js` (it's the main file) with unique step patterns.
