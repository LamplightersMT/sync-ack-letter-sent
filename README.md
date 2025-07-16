# Salesforce Opportunity Acknowledgement TDTM Handler

This project implements an automated donation acknowledgement system using the Salesforce Nonprofit Success Pack (NPSP) Table-Driven Trigger Management (TDTM) framework. When an opportunity's acknowledgement date is populated, the system automatically sets the acknowledgement letter sent flag to true.

## 🎯 Project Overview

The system monitors changes to the `npsp__Acknowledgment_Date__c` field on Opportunity objects and automatically updates the `Acknowledgement_Letter_Sent__c` custom field when an acknowledgement date is populated. 

This obviously won't work unless you have the same custom field in your SF org, but I'm making this repo public for reference.

## 🏗️ Architecture

### Core Components

- **LMT_OpportunityAcknowledgement_TDTM.cls**: Main handler class extending `npsp.TDTM_Runnable`
- **LMT_OpportunityAcknowledgement_TDTMTest.cls**: Comprehensive test class with 100% pass rate
- **scripts/install_trigger.sh**: Automated TDTM registration script
- **scripts/soql/**: Database management queries for TDTM configuration

### Technical Details

- **Framework**: NPSP TDTM (Table-Driven Trigger Management)
- **Trigger Action**: AfterUpdate, AfterInsert on Opportunity object
- **Field Dependencies**: 
  - `npsp__Acknowledgment_Date__c` (NPSP standard field)
  - `Acknowledgement_Letter_Sent__c` (custom field)

## 🚀 Quick Start

### Prerequisites

1. Salesforce org with NPSP package installed
2. Salesforce CLI (`sf`) configured and authenticated
3. Custom field `Acknowledgement_Letter_Sent__c` exists on Opportunity object

### Installation

1. **Deploy the classes**:
   ```bash
   sf project deploy start -x manifest/package.xml
   ```

2. **Register the TDTM handler**:
   ```bash
   ./scripts/install_trigger.sh
   ```

3. **Verify installation**:
   ```bash
   sf apex run test --tests LMT_OpportunityAcknowledgement_TDTMTest --result-format human --synchronous
   ```

## 📋 How It Works

1. **Trigger Detection**: Handler monitors `AfterUpdate` events on Opportunity records
2. **Field Change Detection**: Identifies when `npsp__Acknowledgment_Date__c` changes from null to a date value
3. **Automatic Update**: Sets `Acknowledgement_Letter_Sent__c` to `true` for qualifying opportunities
4. **Bulk Processing**: Efficiently handles multiple records in a single transaction

## 🔧 Configuration

### TDTM Handler Registration

The handler is registered in the NPSP framework with these settings:

- **Active**: `true`
- **Asynchronous**: `false` (synchronous execution)
- **Object**: `Opportunity`
- **Trigger Action**: `AfterUpdate`
- **Load Order**: `3`

## Trigger Action Support

This project now supports the following trigger actions:
- AfterInsert
- AfterUpdate

### Installation Instructions

To register the trigger actions, run the `install_trigger.sh` script. Ensure that the `TRIGGER_ACTION` variable includes both `AfterInsert` and `AfterUpdate`.

## 🧪 Testing

### Run Tests

```bash
# Run the test class
sf apex run test --tests LMT_OpportunityAcknowledgement_TDTMTest --result-format human --synchronous

# Deploy and test together
sf project deploy start -x manifest/package.xml --test-level RunSpecifiedTests --tests LMT_OpportunityAcknowledgement_TDTMTest
```

### Test Coverage

- **Pass Rate**: 100%
- **Test Scenarios**: Field change detection, bulk operations, edge cases
- **TDTM Integration**: Proper 4-parameter method signature testing

## 🐛 Debugging

### Enable Debug Logs

```bash
sf apex log tail --debug-level SFDC_DevConsole
```

The handler includes comprehensive logging that traces:
- Trigger action types
- Record counts (new/old)
- Field value changes
- Update decisions
- Performance metrics

### Verify TDTM Registration

```bash
sf data query -f scripts/soql/select_tdtm_class.soql
```

## 📚 Development Resources

- [NPSP TDTM Documentation](https://help.salesforce.com/s/articleView?id=sfdo.npsp_deploy_apex_tdtm.htm&type=5)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [NPSP Developer Guide](https://powerofus.force.com/s/article/NPSP-Developer-Guide)