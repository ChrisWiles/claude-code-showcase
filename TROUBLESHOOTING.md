# Troubleshooting Guide

Common issues and solutions for Claude Code configuration.

## Table of Contents

1. [Configuration Issues](#configuration-issues)
2. [Hook Issues](#hook-issues)
3. [Skill Issues](#skill-issues)
4. [MCP Server Issues](#mcp-server-issues)
5. [Performance Issues](#performance-issues)

---

## Configuration Issues

### Settings.json Not Loading

**Symptoms:**
- Hooks don't run
- Custom settings not applied

**Solutions:**

1. **Check JSON syntax:**
   ```bash
   node -e "JSON.parse(require('fs').readFileSync('.claude/settings.json', 'utf-8'))"
   ```

2. **Verify file location:**
   ```bash
   ls -la .claude/settings.json
   ```

3. **Check for typos in hook names:**
   - `PreToolUse` (not `PreToolsUse`)
   - `PostToolUse` (not `PostToolsUse`)
   - `UserPromptSubmit` (not `PromptSubmit`)

### CLAUDE.md Not Recognized

**Symptoms:**
- Project context missing
- Claude doesn't know project conventions

**Solutions:**

1. **Check file name (case-sensitive):**
   ```bash
   ls -la CLAUDE.md  # Must be uppercase
   ```

2. **Verify location (try multiple locations):**
   - `.claude/CLAUDE.md` (preferred)
   - `./CLAUDE.md` (project root)
   - `~/.claude/CLAUDE.md` (global)

3. **Restart Claude Code after creating the file**

---

## Hook Issues

### Hooks Not Executing

**Symptoms:**
- Expected behavior doesn't happen
- No output from hooks

**Solutions:**

1. **Check hook matcher:**
   ```json
   {
     "matcher": "Edit|MultiEdit|Write",  // Regex pattern
     "hooks": [...]
   }
   ```

2. **Verify timeout is sufficient:**
   ```json
   {
     "timeout": 30  // Increase if command is slow
   }
   ```

3. **Test hook command manually:**
   ```bash
   # Copy the command from settings.json and run it
   [ "$(git branch --show-current)" != "main" ] || echo "Would block"
   ```

4. **Check exit codes:**
   - `0` = Success
   - `2` = Blocking error (PreToolUse only)
   - Other = Non-blocking error

### Hook Produces Too Much Output

**Symptoms:**
- Overwhelming console output
- Slow hook execution

**Solutions:**

1. **Suppress output:**
   ```json
   {
     "suppressOutput": true
   }
   ```

2. **Redirect stderr:**
   ```bash
   command 2>&1 | tail -30  # Only show last 30 lines
   ```

3. **Add feedback field:**
   ```bash
   echo '{"feedback": "Short message", "suppressOutput": true}'
   ```

### Skill Evaluation Hook Not Working

**Symptoms:**
- Skills not suggested automatically
- Hook times out

**Solutions:**

1. **Check Node.js is installed:**
   ```bash
   node --version  # Should be v14+
   ```

2. **Test skill-eval.js directly:**
   ```bash
   echo '{"prompt": "write a test"}' | node .claude/hooks/skill-eval.js
   ```

3. **Check skill-rules.json syntax:**
   ```bash
   node -e "JSON.parse(require('fs').readFileSync('.claude/hooks/skill-rules.json', 'utf-8'))"
   ```

4. **Increase timeout:**
   ```json
   {
     "timeout": 10  // Increase from 5
   }
   ```

---

## Skill Issues

### Skill Not Activating

**Symptoms:**
- Skill doesn't trigger when expected
- Not suggested by skill-eval hook

**Solutions:**

1. **Check frontmatter format:**
   ```markdown
   ---
   name: skill-name
   description: Clear description with keywords
   ---
   ```

2. **Verify skill name matches directory:**
   ```bash
   # Directory: .claude/skills/testing-patterns/
   # Skill name: testing-patterns
   ```

3. **Update skill-rules.json:**
   ```json
   {
     "skills": {
       "your-skill": {
         "description": "...",
         "triggers": {
           "keywords": ["test", "spec"],
           "keywordPatterns": ["\\btest\\b"]
         }
       }
     }
   }
   ```

4. **Add more trigger keywords:**
   - Think about what users would naturally say
   - Include variations and synonyms

### Skill Content Not Loaded

**Symptoms:**
- Skill activates but content seems missing
- Claude doesn't follow patterns

**Solutions:**

1. **Verify file name is exactly `SKILL.md`** (case-sensitive)

2. **Check file permissions:**
   ```bash
   ls -la .claude/skills/*/SKILL.md
   ```

3. **Ensure file is not empty:**
   ```bash
   wc -l .claude/skills/*/SKILL.md
   ```

### Too Many Skills Suggested

**Symptoms:**
- Overwhelming number of skill suggestions
- Many irrelevant skills

**Solutions:**

1. **Increase minimum confidence score:**
   ```json
   {
     "config": {
       "minConfidenceScore": 5  // Increase from 3
     }
   }
   ```

2. **Add exclude patterns:**
   ```json
   {
     "skills": {
       "testing-patterns": {
         "excludePatterns": ["test data", "test user"]
       }
     }
   }
   ```

3. **Reduce maxSkillsToShow:**
   ```json
   {
     "config": {
       "maxSkillsToShow": 3  // Reduce from 5
     }
   }
   ```

---

## MCP Server Issues

### MCP Server Not Connecting

**Symptoms:**
- Tools not available
- "Server failed to connect" error

**Solutions:**

1. **Check environment variables:**
   ```bash
   echo $JIRA_HOST
   echo $GITHUB_TOKEN
   ```

2. **Test server manually:**
   ```bash
   npx -y @anthropic/mcp-jira --version
   ```

3. **Verify .mcp.json syntax:**
   ```bash
   node -e "JSON.parse(require('fs').readFileSync('.mcp.json', 'utf-8'))"
   ```

4. **Check command path:**
   ```json
   {
     "command": "npx",  // Must be in PATH
     "args": ["-y", "@anthropic/mcp-jira"]
   }
   ```

5. **Review server logs:**
   - Check Claude Code output panel
   - Look for error messages

### MCP Tools Not Showing Up

**Symptoms:**
- Server connects but tools aren't available
- Can't invoke MCP functions

**Solutions:**

1. **Enable MCP servers in settings:**
   ```json
   {
     "enableAllProjectMcpServers": true
   }
   ```

2. **Or enable specific servers:**
   ```json
   {
     "enabledMcpjsonServers": ["jira", "github"]
   }
   ```

3. **Restart Claude Code after configuration change**

---

## Performance Issues

### Hooks Are Slow

**Symptoms:**
- Long delays when editing files
- Timeout errors

**Solutions:**

1. **Increase timeout:**
   ```json
   {
     "timeout": 60  // Give more time
   }
   ```

2. **Optimize hook commands:**
   ```bash
   # Bad: Runs full test suite
   npm test
   
   # Good: Runs only related tests
   npm test -- --findRelatedTests "$CLAUDE_TOOL_INPUT_FILE_PATH"
   ```

3. **Run hooks in parallel (separate hook entries):**
   ```json
   {
     "hooks": [
       { "command": "hook1", "timeout": 30 },
       { "command": "hook2", "timeout": 30 }
     ]
   }
   ```

4. **Disable heavy hooks during rapid development:**
   - Use `settings.local.json` to override
   - Comment out hooks temporarily

### Skill Evaluation Is Slow

**Symptoms:**
- Delay before prompt submission
- Hook timeout

**Solutions:**

1. **Simplify skill-rules.json:**
   - Remove complex regex patterns
   - Reduce number of triggers

2. **Clear regex cache:**
   - Restart Claude Code
   - The cache is in-memory only

3. **Optimize patterns:**
   ```json
   {
     "keywords": ["test"],  // Fast: simple string match
     "keywordPatterns": ["\\btest\\b"]  // Slower: regex
   }
   ```

### Large Files Cause Issues

**Symptoms:**
- Slow to load
- Memory issues

**Solutions:**

1. **Add files to .gitignore:**
   ```gitignore
   node_modules/
   dist/
   build/
   *.log
   ```

2. **Use glob patterns to exclude:**
   ```json
   {
     "excludePatterns": ["node_modules/**", "dist/**"]
   }
   ```

---

## Getting Help

If you're still stuck:

1. **Check the logs:**
   - Claude Code output panel
   - Browser console (if applicable)

2. **Run validation:**
   ```bash
   # Use the validate-config command
   /validate-config
   ```

3. **Simplify and isolate:**
   - Disable all hooks
   - Re-enable one at a time
   - Find the problematic configuration

4. **Review examples in this repository:**
   - Working configurations
   - Tested patterns

5. **Check Claude Code documentation:**
   - [Official docs](https://docs.anthropic.com/en/docs/claude-code)
   - Release notes for updates

---

## Quick Diagnostics

Run these commands to diagnose common issues:

```bash
# 1. Validate all JSON files
for file in .claude/settings.json .claude/hooks/skill-rules.json .mcp.json; do
  [ -f "$file" ] && node -e "JSON.parse(require('fs').readFileSync('$file', 'utf-8'))" && echo "✓ $file" || echo "✗ $file"
done

# 2. Check SKILL.md files
find .claude/skills -name "SKILL.md" -type f | wc -l
echo "skills found"

# 3. Check Node.js version
node --version

# 4. Test skill evaluation
echo '{"prompt": "write a test"}' | node .claude/hooks/skill-eval.js

# 5. Check git branch (for hook testing)
git branch --show-current
```
