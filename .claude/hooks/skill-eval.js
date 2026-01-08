#!/usr/bin/env node
/**
 * Skill Evaluation Engine v2.1
 *
 * Intelligent skill activation based on:
 * - Keywords and patterns in prompts
 * - File paths mentioned or being edited
 * - Directory mappings
 * - Intent detection
 * - Content pattern matching
 *
 * Performance optimizations:
 * - Regex caching for frequently used patterns
 * - Memoization of expensive operations
 * - Early exit strategies
 *
 * Outputs a structured reminder with matched skills and reasons.
 */

const fs = require('fs');
const path = require('path');

// Configuration
const RULES_PATH = path.join(__dirname, 'skill-rules.json');

// Performance: Regex cache to avoid recompilation
const regexCache = new Map();

/**
 * @typedef {Object} SkillMatch
 * @property {string} name - Skill name
 * @property {number} score - Confidence score
 * @property {string[]} reasons - Why this skill was matched
 * @property {number} priority - Skill priority
 */

/**
 * Load skill rules from JSON file
 * @returns {Object} Parsed skill rules
 */
function loadRules() {
  try {
    const content = fs.readFileSync(RULES_PATH, 'utf-8');
    return JSON.parse(content);
  } catch (error) {
    console.error(`Failed to load skill rules: ${error.message}`);
    process.exit(0); // Exit gracefully to not block the prompt
  }
}

/**
 * Extract file paths mentioned in the prompt
 * @param {string} prompt - User's prompt text
 * @returns {string[]} Array of detected file paths
 */
