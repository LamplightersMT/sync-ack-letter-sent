# NPSP TDTM Framework Research - Deliverable 1

## Overview
This document summarizes the research findings for the NPSP TDTM (Table-Driven Trigger Management) framework requirements for implementing an Opportunity acknowledgement date handler.

## TDTM Base Classes

### TDTM_Runnable (Abstract Base Class)
- **Primary interface** for TDTM handlers
- **Method signature:** `public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)`
- **Returns:** `DmlWrapper` object containing records for DML operations
- **Usage:** Most common pattern for TDTM handlers

### TDTM_RunnableMutable (Alternative Interface)
- **Alternative interface** that allows direct mutation of the global DmlWrapper
- **Method signature:** `public override void run(List<SObject> newlist, List<SObject> oldlist, TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult, TDTM_Runnable.DmlWrapper dmlWrapper)`
- **Returns:** `void` (modifies dmlWrapper by reference)
- **Usage:** When you need to directly modify the global DML collection

## Implementation Patterns from NPSP Examples

### 1. Opportunity Handler Examples
From `PMT_Payment_TDTM.cls`:
```apex
public class PMT_Payment_TDTM extends TDTM_Runnable {
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
            TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        DmlWrapper dmlWrapper = new DmlWrapper();
        
        if (objResult.getsObjectType() == Opportunity.sObjectType) {
            dmlWrapper = runForOpportunities(newlist, oldlist, triggerAction);
        }
        
        return dmlWrapper;
    }
}
```

### 2. Field Change Detection Pattern
From various NPSP handlers, common pattern for detecting field changes:
```apex
for (integer i = 0; i < newlist.size(); i++) {
    Opportunity opp = (Opportunity)newlist[i];
    Opportunity oppOld = (Opportunity)oldlist[i];
    
    // Check for field changes
    if (opp.SomeField__c != oppOld.SomeField__c) {
        // Handle the change
    }
}
```

### 3. Trigger Action Filtering
Most handlers filter by specific trigger actions:
```apex
if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
    // Handle after update logic
}
```

## Registration Requirements

### Trigger_Handler__c Record Configuration
Based on NPSP's `TDTM_DefaultConfig.cls`, handlers are registered via Trigger_Handler__c records:

```apex
handlers.add(new Trigger_Handler__c(
    Active__c = true, 
    Asynchronous__c = false,
    Class__c = 'LMT_OpportunityAcknowledgementTDTM', 
    Load_Order__c = 1, 
    Object__c = 'Opportunity',
    Trigger_Action__c = 'AfterUpdate'
));
```

### Required Fields:
- **Active__c:** `true` to enable the handler
- **Asynchronous__c:** `false` for synchronous execution (recommended for field updates)
- **Class__c:** The fully qualified class name
- **Load_Order__c:** Execution order (lower numbers run first)
- **Object__c:** The SObject type (`'Opportunity'`)
- **Trigger_Action__c:** Trigger events (`'AfterUpdate'` for our use case)

## Framework Dependencies

### Required Imports/References
- `TDTM_Runnable` - Base class to extend
- `TDTM_Runnable.Action` - Enum for trigger actions
- `TDTM_Runnable.DmlWrapper` - For DML operations
- `Schema.DescribeSObjectResult` - Object metadata

### NPSP Utility Classes (Available)
- `UTIL_Debug` - For debugging and logging
- `TDTM_ProcessControl` - For recursion control
- `ERR_ExceptionHandler` - For error handling

## Recommended Implementation Approach

### For LMT_OpportunityAcknowledgementTDTM:

1. **Extend TDTM_Runnable** (not TDTM_RunnableMutable) since we're doing simple field updates
2. **Filter for AfterUpdate** trigger action only
3. **Check for field changes** between `newlist` and `oldlist`
4. **Return DmlWrapper** with updated Opportunity records
5. **Use proper recursion control** if needed

### Template Structure:
```apex
public class LMT_OpportunityAcknowledgementTDTM extends TDTM_Runnable {
    
    public override DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
            TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        
        DmlWrapper dmlWrapper = new DmlWrapper();
        
        if (triggerAction == TDTM_Runnable.Action.AfterUpdate) {
            // Process acknowledgement date changes
            processAcknowledgementDateChanges(newlist, oldlist, dmlWrapper);
        }
        
        return dmlWrapper;
    }
    
    private void processAcknowledgementDateChanges(List<SObject> newlist, List<SObject> oldlist, DmlWrapper dmlWrapper) {
        // Implementation logic here
    }
}
```

## Testing Framework Requirements

### NPSP Testing Patterns:
- Use `UTIL_UnitTestData_TEST` for test data creation
- Use `TDTM_Config_API.getCachedRecords()` for trigger handler management
- Follow `@TestSetup`, `Test.startTest()`, and `Test.stopTest()` patterns
- Test bulk operations (200+ records) following NPSP performance patterns

## Next Steps
With this research complete, we can proceed to Deliverable 2: Update package manifest for new components.
