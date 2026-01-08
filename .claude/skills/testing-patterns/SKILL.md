---
name: testing-patterns
description: Jest testing patterns, factory functions, mocking strategies, and TDD workflow. Use when writing unit tests, creating test factories, or following TDD red-green-refactor cycle.
---

# Testing Patterns and Utilities
# 測試模式與工具

## Testing Philosophy
## 測試哲學

**Test-Driven Development (TDD):**
**測試驅動開發 (TDD)：**
- Write failing test FIRST
- 先編寫失敗的測試
- Implement minimal code to pass
- 實作最少的程式碼以通過測試
- Refactor after green
- 測試通過後進行重構
- Never write production code without a failing test
- 永遠不要在沒有失敗測試的情況下編寫正式程式碼

**Behavior-Driven Testing:**
**行為驅動測試：**
- Test behavior, not implementation
- 測試行為，而非實作
- Focus on public APIs and business requirements
- 專注於公開 API 和業務需求
- Avoid testing implementation details
- 避免測試實作細節
- Use descriptive test names that describe behavior
- 使用描述行為的測試名稱

**Factory Pattern:**
**工廠模式：**
- Create `getMockX(overrides?: Partial<X>)` functions
- 建立 `getMockX(overrides?: Partial<X>)` 函數
- Provide sensible defaults
- 提供合理的預設值
- Allow overriding specific properties
- 允許覆蓋特定屬性
- Keep tests DRY and maintainable
- 保持測試乾淨且易於維護

## Test Utilities
## 測試工具

### Custom Render Function
### 自訂渲染函數

Create a custom render that wraps components with required providers:

建立一個自訂渲染函數，將元件包裝在必要的 provider 中：

```typescript
// src/utils/testUtils.tsx
import { render } from '@testing-library/react-native';
import { ThemeProvider } from './theme';

export const renderWithTheme = (ui: React.ReactElement) => {
  return render(
    <ThemeProvider>{ui}</ThemeProvider>
  );
};
```

**Usage:**
**使用方式：**
```typescript
import { renderWithTheme } from 'utils/testUtils';
import { screen } from '@testing-library/react-native';

it('should render component', () => {
  renderWithTheme(<MyComponent />);
  expect(screen.getByText('Hello')).toBeTruthy();
});
```

## Factory Pattern
## 工廠模式

### Component Props Factory
### 元件屬性工廠

```typescript
import { ComponentProps } from 'react';

const getMockMyComponentProps = (
  overrides?: Partial<ComponentProps<typeof MyComponent>>
) => {
  return {
    title: 'Default Title',
    count: 0,
    onPress: jest.fn(),
    isLoading: false,
    ...overrides,
  };
};

// Usage in tests
// 在測試中使用
it('should render with custom title', () => {
  const props = getMockMyComponentProps({ title: 'Custom Title' });
  renderWithTheme(<MyComponent {...props} />);
  expect(screen.getByText('Custom Title')).toBeTruthy();
});
```

### Data Factory
### 資料工廠

```typescript
interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
}

const getMockUser = (overrides?: Partial<User>): User => {
  return {
    id: '123',
    name: 'John Doe',
    email: 'john@example.com',
    role: 'user',
    ...overrides,
  };
};

// Usage
// 使用方式
it('should display admin badge for admin users', () => {
  const user = getMockUser({ role: 'admin' });
  renderWithTheme(<UserCard user={user} />);
  expect(screen.getByText('Admin')).toBeTruthy();
});
```

## Mocking Patterns
## 模擬模式

### Mocking Modules
### 模擬模組

```typescript
// Mock entire module
// 模擬整個模組
jest.mock('utils/analytics');

// Mock with factory function
// 使用工廠函數模擬
jest.mock('utils/analytics', () => ({
  Analytics: {
    logEvent: jest.fn(),
  },
}));

// Access mock in test
// 在測試中存取模擬物件
const mockLogEvent = jest.requireMock('utils/analytics').Analytics.logEvent;
```

### Mocking GraphQL Hooks
### 模擬 GraphQL Hooks

