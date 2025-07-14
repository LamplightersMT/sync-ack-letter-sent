# Critical Deployment Fixes Plan

## Overview
The current deployment is failing with 4 critical errors that prevent basic functionality. This plan addresses each error with specific fixes and validates the solutions.

## Current Deployment Errors

### Error 1: Invalid type: `npsp.DmlWrapper` (Line 11:37)
**Problem:** The return type `npsp.DmlWrapper` is not recognized in the current NPSP version.
**Root Cause:** Based on research documentation, the correct return type should be `TDTM_Runnable.DmlWrapper` or just `DmlWrapper` (without npsp namespace prefix).

### Error 2: Abstract method signature mismatch (Line 133:32) 
**Problem:** Method signature doesn't match the required abstract method from `npsp.TDTM_Runnable`.
**Root Cause:** The method signature in our implementation doesn't exactly match what the abstract class expects.

### Error 3: Field does not exist: `npsp__Acknowledgement_Date__c` (Line 9:39)
**Problem:** The field `npsp__Acknowledgement_Date__c` doesn't exist in the target org's Opportunity object.
**Root Cause:** The field name is incorrect. The corret name is: npsp__Acknowledgment_Date__c

### Error 4: Method signature mismatch in test (Line 20:17)
**Problem:** Test is calling `handler.run(scope)` with wrong parameters.
**Root Cause:** Test is calling the method with only 1 parameter instead of the required 4 parameters.

---

## Phase 1: Critical Handler Class Fixes

### Fix 1.1: Research Correct NPSP TDTM Method Signature
**Priority:** CRITICAL
**Duration:** 15 minutes

**Actions:**
1. **Investigate NPSP TDTM Documentation:**
   - Review existing NPSP TDTM handlers in the org
   - Check the exact method signature required by `npsp.TDTM_Runnable`
   - Verify the correct return type (`DmlWrapper` vs `npsp.DmlWrapper` vs `TDTM_Runnable.DmlWrapper`)

2. **Query Org for Method Signature:**
   ```bash
   # Use Developer Console or SOQL to inspect existing TDTM handlers
   # Look at Setup > Apex Classes > existing NPSP TDTM handlers
   ```

3. **Update Method Signature:**
   - Correct the return type based on findings
   - Ensure parameter types match exactly
   - Update method declaration to match abstract class requirements

### Fix 1.2: Update Field Names to Correct Spelling
**Priority:** CRITICAL  
**Duration:** 5 minutes
**STATUS:** ✅ COMPLETED

**Actions:**
1. **Update Field Reference in Handler Class:** ✅ DONE
   - Change `npsp__Acknowledgement_Date__c` to `npsp__Acknowledgment_Date__c` (missing 'e' in "Acknowledgment")
   - This is a simple spelling correction - the field exists but uses the shorter spelling

2. **Verify Other Field Names:** ✅ DONE
   - Confirm `Acknowledgement_Letter_Sent__c` field name spelling (with 'e')
   - Ensure consistency between NPSP field (without 'e') and custom field (with 'e')

3. **Update All References:** ✅ DONE
   - Replace field name in both handler class and test class
   - Ensure all comments and documentation use correct spelling

### Fix 1.3: Correct DmlWrapper Usage
**Priority:** CRITICAL
**Duration:** 5 minutes

**Actions:**
1. **Fix Return Type:**
   - Update method signature to use correct return type
   - Ensure DmlWrapper instantiation matches the correct class

2. **Fix DmlWrapper Population:**
   - Verify correct property name (`objectsToUpdate` vs `objectsToUpdate` vs other)
   - Ensure proper list handling in DmlWrapper

---

## Phase 2: Test Class Fixes

### Fix 2.1: Correct Test Method Signature
**Priority:** HIGH
**Duration:** 10 minutes

**Actions:**
1. **Update Test Method Call:**
   - Change from `handler.run(scope)` to proper 4-parameter method
   - Provide correct parameter values:
     - `newlist`: List of new records
     - `oldlist`: List of old records (for update scenarios)
     - `triggerAction`: `npsp.TDTM_Runnable.Action.AfterUpdate`
     - `objResult`: `Opportunity.sObjectType.getDescribe()`

2. **Implement Proper NPSP Testing Pattern:**
   - Use `Test.startTest()` and `Test.stopTest()`
   - Create proper old/new record scenarios
   - Test actual trigger simulation instead of direct method calls

