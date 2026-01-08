---
name: formik-patterns
description: Formik form handling with validation patterns. Use when building forms, implementing validation, or handling form submission.
---

# Formik Patterns
# Formik 模式

## Basic Form Setup
## 基本表單設定

```tsx
import { useFormik } from 'formik';
import * as yup from 'yup';

const validationSchema = yup.object({
  email: yup.string().email('Invalid email').required('Email is required'),
  password: yup.string().min(8, 'Min 8 characters').required('Password is required'),
});

const LoginForm = () => {
  const formik = useFormik({
    initialValues: {
      email: '',
      password: '',
    },
    validationSchema,
    onSubmit: async (values) => {
      await loginMutation({ variables: { input: values } });
    },
  });

  return (
    <VStack gap="$4">
      <Input
        label="Email"
        value={formik.values.email}
        onChangeText={formik.handleChange('email')}
        onBlur={formik.handleBlur('email')}
        error={formik.touched.email ? formik.errors.email : undefined}
        keyboardType="email-address"
        autoCapitalize="none"
      />

      <Input
        label="Password"
        value={formik.values.password}
        onChangeText={formik.handleChange('password')}
        onBlur={formik.handleBlur('password')}
        error={formik.touched.password ? formik.errors.password : undefined}
        secureTextEntry
      />

      <Button
        onPress={formik.handleSubmit}
        isDisabled={!formik.isValid || formik.isSubmitting}
        isLoading={formik.isSubmitting}
      >
        Login
      </Button>
    </VStack>
  );
};
```

## Validation Schemas
## 驗證模式

### Common Patterns
### 常見模式

```typescript
import * as yup from 'yup';

// Email
// 電子郵件
email: yup.string()
  .email('Invalid email address')
  .required('Email is required')

// Password with requirements
// 具有要求的密碼
password: yup.string()
  .min(8, 'Must be at least 8 characters')
  .matches(/[a-z]/, 'Must contain lowercase letter')
  .matches(/[A-Z]/, 'Must contain uppercase letter')
  .matches(/[0-9]/, 'Must contain number')
  .required('Password is required')

// Confirm password
// 確認密碼
confirmPassword: yup.string()
  .oneOf([yup.ref('password')], 'Passwords must match')
  .required('Please confirm password')

// Phone number
// 電話號碼
phone: yup.string()
  .matches(/^\+?[1-9]\d{1,14}$/, 'Invalid phone number')
  .required('Phone is required')

// Optional field with validation when present
// 存在時需驗證的選填欄位
website: yup.string()
  .url('Must be a valid URL')
  .nullable()

// Number with range
// 具有範圍的數字
quantity: yup.number()
  .min(1, 'Minimum 1')
  .max(100, 'Maximum 100')
  .required('Quantity required')

// Array with minimum items
// 具有最小項目數的陣列
tags: yup.array()
  .of(yup.string())
  .min(1, 'Select at least one tag')
```

### Conditional Validation
### 條件驗證

```typescript
const schema = yup.object({
  hasCompany: yup.boolean(),
  companyName: yup.string().when('hasCompany', {
    is: true,
    then: (schema) => schema.required('Company name required'),
    otherwise: (schema) => schema.nullable(),
  }),
});
```

## Form Field Helpers
## 表單欄位輔助函數

### Input Helper
### 輸入輔助函數

```tsx
const getFieldProps = (name: keyof typeof formik.values) => ({
  value: formik.values[name],
  onChangeText: formik.handleChange(name),
  onBlur: formik.handleBlur(name),
  error: formik.touched[name] ? formik.errors[name] : undefined,
});

// Usage
// 使用方式
<Input label="Email" {...getFieldProps('email')} />
```

### Select/Picker Helper
### 選擇器輔助函數

```tsx
<Select
  label="Country"
  value={formik.values.country}
  onValueChange={(value) => formik.setFieldValue('country', value)}
  error={formik.touched.country ? formik.errors.country : undefined}
  options={countryOptions}
/>
```

## Form Submission with GraphQL
## 使用 GraphQL 提交表單

```tsx
const CreateItemForm = () => {
  const [createItem] = useCreateItemMutation({
    onCompleted: () => {
      toast.success({ title: 'Item created' });
      navigation.goBack();
    },
    onError: (error) => {
      console.error('createItem failed:', error);
      toast.error({ title: 'Failed to create item' });
    },
  });

  const formik = useFormik({
    initialValues: { name: '', description: '' },
    validationSchema,
    onSubmit: async (values, { setSubmitting }) => {
      try {
        await createItem({ variables: { input: values } });
      } finally {
        setSubmitting(false);
      }
    },
  });

  return (
    <VStack gap="$4">
      {/* Form fields */}
      {/* 表單欄位 */}
      <Button
        onPress={formik.handleSubmit}
        isDisabled={!formik.isValid || formik.isSubmitting}
        isLoading={formik.isSubmitting}
      >
        Create
      </Button>
    </VStack>
  );
};
```

## Edit Form with Initial Values
## 具有初始值的編輯表單