function extractFilePaths(prompt) {
  const paths = new Set();

  // Match explicit paths with extensions (.tsx, .ts, .jsx, .js, .json, .gql, .yaml, .yml, .md, .sh)
  const extensionPattern =
    /(?:^|\s|["'`])([\w\-./]+\.(?:[tj]sx?|json|gql|ya?ml|md|sh))\b/gi;
  let match;
  while ((match = extensionPattern.exec(prompt)) !== null) {
    paths.add(match[1]);
  }

  // Match paths starting with common directories
  const dirPattern =
    /(?:^|\s|["'`])((?:src|app|components|screens|hooks|utils|services|navigation|graphql|localization|\.claude|\.github|\.maestro)\/[\w\-./]+)/gi;
  while ((match = dirPattern.exec(prompt)) !== null) {
    paths.add(match[1]);
  }

  // Match quoted paths
  const quotedPattern = /["'`]([\w\-./]+\/[\w\-./]+)["'`]/g;
  while ((match = quotedPattern.exec(prompt)) !== null) {
    paths.add(match[1]);
  }

  return Array.from(paths);
}

/**
 * Check if a pattern matches the text (with caching)
 * @param {string} text - Text to search in
 * @param {string} pattern - Regex pattern
 * @param {string} flags - Regex flags
 * @returns {boolean}
 */
function matchesPattern(text, pattern, flags = 'i') {
  try {
    const cacheKey = `${pattern}:${flags}`;
    let regex = regexCache.get(cacheKey);
    
    if (!regex) {
      regex = new RegExp(pattern, flags);
      regexCache.set(cacheKey, regex);
    }
    
    return regex.test(text);
  } catch {
    return false;
  }
}

/**
 * Check if a glob pattern matches a file path (with caching)
 * @param {string} filePath - File path to check
 * @param {string} globPattern - Glob pattern (simplified)
 * @returns {boolean}
 */
function matchesGlob(filePath, globPattern) {
  const cacheKey = `glob:${globPattern}`;
  let regex = regexCache.get(cacheKey);
  
  if (!regex) {
    // Convert glob to regex (simplified)
    const regexPattern = globPattern
      .replace(/\./g, '\\.')
      .replace(/\*\*\//g, '<<<DOUBLESTARSLASH>>>')
      .replace(/\*\*/g, '<<<DOUBLESTAR>>>')
      .replace(/\*/g, '[^/]*')
      .replace(/<<<DOUBLESTARSLASH>>>/g, '(.*\\/)?')
      .replace(/<<<DOUBLESTAR>>>/g, '.*')
      .replace(/\?/g, '.');

    try {
      regex = new RegExp(`^${regexPattern}$`, 'i');
      regexCache.set(cacheKey, regex);
    } catch {
      return false;
    }
  }

  try {
    return regex.test(filePath);
  } catch {
    return false;
  }
}

/**
 * Check if file path matches any directory mapping
 * @param {string} filePath - File path to check
 * @param {Object} mappings - Directory to skill mappings
 * @returns {string|null} Matched skill name or null
 */
function matchDirectoryMapping(filePath, mappings) {
  for (const [dir, skillName] of Object.entries(mappings)) {
    if (filePath === dir || filePath.startsWith(dir + '/')) {
      return skillName;
    }
  }
  return null;
}

/**
 * Evaluate a single skill against the prompt and context
 * @param {string} skillName - Name of the skill
 * @param {Object} skill - Skill configuration
 * @param {string} prompt - User's prompt
 * @param {string} promptLower - Lowercase prompt
 * @param {string[]} filePaths - Extracted file paths
 * @param {Object} rules - Full rules object
 * @returns {SkillMatch|null}
 */
function evaluateSkill(
  skillName,
  skill,
  prompt,
  promptLower,
  filePaths,
  rules
) {
  const { triggers = {}, excludePatterns = [], priority = 5 } = skill;
  const scoring = rules.scoring;

  let score = 0;
  const reasons = [];

  // Check exclude patterns first
  for (const excludePattern of excludePatterns) {
    if (matchesPattern(promptLower, excludePattern)) {
      return null;
    }
  }

  // 1. Check keywords
  if (triggers.keywords) {
    for (const keyword of triggers.keywords) {
      if (promptLower.includes(keyword.toLowerCase())) {
        score += scoring.keyword;
        reasons.push(`keyword "${keyword}"`);
      }
    }
  }

  // 2. Check keyword patterns (regex)
  if (triggers.keywordPatterns) {
    for (const pattern of triggers.keywordPatterns) {
      if (matchesPattern(promptLower, pattern)) {
        score += scoring.keywordPattern;
        reasons.push(`pattern /${pattern}/`);
      }
    }
  }

  // 3. Check intent patterns
  if (triggers.intentPatterns) {
    for (const pattern of triggers.intentPatterns) {
      if (matchesPattern(promptLower, pattern)) {
        score += scoring.intentPattern;
        reasons.push(`intent detected`);
        break;
      }
    }
  }

  // 4. Check context patterns
  if (triggers.contextPatterns) {
    for (const pattern of triggers.contextPatterns) {
      if (promptLower.includes(pattern.toLowerCase())) {
        score += scoring.contextPattern;
        reasons.push(`context "${pattern}"`);
      }
    }
  }

  // 5. Check file paths against path patterns
  if (triggers.pathPatterns && filePaths.length > 0) {
    for (const filePath of filePaths) {
      for (const pattern of triggers.pathPatterns) {
        if (matchesGlob(filePath, pattern)) {
          score += scoring.pathPattern;
          reasons.push(`path "${filePath}"`);
          break;
        }
      }
    }
  }

  // 6. Check directory mappings
  if (rules.directoryMappings && filePaths.length > 0) {
    for (const filePath of filePaths) {
      const mappedSkill = matchDirectoryMapping(
        filePath,
        rules.directoryMappings
      );
      if (mappedSkill === skillName) {
        score += scoring.directoryMatch;
        reasons.push(`directory mapping`);
        break;
      }
    }
  }

  // 7. Check content patterns in prompt (for code snippets)
  if (triggers.contentPatterns) {
    for (const pattern of triggers.contentPatterns) {
      if (matchesPattern(prompt, pattern)) {
        score += scoring.contentPattern;
        reasons.push(`code pattern detected`);
        break;
      }
    }
  }

  if (score > 0) {
    return {
      name: skillName,
      score,
      reasons: [...new Set(reasons)],
      priority,
    };
  }

  return null;
}

/**
 * Get related skills that should also be suggested
 * @param {SkillMatch[]} matches - Current matches
 * @param {Object} skills - All skill definitions
 * @returns {string[]} Additional skill names to suggest
 */
function getRelatedSkills(matches, skills) {
  const matchedNames = new Set(matches.map((m) => m.name));
  const related = new Set();

  for (const match of matches) {
    const skill = skills[match.name];
    if (skill?.relatedSkills) {
      for (const relatedName of skill.relatedSkills) {
        if (!matchedNames.has(relatedName)) {
          related.add(relatedName);
        }
      }
    }
  }

  return Array.from(related);
}

/**
 * Format confidence level based on score
 * @param {number} score - Confidence score
 * @param {number} minScore - Minimum threshold
 * @returns {string} Confidence label
 */
function formatConfidence(score, minScore) {
  if (score >= minScore * 3) return 'HIGH';
  if (score >= minScore * 2) return 'MEDIUM';
  return 'LOW';
}

/**
 * Main evaluation function
 * @param {string} prompt - User's prompt
 * @returns {string} Formatted output
 */
function evaluate(prompt) {
  const rules = loadRules();
  const { config, skills } = rules;

  const promptLower = prompt.toLowerCase();
  const filePaths = extractFilePaths(prompt);

  // Evaluate all skills
  const matches = [];
  for (const [name, skill] of Object.entries(skills)) {
    const match = evaluateSkill(
      name,
      skill,
      prompt,
      promptLower,
      filePaths,
      rules
    );
    if (match && match.score >= config.minConfidenceScore) {
      matches.push(match);
    }
  }

  if (matches.length === 0) {
    return '';
  }

  // Sort by score (descending), then by priority (descending)
  matches.sort((a, b) => {
    if (b.score !== a.score) return b.score - a.score;
    return b.priority - a.priority;
  });

  // Limit to max skills
  const topMatches = matches.slice(0, config.maxSkillsToShow);

  // Check for related skills
  const relatedSkills = getRelatedSkills(topMatches, skills);

  // Format output
  let output = '<user-prompt-submit-hook>\n';
  output += 'SKILL ACTIVATION REQUIRED\n\n';

  if (filePaths.length > 0) {
    output += `Detected file paths: ${filePaths.join(', ')}\n\n`;
  }

  output += 'Matched skills (ranked by relevance):\n';

  for (let i = 0; i < topMatches.length; i++) {
    const match = topMatches[i];
    const confidence = formatConfidence(match.score, config.minConfidenceScore);

    output += `${i + 1}. ${match.name} (${confidence} confidence)\n`;

    if (config.showMatchReasons && match.reasons.length > 0) {
      output += `   Matched: ${match.reasons.slice(0, 3).join(', ')}\n`;
    }
  }

  if (relatedSkills.length > 0) {
    output += `\nRelated skills to consider: ${relatedSkills.join(', ')}\n`;
  }

  output += '\nBefore implementing, you MUST:\n';
  output += '1. EVALUATE: State YES/NO for each skill with brief reasoning\n';
  output += '2. ACTIVATE: Invoke the Skill tool for each YES skill\n';
  output += '3. IMPLEMENT: Only proceed after skill activation\n';
  output += '\nExample evaluation:\n';
  output += `- ${topMatches[0].name}: YES - [your reasoning]\n`;
  if (topMatches.length > 1) {
    output += `- ${topMatches[1].name}: NO - [your reasoning]\n`;
  }
  output += '\nDO NOT skip this step. Invoke relevant skills NOW.\n';
  output += '</user-prompt-submit-hook>';

  return output;
}

// Main execution
function main() {
  let input = '';

  process.stdin.setEncoding('utf8');

  process.stdin.on('data', (chunk) => {
    input += chunk;
  });

  process.stdin.on('end', () => {
    let prompt = '';

    try {
      const data = JSON.parse(input);
      prompt = data.prompt || '';
    } catch {
      prompt = input;
    }

    if (!prompt.trim()) {
      process.exit(0);
    }

    try {
      const output = evaluate(prompt);
      if (output) {
        console.log(output);
      }
    } catch (error) {
      console.error(`Skill evaluation failed: ${error.message}`);
    }

    process.exit(0);
  });
}

main();
