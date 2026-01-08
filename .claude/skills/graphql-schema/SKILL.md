---
name: graphql-schema
description: GraphQL queries, mutations, and code generation patterns. Use when creating GraphQL operations, working with Apollo Client, or generating types.
---

# GraphQL Schema Patterns
# GraphQL 模式模式

## Core Rules
## 核心規則

1. **NEVER inline `gql` literals** - Create `.gql` files
1. **永遠不要內聯 `gql` 字串** - 建立 `.gql` 檔案
2. **ALWAYS run codegen** after creating/modifying `.gql` files
2. **總是執行 codegen** 在建立/修改 `.gql` 檔案之後
3. **ALWAYS add `onError` handler** to mutations
3. **總是加入 `onError` 處理器** 到變更操作
4. **Use generated hooks** - Never write raw Apollo hooks
4. **使用生成的 hooks** - 永遠不要編寫原始的 Apollo hooks

## File Structure
## 檔案結構

```
src/
├── components/
│   └── ItemList/
│       ├── ItemList.tsx
│       ├── GetItems.gql           # Query definition
│       │                          # 查詢定義
│       └── GetItems.generated.ts  # Auto-generated (don't edit)
│                                  # 自動生成（不要編輯）
└── graphql/
    └── mutations/
        └── CreateItem.gql         # Shared mutations
                                   # 共享變更
```

## Creating a Query
## 建立查詢

### Step 1: Create .gql file
### 步驟 1：建立 .gql 檔案

```graphql
# src/components/ItemList/GetItems.gql
query GetItems($limit: Int, $offset: Int) {
  items(limit: $limit, offset: $offset) {
    id
    name
    description
    createdAt
  }
}
```

### Step 2: Run codegen
### 步驟 2：執行 codegen

```bash
npm run gql:typegen
```

### Step 3: Import and use generated hook
### 步驟 3：匯入並使用生成的 hook

```typescript
import { useGetItemsQuery } from './GetItems.generated';

const ItemList = () => {
  const { data, loading, error, refetch } = useGetItemsQuery({
    variables: { limit: 20, offset: 0 },
  });

  if (error) return <ErrorState error={error} onRetry={refetch} />;
  if (loading && !data) return <LoadingSkeleton />;
  if (!data?.items.length) return <EmptyState />;

  return <List items={data.items} />;
};
```

## Creating a Mutation
## 建立變更

### Step 1: Create .gql file
### 步驟 1：建立 .gql 檔案

```graphql
# src/graphql/mutations/CreateItem.gql
mutation CreateItem($input: CreateItemInput!) {
  createItem(input: $input) {
    id
    name
    description
  }
}
```

### Step 2: Run codegen
### 步驟 2：執行 codegen

```bash
npm run gql:typegen
```

### Step 3: Use with REQUIRED error handling
### 步驟 3：使用並加上必要的錯誤處理

```typescript
import { useCreateItemMutation } from 'graphql/mutations/CreateItem.generated';

const CreateItemForm = () => {
  const [createItem, { loading }] = useCreateItemMutation({
    // Success handling
    // 成功處理
    onCompleted: (data) => {
      toast.success({ title: 'Item created' });
      navigation.goBack();
    },
    // ERROR HANDLING IS REQUIRED
    // 錯誤處理是必要的
    onError: (error) => {
      console.error('createItem failed:', error);
      toast.error({ title: 'Failed to create item' });
    },
    // Cache update
    // 快取更新
    update: (cache, { data }) => {
      if (data?.createItem) {
        cache.modify({
          fields: {
            items: (existing = []) => [...existing, data.createItem],
          },
        });
      }
    },
  });

  return (
    <Button
      onPress={() => createItem({ variables: { input: formValues } })}
      isDisabled={!isValid || loading}
      isLoading={loading}
    >
      Create
    </Button>
  );
};
```

## Mutation UI Requirements
## 變更 UI 要求

**CRITICAL: Every mutation trigger must:**

**關鍵：每個變更觸發器必須：**

1. **Be disabled during mutation** - Prevent double-clicks
1. **在變更期間停用** - 防止雙擊
2. **Show loading state** - Visual feedback
2. **顯示載入狀態** - 視覺回饋
3. **Have onError handler** - User knows it failed
3. **有 onError 處理器** - 使用者知道失敗了
4. **Show success feedback** - User knows it worked
4. **顯示成功回饋** - 使用者知道成功了