```tsx
const EditItemForm = ({ item }: { item: Item }) => {
  const [updateItem] = useUpdateItemMutation({
    onCompleted: () => toast.success({ title: 'Saved' }),
    onError: (error) => {
      console.error('updateItem failed:', error);
      toast.error({ title: 'Save failed' });
    },
  });

  const formik = useFormik({
    initialValues: {
      name: item.name,
      description: item.description ?? '',
    },
    enableReinitialize: true, // Update when item prop changes
                              // 當 item prop 改變時更新
    validationSchema,
    onSubmit: async (values) => {
      await updateItem({
        variables: { id: item.id, input: values },
      });
    },
  });

  // Track if form has changes
  // 追蹤表單是否有變更
  const hasChanges = formik.dirty;

  return (
    <VStack gap="$4">
      {/* Form fields */}
      {/* 表單欄位 */}
      <Button
        onPress={formik.handleSubmit}
        isDisabled={!hasChanges || !formik.isValid || formik.isSubmitting}
        isLoading={formik.isSubmitting}
      >
        Save Changes
      </Button>
    </VStack>
  );
};
```

## Form State Helpers
## 表單狀態輔助函數

```tsx
const {
  values,          // Current form values
                   // 目前表單值
  errors,          // Validation errors
                   // 驗證錯誤
  touched,         // Fields that have been touched
                   // 已觸碰的欄位
  isValid,         // Form passes validation
                   // 表單通過驗證
  isSubmitting,    // Submit in progress
                   // 提交進行中
  dirty,           // Values differ from initial
                   // 值與初始值不同
  handleSubmit,    // Submit handler
                   // 提交處理器
  handleChange,    // Change handler
                   // 變更處理器
  handleBlur,      // Blur handler
                   // 失焦處理器
  setFieldValue,   // Set single field
                   // 設定單一欄位
  setFieldTouched, // Mark field touched
                   // 標記欄位已觸碰
  resetForm,       // Reset to initial values
                   // 重設為初始值
  setSubmitting,   // Control submitting state
                   // 控制提交狀態
} = formik;
```

## Multi-Step Forms
## 多步驟表單

```tsx
const MultiStepForm = () => {
  const [step, setStep] = useState(0);

  const formik = useFormik({
    initialValues: {
      // Step 1
      // 步驟 1
      name: '',
      email: '',
      // Step 2
      // 步驟 2
      address: '',
      city: '',
      // Step 3
      // 步驟 3
      cardNumber: '',
    },
    validationSchema: stepSchemas[step],
    onSubmit: async (values) => {
      if (step < steps.length - 1) {
        setStep(step + 1);
      } else {
        await submitOrder(values);
      }
    },
  });

  return (
    <VStack>
      {step === 0 && <PersonalInfoStep formik={formik} />}
      {step === 1 && <AddressStep formik={formik} />}
      {step === 2 && <PaymentStep formik={formik} />}

      <HStack gap="$4">
        {step > 0 && (
          <Button variant="outline" onPress={() => setStep(step - 1)}>
            Back
          </Button>
        )}
        <Button
          onPress={formik.handleSubmit}
          isDisabled={!formik.isValid}
          isLoading={formik.isSubmitting}
        >
          {step < steps.length - 1 ? 'Next' : 'Submit'}
        </Button>
      </HStack>
    </VStack>
  );
};
```

## Anti-Patterns
## 反模式

```tsx
// WRONG - Not showing validation errors
// 錯誤 - 不顯示驗證錯誤
<Input
  value={formik.values.email}
  onChangeText={formik.handleChange('email')}
/>

// CORRECT - Show errors when touched
// 正確 - 觸碰時顯示錯誤
<Input
  value={formik.values.email}
  onChangeText={formik.handleChange('email')}
  onBlur={formik.handleBlur('email')}
  error={formik.touched.email ? formik.errors.email : undefined}
/>


// WRONG - Submit button always enabled
// 錯誤 - 提交按鈕總是啟用
<Button onPress={formik.handleSubmit}>Submit</Button>

// CORRECT - Disabled when invalid or submitting
// 正確 - 無效或提交時停用
<Button
  onPress={formik.handleSubmit}
  isDisabled={!formik.isValid || formik.isSubmitting}
  isLoading={formik.isSubmitting}
>
  Submit
</Button>


// WRONG - No error handling on mutation
// 錯誤 - 變更沒有錯誤處理
onSubmit: async (values) => {
  await createItem({ variables: { input: values } });
}

// CORRECT - Handle errors
// 正確 - 處理錯誤
onSubmit: async (values, { setSubmitting }) => {
  try {
    await createItem({ variables: { input: values } });
  } catch (error) {
    toast.error({ title: 'Failed to save' });
  } finally {
    setSubmitting(false);
  }
}
```

## Integration with Other Skills
## 與其他技能的整合

- **graphql-schema**: Mutation submission patterns
- **graphql-schema**：變更提交模式
- **react-ui-patterns**: Loading/error states
- **react-ui-patterns**：載入/錯誤狀態
- **testing-patterns**: Test form validation and submission
- **testing-patterns**：測試表單驗證和提交