### Fix 2.2: Fix Field References in Test
**Priority:** HIGH
**Duration:** 3 minutes
**STATUS:** ✅ COMPLETED

**Actions:**
1. **Update Field Names:** ✅ DONE
   - Change `npsp__Acknowledgement_Date__c` to `npsp__Acknowledgment_Date__c` (remove 'e' to match NPSP spelling)
   - Ensure test data creation uses correct field spelling

2. **Add Required Fields:** ⏳ PENDING
   - Include mandatory Opportunity fields (Amount, StageName, CloseDate)
   - Ensure test data is valid for insertion

---

## Phase 3: Validation and Testing

### Fix 3.1: Incremental Deployment Testing
**Priority:** HIGH
**Duration:** 20 minutes

**Actions:**
1. **Deploy Handler Class Only:**
   ```bash
   sf project deploy start --source-dir force-app/main/default/classes/LMT_OpportunityAcknowledgement_TDTM.cls
   ```

2. **Deploy Test Class Separately:**
   ```bash
   sf project deploy start --source-dir force-app/main/default/classes/LMT_OpportunityAcknowledgement_TDTMTest.cls
   ```

3. **Run Basic Test:**
   ```bash
   sf apex run test --tests LMT_OpportunityAcknowledgement_TDTMTest --result-format human --synchronous
   ```

### Fix 3.2: Integration Testing
**Priority:** MEDIUM
**Duration:** 15 minutes

**Actions:**
1. **Test Handler via Anonymous Apex:**
   - Create test opportunity records
   - Simulate trigger conditions
   - Verify handler behavior

2. **Validate Field Updates:**
   - Confirm acknowledgement date changes trigger the handler
   - Verify letter sent field is updated correctly

---

## Phase 4: Plan Updates

### Fix 4.1: Update Project Plan Status
**Priority:** LOW
**Duration:** 5 minutes

**Actions:**
1. **Update Deliverable Status:**
   - Mark Deliverable 3 as "In Progress - Fixing Critical Deployment Issues"
   - Update Current Implementation Status section
   - Add lessons learned about NPSP framework specifics

2. **Document Resolution Steps:**
   - Record actual field names found in org
   - Document correct NPSP TDTM method signatures
   - Update technical considerations with accurate information

---

## Success Criteria

### Phase 1 Complete When:
- [ ] Handler class deploys without errors
- [x] Field name corrected from `npsp__Acknowledgement_Date__c` to `npsp__Acknowledgment_Date__c`
- [ ] Proper NPSP TDTM method signature confirmed

### Phase 2 Complete When:
- [ ] Test class deploys without errors
- [ ] Test method uses correct 4-parameter signature
- [x] Test data uses correct field spelling (`npsp__Acknowledgment_Date__c`)

### Phase 3 Complete When:
- [ ] Both classes deploy successfully via manifest
- [ ] Basic test passes
- [ ] Handler functionality validated

### Phase 4 Complete When:
- [ ] Plan updated with current status
- [ ] Lessons learned documented
- [ ] Ready to proceed with enhanced testing (Deliverable 5)

---

## Immediate Next Steps

1. **Start with Fix 1.1** - Research correct NPSP method signature (highest impact)
2. ~~**Apply Fix 1.2** - Correct field name spelling (quick fix: `npsp__Acknowledgement_Date__c` → `npsp__Acknowledgment_Date__c`)~~ ✅ COMPLETED
3. **Apply Fix 1.3** - Correct DmlWrapper usage
4. **Test incremental deployment** after each fix
5. **Move to test class fixes** once handler deploys successfully

## Current Deployment Status (Latest attempt):
❌ **3 errors still blocking deployment:**
- Error 1: Invalid type: `npsp.DmlWrapper` (Line 11:37) - **UNCHANGED**
- Error 2: Abstract method signature mismatch (Line 133:32) - **UNCHANGED** 
- Error 4: Test method signature mismatch (Line 20:17) - **UNCHANGED**

✅ **1 error RESOLVED:**
- Error 3: Field name spelling corrected to `npsp__Acknowledgment_Date__c` - **FIXED**

## Estimated Total Time: 63 minutes (reduced due to field name being a simple spelling correction)

This plan prioritizes the most critical blocking issues first and provides incremental validation to prevent introducing new errors while fixing existing ones.
