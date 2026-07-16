# Workflow DateTime Display Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the leave-request start and end date-time fields immediately display the accepted picker values.

**Architecture:** Keep the existing picker callbacks and `@State` fields as the source of truth. Remove the stale primitive `value` parameter from the reusable Builder and derive its displayed value directly from `workflowDateInput` or `workflowEndDateInput` on each render.

**Tech Stack:** HarmonyOS ArkUI, ArkTS, DevEco Studio hvigor

---

### Task 1: Bind the selector directly to reactive state

**Files:**
- Modify: `entry/src/main/ets/pages/Index.ets:1246-1274`
- Verify: `entry/src/main/ets/pages/Index.ets:1298-1299`

There is no correct unit-test seam for the system date and time dialogs in the current test suite. The regression signal is ArkTS compilation followed by a simulator interaction check that exercises the real dialog callbacks.

- [x] **Step 1: Change the Builder signature and derive the displayed value**

Replace the selector signature and its display expression with:

```typescript
@Builder
private WorkflowDateTimeSelector(label: string, isEnd: boolean) {
  const value: string = isEnd ? this.workflowEndDateInput : this.workflowDateInput;
  Column({ space: 6 }) {
    Text(label)
    // Keep the existing Text and Row styles.
    Row() {
      Text(value.length > 0 ? value : '请选择日期和时间')
        .fontColor(value.length > 0 ? '#1F2A44' : '#98A2B3')
    }
  }
}
```

Only the signature, local state selection, and existing value expressions change; retain all current layout and click-handler modifiers.

- [x] **Step 2: Update the two Builder call sites**

Use the reactive-state selector without passing primitive snapshots:

```typescript
this.WorkflowDateTimeSelector('开始时间', false)
this.WorkflowDateTimeSelector('结束时间', true)
```

- [x] **Step 3: Run static consistency checks**

Run:

```powershell
rg -n "WorkflowDateTimeSelector" entry/src/main/ets/pages/Index.ets
git diff --check
```

Expected: the definition and both calls use the two-argument signature; `git diff --check` reports no whitespace errors.

- [x] **Step 4: Compile the HarmonyOS application**

Run:

```powershell
& 'C:\Program Files\Huawei\DevEco Studio\tools\node\node.exe' `
  'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js' `
  --mode module -p product=default -p module=entry@default -p buildMode=debug assembleHap
```

Expected: `BUILD SUCCESSFUL`. Existing deprecation or signing warnings may remain, but no ArkTS compile error is allowed.

- [ ] **Step 5: Perform the simulator regression check**

Open a leave-request form, select and accept a start date and time, then select and accept a later end date and time. Expected: both fields immediately show `YYYY-MM-DD HH:mm`; an end time not later than the start time is rejected; submission still sends `开始时间 至 结束时间`.

- [ ] **Step 6: Commit the fix after simulator verification**

```powershell
git add entry/src/main/ets/pages/Index.ets docs/superpowers/plans/2026-07-17-workflow-datetime-display-fix.md
git commit -m "fix: refresh workflow datetime fields"
```
