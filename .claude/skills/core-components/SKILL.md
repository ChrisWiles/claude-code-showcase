---
name: core-components
description: Core component library and design system patterns. Use when building UI, using design tokens, or working with the component library.
---

# Core Components
# 核心元件

## Design System Overview
## 設計系統概述

Use components from your core library instead of raw platform components. This ensures consistent styling and behavior.

使用核心庫中的元件，而非原始平台元件。這確保了一致的樣式和行為。

## Design Tokens
## 設計標記

**NEVER hard-code values. Always use design tokens.**

**永遠不要硬編碼值。總是使用設計標記。**

### Spacing Tokens
### 間距標記

```tsx
// CORRECT - Use tokens
// 正確 - 使用標記
<Box padding="$4" marginBottom="$2" />

// WRONG - Hard-coded values
// 錯誤 - 硬編碼值
<Box padding={16} marginBottom={8} />
```

| Token | Value |
|-------|-------|
| `$1` | 4px |
| `$2` | 8px |
| `$3` | 12px |
| `$4` | 16px |
| `$6` | 24px |
| `$8` | 32px |

### Color Tokens
### 顏色標記

```tsx
// CORRECT - Semantic tokens
// 正確 - 語意化標記
<Text color="$textPrimary" />
<Box backgroundColor="$backgroundSecondary" />

// WRONG - Hard-coded colors
// 錯誤 - 硬編碼顏色
<Text color="#333333" />
<Box backgroundColor="rgb(245, 245, 245)" />
```

| Semantic Token | Use For |
|----------------|---------|
| `$textPrimary` | Main text |
| `$textPrimary` | 主要文字 |
| `$textSecondary` | Supporting text |
| `$textSecondary` | 支援文字 |
| `$textTertiary` | Disabled/hint text |
| `$textTertiary` | 停用/提示文字 |
| `$primary500` | Brand/accent color |
| `$primary500` | 品牌/強調顏色 |
| `$statusError` | Error states |
| `$statusError` | 錯誤狀態 |
| `$statusSuccess` | Success states |
| `$statusSuccess` | 成功狀態 |

### Typography Tokens
### 排版標記

```tsx
<Text fontSize="$lg" fontWeight="$semibold" />
```

| Token | Size |
|-------|------|
| `$xs` | 12px |
| `$sm` | 14px |
| `$md` | 16px |
| `$lg` | 18px |
| `$xl` | 20px |
| `$2xl` | 24px |

## Core Components
## 核心元件

### Box
### Box 容器

Base layout component with token support:

支援標記的基礎佈局元件：

```tsx
<Box
  padding="$4"
  backgroundColor="$backgroundPrimary"
  borderRadius="$lg"
>
  {children}
</Box>
```

### HStack / VStack
### 水平堆疊 / 垂直堆疊

Horizontal and vertical flex layouts:

水平和垂直彈性佈局：

```tsx
<HStack gap="$3" alignItems="center">
  <Icon name="user" />
  <Text>Username</Text>
</HStack>

<VStack gap="$4" padding="$4">
  <Heading>Title</Heading>
  <Text>Content</Text>
</VStack>
```

### Text
### 文字

Typography with token support:

支援標記的排版：

```tsx
<Text
  fontSize="$lg"
  fontWeight="$semibold"
  color="$textPrimary"
>
  Hello World
</Text>
```

### Button
### 按鈕

Interactive button with variants:

具有變體的互動按鈕：

```tsx
<Button
  onPress={handlePress}
  variant="solid"
  size="md"
  isLoading={loading}
  isDisabled={disabled}
>
  Click Me
</Button>
```

| Variant | Use For |
|---------|---------|
| `solid` | Primary actions |
| `solid` | 主要操作 |
| `outline` | Secondary actions |
| `outline` | 次要操作 |
| `ghost` | Tertiary/subtle actions |
| `ghost` | 第三級/微妙操作 |
| `link` | Inline actions |
| `link` | 內聯操作 |

### Input
### 輸入框

Form input with validation:

具有驗證的表單輸入：

```tsx
<Input
  value={value}
  onChangeText={setValue}
  placeholder="Enter text"
  error={touched ? errors.field : undefined}
  label="Field Name"
/>
```

### Card
### 卡片

Content container:

內容容器：

```tsx
<Card padding="$4" gap="$3">
  <CardHeader>
    <Heading size="sm">Card Title</Heading>
  </CardHeader>
  <CardBody>
    <Text>Card content</Text>
  </CardBody>
</Card>
```

## Layout Patterns
## 佈局模式

### Screen Layout
### 畫面佈局

```tsx
const MyScreen = () => (
  <Screen>
    <ScreenHeader title="Page Title" />
    <ScreenContent padding="$4">
      {/* Content */}
      {/* 內容 */}
    </ScreenContent>
  </Screen>
);
```

### Form Layout
### 表單佈局

```tsx
<VStack gap="$4" padding="$4">
  <Input label="Name" {...nameProps} />
  <Input label="Email" {...emailProps} />
  <Button isLoading={loading}>Submit</Button>
</VStack>
```

### List Item Layout
### 列表項目佈局

```tsx
<HStack
  padding="$4"
  gap="$3"
  alignItems="center"
  borderBottomWidth={1}
  borderColor="$borderLight"
>
  <Avatar source={{ uri: imageUrl }} size="md" />
  <VStack flex={1}>
    <Text fontWeight="$semibold">{title}</Text>
    <Text color="$textSecondary" fontSize="$sm">{subtitle}</Text>
  </VStack>
  <Icon name="chevron-right" color="$textTertiary" />
</HStack>
```

## Anti-Patterns
## 反模式

```tsx
// WRONG - Hard-coded values
// 錯誤 - 硬編碼值
<View style={{ padding: 16, backgroundColor: '#fff' }}>

// CORRECT - Design tokens
// 正確 - 設計標記
<Box padding="$4" backgroundColor="$backgroundPrimary">


// WRONG - Raw platform components
// 錯誤 - 原始平台元件
import { View, Text } from 'react-native';

// CORRECT - Core components
// 正確 - 核心元件
import { Box, Text } from 'components/core';


// WRONG - Inline styles
// 錯誤 - 內聯樣式
<Text style={{ fontSize: 18, fontWeight: '600' }}>

// CORRECT - Token props
// 正確 - 標記屬性
<Text fontSize="$lg" fontWeight="$semibold">
```

## Component Props Pattern
## 元件屬性模式

When creating components, use token-based props:

建立元件時，使用基於標記的屬性：

```tsx
interface CardProps {
  padding?: '$2' | '$4' | '$6';
  variant?: 'elevated' | 'outlined' | 'filled';
  children: React.ReactNode;
}

const Card = ({ padding = '$4', variant = 'elevated', children }: CardProps) => (
  <Box
    padding={padding}
    backgroundColor="$backgroundPrimary"
    borderRadius="$lg"
    {...variantStyles[variant]}
  >
    {children}
  </Box>
);
```

## Integration with Other Skills
## 與其他技能的整合

- **react-ui-patterns**: Use core components for UI states
- **react-ui-patterns**：使用核心元件處理 UI 狀態
- **testing-patterns**: Mock core components in tests
- **testing-patterns**：在測試中模擬核心元件
- **storybook**: Document component variants
- **storybook**：記錄元件變體
