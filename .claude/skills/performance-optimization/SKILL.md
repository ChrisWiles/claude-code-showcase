---
name: performance-optimization
description: Performance optimization patterns for React, TypeScript, and Node.js applications. Use when optimizing rendering, reducing bundle size, improving load times, or addressing performance issues.
---

# Performance Optimization

## When to Use This Skill

- Optimizing component rendering
- Reducing bundle size
- Improving page load times
- Addressing performance bottlenecks
- Optimizing API responses
- Implementing lazy loading
- Optimizing database queries

## React Performance Patterns

### 1. Memoization

**Use React.memo for expensive components:**

```tsx
// ✅ Good: Memoize expensive component
const ExpensiveComponent = React.memo(({ data }: Props) => {
  return (
    <div>
      {data.map(item => <ComplexItem key={item.id} item={item} />)}
    </div>
  );
});

// ❌ Bad: Re-renders on every parent update
const ExpensiveComponent = ({ data }: Props) => {
  return (
    <div>
      {data.map(item => <ComplexItem key={item.id} item={item} />)}
    </div>
  );
};
```

### 2. useMemo and useCallback

**Memoize expensive calculations and callbacks:**

```tsx
// ✅ Good: Memoize expensive computation
const MyComponent = ({ items }: Props) => {
  const sortedItems = useMemo(() => {
    return items.sort((a, b) => a.value - b.value);
  }, [items]);

  const handleClick = useCallback((id: string) => {
    console.log('Clicked:', id);
  }, []);

  return <ItemList items={sortedItems} onClick={handleClick} />;
};

// ❌ Bad: Recompute on every render
const MyComponent = ({ items }: Props) => {
  const sortedItems = items.sort((a, b) => a.value - b.value);
  
  const handleClick = (id: string) => {
    console.log('Clicked:', id);
  };

  return <ItemList items={sortedItems} onClick={handleClick} />;
};
```

### 3. Lazy Loading

**Code split and lazy load components:**

```tsx
// ✅ Good: Lazy load heavy components
import { lazy, Suspense } from 'react';

const HeavyChart = lazy(() => import('./HeavyChart'));
const HeavyEditor = lazy(() => import('./HeavyEditor'));

function Dashboard() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <HeavyChart data={data} />
      <HeavyEditor content={content} />
    </Suspense>
  );
}

// ❌ Bad: Load everything upfront
import HeavyChart from './HeavyChart';
import HeavyEditor from './HeavyEditor';

function Dashboard() {
  return (
    <>
      <HeavyChart data={data} />
      <HeavyEditor content={content} />
    </>
  );
}
```

### 4. Virtualization for Long Lists

**Use virtualization for large lists:**

```tsx
// ✅ Good: Virtualize long lists
import { FlashList } from '@shopify/flash-list';

function UserList({ users }: Props) {
  return (
    <FlashList
      data={users}
      estimatedItemSize={80}
      renderItem={({ item }) => <UserCard user={item} />}
    />
  );
}

// ❌ Bad: Render all items
function UserList({ users }: Props) {
  return (
    <div>
      {users.map(user => <UserCard key={user.id} user={user} />)}
    </div>
  );
}
```

### 5. Avoid Inline Functions and Objects

**Define functions and objects outside render:**

```tsx
// ✅ Good: Stable references
const EMPTY_ARRAY = [];
const DEFAULT_STYLE = { padding: 10 };

function MyComponent({ items = EMPTY_ARRAY }: Props) {
  return <List items={items} style={DEFAULT_STYLE} />;
}

// ❌ Bad: New references on every render
function MyComponent({ items }: Props) {
  return <List items={items || []} style={{ padding: 10 }} />;
}
```

## Bundle Size Optimization

### 1. Tree Shaking

**Import only what you need:**

```typescript
// ✅ Good: Named imports for tree shaking
import { debounce, throttle } from 'lodash-es';

// ❌ Bad: Imports entire library
import _ from 'lodash';
const debounced = _.debounce(fn);
```

### 2. Dynamic Imports

**Load code on demand:**