```typescript
jest.mock('./GetItems.generated', () => ({
  useGetItemsQuery: jest.fn(),
}));

const mockUseGetItemsQuery = jest.requireMock(
  './GetItems.generated'
).useGetItemsQuery as jest.Mock;

// In test
// 在測試中
mockUseGetItemsQuery.mockReturnValue({
  data: { items: [] },
  loading: false,
  error: undefined,
});
```

## Test Structure
## 測試結構

```typescript
describe('ComponentName', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Rendering', () => {
    it('should render component with default props', () => {});
    it('should render loading state when loading', () => {});
  });

  describe('User interactions', () => {
    it('should call onPress when button is clicked', async () => {});
  });

  describe('Edge cases', () => {
    it('should handle empty data gracefully', () => {});
  });
});
```

## Query Patterns
## 查詢模式

```typescript
// Element must exist
// 元素必須存在
expect(screen.getByText('Hello')).toBeTruthy();

// Element should not exist
// 元素不應存在
expect(screen.queryByText('Goodbye')).toBeNull();

// Element appears asynchronously
// 元素非同步出現
await waitFor(() => {
  expect(screen.findByText('Loaded')).toBeTruthy();
});
```

## User Interaction Patterns
## 使用者互動模式

```typescript
import { fireEvent, screen } from '@testing-library/react-native';

it('should submit form on button click', async () => {
  const onSubmit = jest.fn();
  renderWithTheme(<LoginForm onSubmit={onSubmit} />);

  fireEvent.changeText(screen.getByLabelText('Email'), 'user@example.com');
  fireEvent.changeText(screen.getByLabelText('Password'), 'password123');
  fireEvent.press(screen.getByTestId('login-button'));

  await waitFor(() => {
    expect(onSubmit).toHaveBeenCalled();
  });
});
```

## Anti-Patterns to Avoid
## 應避免的反模式

### Testing Mock Behavior Instead of Real Behavior
### 測試模擬行為而非真實行為

```typescript
// Bad - testing the mock
// 不好 - 測試模擬物件
expect(mockFetchData).toHaveBeenCalled();

// Good - testing actual behavior
// 好 - 測試實際行為
expect(screen.getByText('John Doe')).toBeTruthy();
```

### Not Using Factories
### 不使用工廠函數

```typescript
// Bad - duplicated, inconsistent test data
// 不好 - 重複且不一致的測試資料
it('test 1', () => {
  const user = { id: '1', name: 'John', email: 'john@test.com', role: 'user' };
});
it('test 2', () => {
  const user = { id: '2', name: 'Jane', email: 'jane@test.com' }; // Missing role!
                                                                   // 缺少 role！
});

// Good - reusable factory
// 好 - 可重複使用的工廠函數
const user = getMockUser({ name: 'Custom Name' });
```

## Best Practices
## 最佳實踐

1. **Always use factory functions** for props and data
1. **總是使用工廠函數** 來建立屬性和資料
2. **Test behavior, not implementation**
2. **測試行為，而非實作**
3. **Use descriptive test names**
3. **使用描述性的測試名稱**
4. **Organize with describe blocks**
4. **使用 describe 區塊組織測試**
5. **Clear mocks between tests**
5. **在測試之間清除模擬物件**
6. **Keep tests focused** - one behavior per test
6. **保持測試專注** - 每個測試一個行為

## Running Tests
## 執行測試

```bash
# Run all tests
# 執行所有測試
npm test

# Run with coverage
# 執行並產生覆蓋率報告
npm run test:coverage

# Run specific file
# 執行特定檔案
npm test ComponentName.test.tsx
```

## Integration with Other Skills
## 與其他技能的整合

- **react-ui-patterns**: Test all UI states (loading, error, empty, success)
- **react-ui-patterns**：測試所有 UI 狀態（載入、錯誤、空白、成功）
- **systematic-debugging**: Write test that reproduces bug before fixing
- **systematic-debugging**：在修復之前編寫能重現錯誤的測試
