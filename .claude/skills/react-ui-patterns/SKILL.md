---
name: react-ui-patterns
description: Modern React UI patterns for loading states, error handling, and data fetching. Use when building UI components, handling async data, or managing UI states.
---

# React UI Patterns
# React UI 模式

## Core Principles
## 核心原則

1. **Never show stale UI** - Loading spinners only when actually loading
1. **永不顯示過時的 UI** - 只在實際載入時顯示載入旋轉器
2. **Always surface errors** - Users must know when something fails
2. **總是顯示錯誤** - 使用者必須知道何時發生失敗
3. **Optimistic updates** - Make the UI feel instant
3. **樂觀更新** - 讓 UI 感覺即時
4. **Progressive disclosure** - Show content as it becomes available
4. **漸進式揭露** - 當內容可用時顯示
5. **Graceful degradation** - Partial data is better than no data
5. **優雅降級** - 部分資料勝過沒有資料

## Loading State Patterns
## 載入狀態模式

### The Golden Rule
### 黃金法則

**Show loading indicator ONLY when there's no data to display.**

**只在沒有資料可顯示時顯示載入指示器。**

```typescript
// CORRECT - Only show loading when no data exists
// 正確 - 只在沒有資料存在時顯示載入
const { data, loading, error } = useGetItemsQuery();

if (error) return <ErrorState error={error} onRetry={refetch} />;
if (loading && !data) return <LoadingState />;
if (!data?.items.length) return <EmptyState />;

return <ItemList items={data.items} />;
```

```typescript
// WRONG - Shows spinner even when we have cached data
// 錯誤 - 即使有快取資料也顯示旋轉器
if (loading) return <LoadingState />; // Flashes on refetch!
                                      // 重新取得時會閃爍！
```

### Loading State Decision Tree
### 載入狀態決策樹

```
Is there an error?
有錯誤嗎？
  → Yes: Show error state with retry option
  → 是：顯示錯誤狀態並提供重試選項
  → No: Continue
  → 否：繼續

Is it loading AND we have no data?
正在載入且沒有資料嗎？
  → Yes: Show loading indicator (spinner/skeleton)
  → 是：顯示載入指示器（旋轉器/骨架）
  → No: Continue
  → 否：繼續

Do we have data?
有資料嗎？
  → Yes, with items: Show the data
  → 是，有項目：顯示資料
  → Yes, but empty: Show empty state
  → 是，但為空：顯示空白狀態
  → No: Show loading (fallback)
  → 否：顯示載入（後備）
```

### Skeleton vs Spinner
### 骨架 vs 旋轉器

| Use Skeleton When | Use Spinner When |
|-------------------|------------------|
| Known content shape | Unknown content shape |
| 已知內容形狀 | 未知內容形狀 |
| List/card layouts | Modal actions |
| 列表/卡片佈局 | 模態框操作 |
| Initial page load | Button submissions |
| 初始頁面載入 | 按鈕提交 |
| Content placeholders | Inline operations |
| 內容佔位符 | 內聯操作 |

## Error Handling Patterns
## 錯誤處理模式

### The Error Handling Hierarchy
### 錯誤處理層次結構

```
1. Inline error (field-level) → Form validation errors
1. 內聯錯誤（欄位級別）→ 表單驗證錯誤
2. Toast notification → Recoverable errors, user can retry
2. Toast 通知 → 可恢復的錯誤，使用者可以重試
3. Error banner → Page-level errors, data still partially usable
3. 錯誤橫幅 → 頁面級別錯誤，資料仍部分可用
4. Full error screen → Unrecoverable, needs user action
4. 完整錯誤畫面 → 無法恢復，需要使用者操作
```

### Always Show Errors
### 總是顯示錯誤

**CRITICAL: Never swallow errors silently.**

**關鍵：永遠不要靜默吞噬錯誤。**

```typescript
// CORRECT - Error always surfaced to user
// 正確 - 錯誤總是顯示給使用者
const [createItem, { loading }] = useCreateItemMutation({
  onCompleted: () => {
    toast.success({ title: 'Item created' });
  },
  onError: (error) => {
    console.error('createItem failed:', error);
    toast.error({ title: 'Failed to create item' });
  },
});

// WRONG - Error silently caught, user has no idea
// 錯誤 - 錯誤被靜默捕獲，使用者不知道
const [createItem] = useCreateItemMutation({
  onError: (error) => {
    console.error(error); // User sees nothing!
                          // 使用者什麼都看不到！
  },
});
```

### Error State Component Pattern
### 錯誤狀態元件模式

```typescript
interface ErrorStateProps {
  error: Error;
  onRetry?: () => void;
  title?: string;
}

const ErrorState = ({ error, onRetry, title }: ErrorStateProps) => (
  <div className="error-state">
    <Icon name="exclamation-circle" />
    <h3>{title ?? 'Something went wrong'}</h3>
    <p>{error.message}</p>
    {onRetry && (
      <Button onClick={onRetry}>Try Again</Button>
    )}
  </div>
);
```

