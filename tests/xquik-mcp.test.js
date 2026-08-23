const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join, resolve } = require('node:path');
const { spawnSync } = require('node:child_process');
const test = require('node:test');

const root = resolve(__dirname, '..');

function readJson(path) {
  return JSON.parse(readFileSync(join(root, path), 'utf8'));
}

function evaluateSkill(prompt) {
  return spawnSync('node', ['.claude/hooks/skill-eval.js'], {
    cwd: root,
    encoding: 'utf8',
    input: JSON.stringify({ prompt }),
  });
}

test('configures Xquik as a remote OAuth MCP server', () => {
  const server = readJson('.mcp.json').mcpServers.xquik;

  assert.deepEqual(server, {
    type: 'http',
    url: 'https://xquik.com/mcp',
    oauth: { scopes: 'mcp:tools' },
  });
});

test('registers the X research skill and its MCP-only tool boundary', () => {
  const skill = readFileSync(
    join(root, '.claude/skills/x-research/SKILL.md'),
    'utf8'
  );
  const rules = readJson('.claude/hooks/skill-rules.json');

  assert.match(skill, /^---\nname: x-research\n/);
  assert.match(
    skill,
    /allowed-tools: mcp__xquik__explore mcp__xquik__xquik/
  );
  assert.ok(rules.skills['x-research']);
});

test('suggests X research for explicit public-post research', () => {
  const prompts = [
    'Research recent X posts about TypeScript and summarize the themes.',
    'Search tweets about the React release and cite the sources.',
    'Check current X trends before drafting release notes.',
    'Analyze X sentiment around our launch.',
  ];

  for (const prompt of prompts) {
    const result = evaluateSkill(prompt);

    assert.equal(result.status, 0, result.stderr);
    assert.match(result.stdout, /1\. x-research \(HIGH confidence\)/);
  }
});

test('does not confuse chart axes with X research', () => {
  const prompts = [
    'Adjust the x-axis labels on this chart.',
    'Update the Twitter icon in the footer.',
  ];

  for (const prompt of prompts) {
    const result = evaluateSkill(prompt);

    assert.equal(result.status, 0, result.stderr);
    assert.doesNotMatch(result.stdout, /x-research/);
  }
});
