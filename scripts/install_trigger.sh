#!/bin/sh
# This script creates a record for the NPSP Trigger Handler for the LMT_Opportunity

ACTIVE=true
ASYNC=false
CLASS_NAME='LMT_OpportunityAcknowledgement_TDTM'
LOAD_ORDER=3
TRIGGER_ACTION='AfterUpdate,AfterInsert'

sf data create record --sobject npsp__Trigger_Handler__c -v "npsp__Active__c=$ACTIVE npsp__Asynchronous__c=$ASYNC npsp__Class__c='$CLASS_NAME' npsp__Load_Order__c=$LOAD_ORDER npsp__Object__c='Opportunity' npsp__Trigger_Action__c='$TRIGGER_ACTION'"