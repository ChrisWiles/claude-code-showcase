---
name: security-best-practices
description: Security best practices for code, including input validation, authentication, authorization, and vulnerability prevention. Use when implementing security features or reviewing code for security issues.
---

# Security Best Practices

## When to Use This Skill

- Implementing authentication or authorization
- Handling user input or external data
- Working with sensitive information
- Reviewing code for security vulnerabilities
- Implementing API endpoints
- Adding validation logic

## Core Security Principles

### 1. Input Validation

**Always validate and sanitize user input:**

```typescript
// ✅ Good: Validate and sanitize input
function processUserInput(input: string): string {
  if (!input || typeof input !== 'string') {
    throw new Error('Invalid input');
  }
  
  // Sanitize: Remove dangerous characters
  const sanitized = input.trim().replace(/[<>]/g, '');
  
  // Validate: Check format
  if (sanitized.length > 1000) {
    throw new Error('Input too long');
  }
  
  return sanitized;
}

// ❌ Bad: Using input directly
function processUserInput(input: string): string {
  return input; // Vulnerable to XSS, injection attacks
}
```

### 2. Authentication & Authorization

**Implement proper auth checks:**

```typescript
// ✅ Good: Verify authentication and authorization
async function updateUserProfile(userId: string, data: ProfileData): Promise<void> {
  // 1. Verify user is authenticated
  const currentUser = await getCurrentUser();
  if (!currentUser) {
    throw new UnauthorizedError('Not authenticated');
  }
  
  // 2. Verify user has permission (authorization)
  if (currentUser.id !== userId && !currentUser.isAdmin) {
    throw new ForbiddenError('Not authorized to update this profile');
  }
  
  // 3. Validate data
  const validatedData = validateProfileData(data);
  
  // 4. Perform update
  await db.users.update(userId, validatedData);
}

// ❌ Bad: No auth checks
async function updateUserProfile(userId: string, data: ProfileData): Promise<void> {
  await db.users.update(userId, data); // Anyone can update any profile!
}
```

### 3. Secrets Management

**Never hardcode secrets:**

```typescript
// ✅ Good: Use environment variables
const apiKey = process.env.API_KEY;
if (!apiKey) {
  throw new Error('API_KEY environment variable not set');
}

// ❌ Bad: Hardcoded secret
const apiKey = 'sk_live_abc123xyz'; // NEVER DO THIS!
```

### 4. SQL Injection Prevention

**Use parameterized queries:**

```typescript
// ✅ Good: Parameterized query
async function getUserByEmail(email: string): Promise<User> {
  return await db.query(
    'SELECT * FROM users WHERE email = $1',
    [email]
  );
}

// ❌ Bad: String concatenation
async function getUserByEmail(email: string): Promise<User> {
  return await db.query(
    `SELECT * FROM users WHERE email = '${email}'` // SQL injection vulnerability!
  );
}
```

### 5. XSS Prevention

**Escape output, use safe rendering:**

```tsx
// ✅ Good: React automatically escapes
function UserProfile({ userName }: Props) {
  return <div>{userName}</div>; // Safe: React escapes by default
}

// ✅ Good: Explicit sanitization when needed
import DOMPurify from 'dompurify';

function RichContent({ html }: Props) {
  const sanitized = DOMPurify.sanitize(html);
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}

// ❌ Bad: Unescaped HTML
function RichContent({ html }: Props) {
  return <div dangerouslySetInnerHTML={{ __html: html }} />; // XSS vulnerability!
}
```

### 6. Secure Dependencies

**Keep dependencies updated and scan for vulnerabilities:**

```bash
# Run regular security audits
npm audit
npm audit fix

# Use tools like Snyk or Dependabot
```

## Security Checklist

Before submitting code, verify:

- [ ] All user input is validated and sanitized
- [ ] Authentication is required for protected routes
- [ ] Authorization checks are in place
- [ ] No secrets are hardcoded
- [ ] SQL queries use parameterized statements
- [ ] XSS prevention is implemented
- [ ] Error messages don't leak sensitive info
- [ ] Dependencies are up to date
- [ ] Security events are logged (without sensitive data)

## Common Vulnerabilities to Avoid

1. **SQL Injection** - Use parameterized queries
2. **XSS (Cross-Site Scripting)** - Escape output, sanitize HTML
3. **CSRF (Cross-Site Request Forgery)** - Use CSRF tokens
4. **Authentication Bypass** - Always verify auth
5. **Authorization Bypass** - Check permissions
6. **Sensitive Data Exposure** - Don't leak secrets or internal info
7. **Using Components with Known Vulnerabilities** - Keep dependencies updated
8. **Insufficient Logging & Monitoring** - Log security events

## Related Skills

- `testing-patterns` - Write security tests
- `systematic-debugging` - Debug security issues
- `graphql-schema` - Secure GraphQL APIs
