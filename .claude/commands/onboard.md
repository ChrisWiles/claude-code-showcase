---
name: onboard
description: Onboard Claude to a new task by exploring the codebase and preparing a task brief
allowed-tools: Read, Glob, Grep, Write, Bash(find:*)
---

# Onboard

You are given the following context:
$ARGUMENTS

## Instructions

> "AI models are geniuses who start from scratch on every task." – Noam Brown

Your job is to **onboard** yourself to the current task.

Do this by:

- Using extended thinking
- Exploring the codebase
- Asking me questions if needed

The goal is to get you fully prepared to start working on the task.

Take as long as you need to get yourself ready. Overdoing it is better than underdoing it.

Record everything in a `.claude/tasks/[TASK_ID]/onboarding.md` file. This file will be used to onboard you to the task in a new session if needed, so make sure it's comprehensive.