## Button State Patterns
## 按鈕狀態模式

### Button Loading State
### 按鈕載入狀態

```tsx
<Button
  onClick={handleSubmit}
  isLoading={isSubmitting}
  disabled={!isValid || isSubmitting}
>
  Submit
</Button>
```

### Disable During Operations
### 操作期間停用

**CRITICAL: Always disable triggers during async operations.**

**關鍵：在非同步操作期間總是停用觸發器。**

```tsx
// CORRECT - Button disabled while loading
// 正確 - 載入時按鈕停用
<Button
  disabled={isSubmitting}
  isLoading={isSubmitting}
  onClick={handleSubmit}
>
  Submit
</Button>

// WRONG - User can tap multiple times
// 錯誤 - 使用者可以點擊多次
<Button onClick={handleSubmit}>
  {isSubmitting ? 'Submitting...' : 'Submit'}
</Button>
```

## Empty States
## 空白狀態

### Empty State Requirements
### 空白狀態要求

Every list/collection MUST have an empty state:

每個列表/集合都必須有空白狀態：

```tsx
// WRONG - No empty state
// 錯誤 - 沒有空白狀態
return <FlatList data={items} />;

// CORRECT - Explicit empty state
// 正確 - 明確的空白狀態
return (
  <FlatList
    data={items}
    ListEmptyComponent={<EmptyState />}
  />
);
```

### Contextual Empty States
### 情境式空白狀態

```tsx
// Search with no results
// 搜尋無結果
<EmptyState
  icon="search"
  title="No results found"
  description="Try different search terms"
/>

// List with no items yet
// 列表尚無項目
<EmptyState
  icon="plus-circle"
  title="No items yet"
  description="Create your first item"
  action={{ label: 'Create Item', onClick: handleCreate }}
/>
```

## Form Submission Pattern
## 表單提交模式

```tsx
const MyForm = () => {
  const [submit, { loading }] = useSubmitMutation({
    onCompleted: handleSuccess,
    onError: handleError,
  });

  const handleSubmit = async () => {
    if (!isValid) {
      toast.error({ title: 'Please fix errors' });
      return;
    }
    await submit({ variables: { input: values } });
  };

  return (
    <form>
      <Input
        value={values.name}
        onChange={handleChange('name')}
        error={touched.name ? errors.name : undefined}
      />
      <Button
        type="submit"
        onClick={handleSubmit}
        disabled={!isValid || loading}
        isLoading={loading}
      >
        Submit
      </Button>
    </form>
  );
};
```

## Anti-Patterns
## 反模式

### Loading States
### 載入狀態

```typescript
// WRONG - Spinner when data exists (causes flash)
// 錯誤 - 資料存在時顯示旋轉器（造成閃爍）
if (loading) return <Spinner />;

// CORRECT - Only show loading without data
// 正確 - 只在沒有資料時顯示載入
if (loading && !data) return <Spinner />;
```

### Error Handling
### 錯誤處理

```typescript
// WRONG - Error swallowed
// 錯誤 - 錯誤被吞噬
try {
  await mutation();
} catch (e) {
  console.log(e); // User has no idea!
                  // 使用者不知道！
}

// CORRECT - Error surfaced
// 正確 - 錯誤被顯示
onError: (error) => {
  console.error('operation failed:', error);
  toast.error({ title: 'Operation failed' });
}
```

### Button States
### 按鈕狀態

```typescript
// WRONG - Button not disabled during submission
// 錯誤 - 提交期間按鈕未停用
<Button onClick={submit}>Submit</Button>

// CORRECT - Disabled and shows loading
// 正確 - 停用並顯示載入
<Button onClick={submit} disabled={loading} isLoading={loading}>
  Submit
</Button>
```

## Checklist
## 檢查清單

Before completing any UI component:

在完成任何 UI 元件之前：

**UI States:**
**UI 狀態：**
- [ ] Error state handled and shown to user
- [ ] 錯誤狀態已處理並顯示給使用者
- [ ] Loading state shown only when no data exists
- [ ] 只在沒有資料存在時顯示載入狀態
- [ ] Empty state provided for collections
- [ ] 為集合提供空白狀態
- [ ] Buttons disabled during async operations
- [ ] 非同步操作期間按鈕停用
- [ ] Buttons show loading indicator when appropriate
- [ ] 適當時按鈕顯示載入指示器

**Data & Mutations:**
**資料與變更：**
- [ ] Mutations have onError handler
- [ ] 變更有 onError 處理器
- [ ] All user actions have feedback (toast/visual)
- [ ] 所有使用者操作都有回饋（toast/視覺）

## Integration with Other Skills
## 與其他技能的整合

- **graphql-schema**: Use mutation patterns with proper error handling
- **graphql-schema**：使用具有適當錯誤處理的變更模式
- **testing-patterns**: Test all UI states (loading, error, empty, success)
- **testing-patterns**：測試所有 UI 狀態（載入、錯誤、空白、成功）
- **formik-patterns**: Apply form submission patterns
- **formik-patterns**：應用表單提交模式
