---
name: systematic-debugging
description: Four-phase debugging methodology with root cause analysis. Use when investigating bugs, fixing test failures, or troubleshooting unexpected behavior. Emphasizes NO FIXES WITHOUT ROOT CAUSE FIRST.
---

# Systematic Debugging
# 系統化除錯

## Core Principle
## 核心原則

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

**沒有根本原因調查就不要修復。**

Never apply symptom-focused patches that mask underlying problems. Understand WHY something fails before attempting to fix it.

永遠不要應用只針對症狀的修補程式來掩蓋底層問題。在嘗試修復之前，先理解為什麼會失敗。

## The Four-Phase Framework
## 四階段框架

### Phase 1: Root Cause Investigation
### 第一階段：根本原因調查

Before touching any code:

在觸碰任何程式碼之前：

1. **Read error messages thoroughly** - Every word matters
1. **徹底閱讀錯誤訊息** - 每個字都很重要
2. **Reproduce the issue consistently** - If you can't reproduce it, you can't verify a fix
2. **一致地重現問題** - 如果無法重現，就無法驗證修復
3. **Examine recent changes** - What changed before this started failing?
3. **檢查最近的變更** - 在開始失敗之前發生了什麼變化？
4. **Gather diagnostic evidence** - Logs, stack traces, state dumps
4. **收集診斷證據** - 日誌、堆疊追蹤、狀態轉儲
5. **Trace data flow** - Follow the call chain to find where bad values originate
5. **追蹤資料流** - 跟隨呼叫鏈找出錯誤值的來源

**Root Cause Tracing Technique:**
**根本原因追蹤技巧：**
```
1. Observe the symptom - Where does the error manifest?
1. 觀察症狀 - 錯誤在哪裡出現？
2. Find immediate cause - Which code directly produces the error?
2. 找出直接原因 - 哪段程式碼直接產生錯誤？
3. Ask "What called this?" - Map the call chain upward
3. 問「是什麼呼叫了這個？」- 向上映射呼叫鏈
4. Keep tracing up - Follow invalid data backward through the stack
4. 繼續向上追蹤 - 通過堆疊向後追蹤無效資料
5. Find original trigger - Where did the problem actually start?
5. 找出原始觸發點 - 問題實際上從哪裡開始？
```

**Key principle:** Never fix problems solely where errors appear—always trace to the original trigger.

**關鍵原則：** 永遠不要只在錯誤出現的地方修復問題——總是追蹤到原始觸發點。

### Phase 2: Pattern Analysis
### 第二階段：模式分析

1. **Locate working examples** - Find similar code that works correctly
1. **找出正常運作的範例** - 找到運作正常的類似程式碼
2. **Compare implementations completely** - Don't just skim
2. **完整比較實作** - 不要只是略讀
3. **Identify differences** - What's different between working and broken?
3. **識別差異** - 正常和損壞的之間有什麼不同？
4. **Understand dependencies** - What does this code depend on?
4. **理解依賴關係** - 這段程式碼依賴什麼？

### Phase 3: Hypothesis and Testing
### 第三階段：假設與測試

Apply the scientific method:

應用科學方法：

1. **Formulate ONE clear hypothesis** - "The error occurs because X"
1. **制定一個清晰的假設** -「錯誤發生是因為 X」
2. **Design minimal test** - Change ONE variable at a time
2. **設計最小測試** - 一次只改變一個變數
3. **Predict the outcome** - What should happen if hypothesis is correct?
3. **預測結果** - 如果假設正確應該會發生什麼？
4. **Run the test** - Execute and observe
4. **執行測試** - 執行並觀察
5. **Verify results** - Did it behave as predicted?
5. **驗證結果** - 是否如預測般運作？
6. **Iterate or proceed** - Refine hypothesis if wrong, implement if right
6. **迭代或繼續** - 如果錯誤則改進假設，如果正確則實作

### Phase 4: Implementation
### 第四階段：實作

1. **Create failing test case** - Captures the bug behavior
1. **建立失敗的測試案例** - 捕捉錯誤行為
2. **Implement single fix** - Address root cause, not symptoms
2. **實作單一修復** - 解決根本原因，而非症狀
3. **Verify test passes** - Confirms fix works
3. **驗證測試通過** - 確認修復有效
4. **Run full test suite** - Ensure no regressions
4. **執行完整測試套件** - 確保沒有退化
5. **If fix fails, STOP** - Re-evaluate hypothesis
5. **如果修復失敗，停止** - 重新評估假設

**Critical rule:** If THREE or more fixes fail consecutively, STOP. This signals architectural problems requiring discussion, not more patches.

