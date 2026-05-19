#!/usr/bin/env node

/**
 * validate-falsifiable-eng.mjs
 *
 * Validates that the Falsifiable Engineering feature (v3.10.0+) is properly installed.
 * Checks for required files, protocol references, and configuration.
 *
 * Exit codes:
 *   0 = All checks pass
 *   1 = One or more checks failed
 *
 * Usage: node scripts/validate-falsifiable-eng.mjs
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const projectRoot = path.resolve(__dirname, '..');

const REQUIRED_FILES = [
  '.claude/agents/critic.md',
  '.github/agents/critic.agent.md',
  '.agents/plans/PLAN-EXAMPLE.md',
  '.agents/templates/bdr-commit.md',
];

const PROTOCOL_REFS = [
  {
    file: 'CLAUDE.md',
    pattern: 'Falsifiable Engineering',
    description: 'Falsifiable Engineering section',
  },
  {
    file: '.github/copilot-instructions.md',
    pattern: 'Falsifiable Engineering',
    description: 'Falsifiable Engineering section',
  },
  {
    file: '.github/agents/manager.agent.md',
    pattern: 'Falsifiable Engineering Protocol',
    description: 'Falsifiable Engineering Protocol section',
  },
  {
    file: '.github/agents/engineer.agent.md',
    pattern: 'BDR Commits',
    description: 'BDR commit format requirement',
  },
  {
    file: '.github/agents/engineer.agent.md',
    pattern: 'Critic Review (Post-Commit)',
    description: 'Critic review section',
  },
  {
    file: '.agents/workspace-map.md',
    pattern: 'bdr-commit.md',
    description: 'BDR template reference in workspace-map',
  },
];

let failures = 0;

console.log('🔍 Validating Falsifiable Engineering (v3.10.0+)...\n');

// Check 1: Required files exist
console.log('1️⃣  Checking required files:');
for (const filePath of REQUIRED_FILES) {
  const fullPath = path.join(projectRoot, filePath);
  if (fs.existsSync(fullPath)) {
    const stat = fs.statSync(fullPath);
    console.log(`   ✅ ${filePath} (${stat.size} bytes)`);
  } else {
    console.log(`   ❌ ${filePath} — MISSING`);
    failures++;
  }
}
console.log('');

// Check 2: Protocol references exist in key files
console.log('2️⃣  Checking protocol references:');
for (const ref of PROTOCOL_REFS) {
  const fullPath = path.join(projectRoot, ref.file);
  if (!fs.existsSync(fullPath)) {
    console.log(`   ❌ ${ref.file} — FILE NOT FOUND (can't check for "${ref.pattern}")`);
    failures++;
    continue;
  }

  const content = fs.readFileSync(fullPath, 'utf-8');
  if (content.includes(ref.pattern)) {
    console.log(`   ✅ ${ref.file} — "${ref.description}"`);
  } else {
    console.log(
      `   ❌ ${ref.file} — MISSING reference to "${ref.description}" (pattern: "${ref.pattern}")`
    );
    failures++;
  }
}
console.log('');

// Check 3: Critic agent referenced in manager frontmatter
console.log('3️⃣  Checking agent declarations:');
const managerPath = path.join(projectRoot, '.github/agents/manager.agent.md');
const managerContent = fs.readFileSync(managerPath, 'utf-8');

if (managerContent.includes('agent: critic')) {
  console.log(`   ✅ Manager handoff includes Critic agent`);
} else {
  console.log(`   ❌ Manager handoff — MISSING Critic agent declaration`);
  failures++;
}

if (managerContent.includes('critic-report.md')) {
  console.log(`   ✅ Manager mentions critic-report.md`);
} else {
  console.log(`   ❌ Manager — MISSING reference to critic-report.md`);
  failures++;
}
console.log('');

// Check 4: BDR template content check
console.log('4️⃣  Checking template file quality:');
const bdrPath = path.join(projectRoot, '.agents/templates/bdr-commit.md');
const bdrContent = fs.readFileSync(bdrPath, 'utf-8');

const bdrFields = ['Contract:', 'Acceptance:', 'Rejected:', 'Non-scope:', 'Co-Authored-By:'];
let bdrFieldsMissing = [];
for (const field of bdrFields) {
  if (!bdrContent.includes(field)) {
    bdrFieldsMissing.push(field);
  }
}

if (bdrFieldsMissing.length === 0) {
  console.log(`   ✅ BDR template includes all required fields`);
} else {
  console.log(`   ❌ BDR template — MISSING fields: ${bdrFieldsMissing.join(', ')}`);
  failures++;
}
console.log('');

// Check 5: Critic agent has correct tools
console.log('5️⃣  Checking Critic agent configuration:');
const criticPath = path.join(projectRoot, '.github/agents/critic.agent.md');
const criticContent = fs.readFileSync(criticPath, 'utf-8');

const criticRequirements = [
  { pattern: 'Over-engineering', description: 'Over-engineering scan section' },
  { pattern: 'Slop', description: 'Slop scan section' },
  { pattern: 'Redundancy', description: 'Redundancy scan section' },
  { pattern: 'CLEAN', description: 'Verdict format (CLEAN)' },
  { pattern: 'NEEDS_REVISION', description: 'Verdict format (NEEDS_REVISION)' },
  { pattern: 'critic-report.md', description: 'Report file reference' },
];

for (const req of criticRequirements) {
  if (criticContent.includes(req.pattern)) {
    console.log(`   ✅ ${req.description}`);
  } else {
    console.log(`   ❌ ${req.description} — MISSING`);
    failures++;
  }
}
console.log('');

// Final report
console.log('═══════════════════════════════════════');
if (failures === 0) {
  console.log('✅ All validation checks passed!');
  console.log('\nFalsifiable Engineering (v3.10.0) is properly installed:');
  console.log('  • Critic agent defined for both Claude Code and Copilot');
  console.log('  • Plan-first protocol documented');
  console.log('  • BDR commit template available');
  console.log('  • Manager and Engineer protocols updated');
  console.log('  • Workspace map reflects new files');
  process.exit(0);
} else {
  console.log(`❌ ${failures} validation check(s) failed`);
  console.log('\nTo fix:');
  console.log('  1. Verify all files exist in the paths listed above');
  console.log('  2. Ensure protocol sections are properly formatted');
  console.log('  3. Check that file references are correct');
  console.log('  4. Re-run this script to confirm all checks pass');
  process.exit(1);
}