```typescript
// ✅ Good: Dynamic import
async function loadFeature() {
  const { heavyFunction } = await import('./heavyModule');
  return heavyFunction();
}

// ❌ Bad: Static import
import { heavyFunction } from './heavyModule';

async function loadFeature() {
  return heavyFunction();
}
```

### 3. Analyze Bundle

**Regularly analyze your bundle:**

```bash
# For webpack
npm run build -- --analyze

# For vite
npm run build && npx vite-bundle-visualizer
```

## Database Performance

### 1. Indexing

**Add indexes for frequently queried fields:**

```sql
-- ✅ Good: Index on commonly queried fields
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Use indexes in queries
SELECT * FROM users WHERE email = 'user@example.com';
```

### 2. Query Optimization

**Optimize queries with proper joins and projections:**

```typescript
// ✅ Good: Select only needed fields
const users = await db.query(
  'SELECT id, name, email FROM users WHERE active = $1 LIMIT 100',
  [true]
);

// ❌ Bad: Select all fields, no limit
const users = await db.query(
  'SELECT * FROM users WHERE active = $1',
  [true]
);
```

### 3. Connection Pooling

**Use connection pooling:**

```typescript
// ✅ Good: Connection pool
import { Pool } from 'pg';

const pool = new Pool({
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// ❌ Bad: New connection per query
import { Client } from 'pg';

const client = new Client();
await client.connect();
```

## API Performance

### 1. Caching

**Implement caching strategies:**

```typescript
// ✅ Good: Cache responses
import { cache } from './cache';

async function getUserData(userId: string) {
  const cacheKey = `user:${userId}`;
  
  // Check cache first
  const cached = await cache.get(cacheKey);
  if (cached) return cached;
  
  // Fetch from database
  const user = await db.users.findById(userId);
  
  // Cache for 5 minutes
  await cache.set(cacheKey, user, { ttl: 300 });
  
  return user;
}
```

### 2. Pagination

**Always paginate large datasets:**

```typescript
// ✅ Good: Paginated response
async function getUsers(page: number = 1, limit: number = 20) {
  const offset = (page - 1) * limit;
  
  const [users, total] = await Promise.all([
    db.users.findMany({ skip: offset, take: limit }),
    db.users.count()
  ]);
  
  return {
    data: users,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit)
    }
  };
}

// ❌ Bad: Return all records
async function getUsers() {
  return await db.users.findMany();
}
```

### 3. Compression

**Enable response compression:**

```typescript
// ✅ Good: Enable compression
import compression from 'compression';

app.use(compression());
```

## Performance Monitoring

### 1. React DevTools Profiler

**Profile component renders:**

```tsx
import { Profiler } from 'react';

function onRenderCallback(
  id: string,
  phase: 'mount' | 'update',
  actualDuration: number
) {
  console.log(`${id} (${phase}) took ${actualDuration}ms`);
}

<Profiler id="MyComponent" onRender={onRenderCallback}>
  <MyComponent />
</Profiler>
```

### 2. Performance API

**Measure critical operations:**

```typescript
// Measure operation time
performance.mark('operation-start');
await heavyOperation();
performance.mark('operation-end');

performance.measure('operation', 'operation-start', 'operation-end');
const measure = performance.getEntriesByName('operation')[0];
console.log(`Operation took ${measure.duration}ms`);
```

## Performance Checklist

- [ ] Components use React.memo where appropriate
- [ ] Expensive calculations use useMemo
- [ ] Callbacks use useCallback
- [ ] Heavy components are lazy loaded
- [ ] Long lists are virtualized
- [ ] Bundle size is analyzed and optimized
- [ ] Database queries use indexes
- [ ] API responses are cached
- [ ] Large datasets are paginated
- [ ] Compression is enabled
- [ ] Performance is monitored

## Related Skills

- `react-ui-patterns` - Optimize React components
- `testing-patterns` - Performance testing
- `systematic-debugging` - Debug performance issues
- `graphql-schema` - Optimize GraphQL queries

## Resources

- [React Performance Optimization](https://react.dev/learn/render-and-commit)
- [Web Vitals](https://web.dev/vitals/)
- [Lighthouse](https://developers.google.com/web/tools/lighthouse)