**關鍵規則：** 如果連續三次或更多修復失敗，請停止。這表示架構問題需要討論，而不是更多修補程式。

## Red Flags - Process Violations
## 紅旗警告 - 流程違規

Stop immediately if you catch yourself thinking:

如果你發現自己在想以下想法，請立即停止：

- "Quick fix for now, investigate later"
-「現在快速修復，稍後再調查」
- "One more fix attempt" (after multiple failures)
-「再嘗試修復一次」（在多次失敗之後）
- "This should work" (without understanding why)
-「這應該可以運作」（不理解為什麼）
- "Let me just try..." (without hypothesis)
-「讓我試試看...」（沒有假設）
- "It works on my machine" (without investigating difference)
-「在我的機器上可以運作」（不調查差異）

## Warning Signs of Deeper Problems
## 更深層問題的警告信號

**Consecutive fixes revealing new problems in different areas** indicates architectural issues:

**連續修復揭示不同領域的新問題** 表示架構問題：

- Stop patching
- 停止修補
- Document what you've found
- 記錄你發現的內容
- Discuss with team before proceeding
- 在繼續之前與團隊討論
- Consider if the design needs rethinking
- 考慮是否需要重新思考設計

## Common Debugging Scenarios
## 常見除錯場景

### Test Failures
### 測試失敗

```
1. Read the FULL error message and stack trace
1. 閱讀完整的錯誤訊息和堆疊追蹤
2. Identify which assertion failed and why
2. 識別哪個斷言失敗以及為什麼
3. Check test setup - is the test environment correct?
3. 檢查測試設置 - 測試環境是否正確？
4. Check test data - are mocks/fixtures correct?
4. 檢查測試資料 - 模擬/固定裝置是否正確？
5. Trace to the source of unexpected value
5. 追蹤到意外值的來源
```

### Runtime Errors
### 執行時期錯誤

```
1. Capture the full stack trace
1. 捕捉完整的堆疊追蹤
2. Identify the line that throws
2. 識別拋出錯誤的行
3. Check what values are undefined/null
3. 檢查哪些值是 undefined/null
4. Trace backward to find where bad value originated
4. 向後追蹤找出錯誤值的來源
5. Add validation at the source
5. 在來源處加入驗證
```

### "It worked before"
###「之前可以運作」

```
1. Use git bisect to find the breaking commit
1. 使用 git bisect 找出破壞性的提交
2. Compare the change with previous working version
2. 將變更與先前的工作版本比較
3. Identify what assumption changed
3. 識別哪個假設改變了
4. Fix at the source of the assumption violation
4. 在假設違反的來源處修復
```

### Intermittent Failures
### 間歇性失敗

```
1. Look for race conditions
1. 尋找競態條件
2. Check for shared mutable state
2. 檢查共享的可變狀態
3. Examine async operation ordering
3. 檢查非同步操作順序
4. Look for timing dependencies
4. 尋找時間依賴
5. Add deterministic waits or proper synchronization
5. 加入確定性等待或適當的同步化
```

## Debugging Checklist
## 除錯檢查清單

Before claiming a bug is fixed:

在聲稱錯誤已修復之前：

- [ ] Root cause identified and documented
- [ ] 根本原因已識別並記錄
- [ ] Hypothesis formed and tested
- [ ] 假設已形成並測試
- [ ] Fix addresses root cause, not symptoms
- [ ] 修復解決根本原因，而非症狀
- [ ] Failing test created that reproduces bug
- [ ] 建立了能重現錯誤的失敗測試
- [ ] Test now passes with fix
- [ ] 測試現在通過修復
- [ ] Full test suite passes
- [ ] 完整測試套件通過
- [ ] No "quick fix" rationalization used
- [ ] 沒有使用「快速修復」的合理化藉口
- [ ] Fix is minimal and focused
- [ ] 修復是最小且專注的

## Success Metrics
## 成功指標

Systematic debugging achieves ~95% first-time fix rate vs ~40% with ad-hoc approaches.

系統化除錯達到約 95% 的首次修復率，相對於臨時方法的約 40%。

Signs you're doing it right:
你做對了的跡象：
- Fixes don't create new bugs
- 修復不會產生新的錯誤
- You can explain WHY the bug occurred
- 你可以解釋為什麼會發生錯誤
- Similar bugs don't recur
- 類似的錯誤不會再次發生
- Code is better after the fix, not just "working"
- 修復後的程式碼更好，而不僅僅是「可運作」

## Integration with Other Skills
## 與其他技能的整合

- **testing-patterns**: Create test that reproduces the bug before fixing
- **testing-patterns**：在修復之前建立能重現錯誤的測試