```typescript
// CORRECT - Complete mutation pattern
// 正確 - 完整的變更模式
const [submit, { loading }] = useSubmitMutation({
  onError: (error) => {
    console.error('submit failed:', error);
    toast.error({ title: 'Save failed' });
  },
  onCompleted: () => {
    toast.success({ title: 'Saved' });
  },
});

<Button
  onPress={handleSubmit}
  isDisabled={!isValid || loading}
  isLoading={loading}
>
  Submit
</Button>
```

## Query Options
## 查詢選項

### Fetch Policies
### 取得策略

| Policy | Use When |
|--------|----------|
| `cache-first` | Data rarely changes |
| `cache-first` | 資料很少改變 |
| `cache-and-network` | Want fast + fresh (default) |
| `cache-and-network` | 想要快速 + 新鮮（預設）|
| `network-only` | Always need latest |
| `network-only` | 總是需要最新的 |
| `no-cache` | Never cache (rare) |
| `no-cache` | 永不快取（罕見）|

### Common Options
### 常見選項

```typescript
useGetItemsQuery({
  variables: { id: itemId },

  // Fetch strategy
  // 取得策略
  fetchPolicy: 'cache-and-network',

  // Re-render on network status changes
  // 網路狀態變更時重新渲染
  notifyOnNetworkStatusChange: true,

  // Skip if condition not met
  // 如果條件未滿足則跳過
  skip: !itemId,

  // Poll for updates
  // 輪詢更新
  pollInterval: 30000,
});
```

## Optimistic Updates
## 樂觀更新

For instant UI feedback:

用於即時 UI 回饋：

```typescript
const [toggleFavorite] = useToggleFavoriteMutation({
  optimisticResponse: {
    toggleFavorite: {
      __typename: 'Item',
      id: itemId,
      isFavorite: !currentState,
    },
  },
  onError: (error) => {
    // Rollback happens automatically
    // 回滾自動發生
    console.error('toggleFavorite failed:', error);
    toast.error({ title: 'Failed to update' });
  },
});
```

### When NOT to Use Optimistic Updates
### 何時不使用樂觀更新

- Operations that can fail validation
- 可能無法通過驗證的操作
- Operations with server-generated values
- 具有伺服器生成值的操作
- Destructive operations (delete)
- 破壞性操作（刪除）
- Operations affecting other users
- 影響其他使用者的操作

## Fragments
## 片段

For reusable field selections:

用於可重複使用的欄位選擇：

```graphql
# src/graphql/fragments/ItemFields.gql
fragment ItemFields on Item {
  id
  name
  description
  createdAt
  updatedAt
}
```

Use in queries:

在查詢中使用：

```graphql
query GetItems {
  items {
    ...ItemFields
  }
}
```

## Anti-Patterns
## 反模式

```typescript
// WRONG - Inline gql
// 錯誤 - 內聯 gql
const GET_ITEMS = gql`
  query GetItems { items { id } }
`;

// CORRECT - Use .gql file + generated hook
// 正確 - 使用 .gql 檔案 + 生成的 hook
import { useGetItemsQuery } from './GetItems.generated';


// WRONG - No error handler
// 錯誤 - 沒有錯誤處理器
const [mutate] = useMutation(MUTATION);

// CORRECT - Always handle errors
// 正確 - 總是處理錯誤
const [mutate] = useMutation(MUTATION, {
  onError: (error) => {
    console.error('mutation failed:', error);
    toast.error({ title: 'Operation failed' });
  },
});


// WRONG - Button not disabled during mutation
// 錯誤 - 變更期間按鈕未停用
<Button onPress={submit}>Submit</Button>

// CORRECT - Disabled and loading
// 正確 - 停用並載入
<Button onPress={submit} isDisabled={loading} isLoading={loading}>
  Submit
</Button>
```

## Codegen Commands
## Codegen 指令

```bash
# Generate types from .gql files
# 從 .gql 檔案生成類型
npm run gql:typegen

# Download schema + generate types
# 下載 schema + 生成類型
npm run sync-types
```

## Integration with Other Skills
## 與其他技能的整合

- **react-ui-patterns**: Loading/error/empty states for queries
- **react-ui-patterns**：查詢的載入/錯誤/空白狀態
- **testing-patterns**: Mock generated hooks in tests
- **testing-patterns**：在測試中模擬生成的 hooks
- **formik-patterns**: Mutation submission patterns
- **formik-patterns**：變更提交模式
