global class LMT_OpportunityAcknowledgement_TDTM extends npsp.TDTM_Runnable {
    
    /**
     * Executes the TDTM logic for the Opportunity object.
     * @param newlist The list of new Opportunity records
     * @param oldlist The list of old Opportunity records
     * @param triggerAction The trigger action (BeforeInsert, AfterUpdate, etc.)
     * @param objResult The object describe result
     * @return DmlWrapper containing records to update
     */
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist, 
        npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

        System.debug(LoggingLevel.INFO, 'Trigger Action: ' + triggerAction);
        System.debug(LoggingLevel.INFO, 'Number of new records: ' + newlist.size());
        System.debug(LoggingLevel.INFO, 'Number of old records: ' + oldlist.size());

        // Only process AfterUpdate or AfterInsert actions
        if (!(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate ||
                triggerAction == npsp.TDTM_Runnable.Action.AfterInsert)) {
            System.debug(LoggingLevel.INFO, 'Skipping processing as Trigger Action is not AfterUpdate or AfterInsert');
            return dmlWrapper;
        }

        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Map<Id, SObject> oldMap = new Map<Id, SObject>(oldlist);

        for (SObject newRecord : newlist) {
            Opportunity newOpp = (Opportunity) newRecord;
            Opportunity oldOpp = (Opportunity) oldMap.get(newOpp.Id);

            System.debug(LoggingLevel.INFO, 'Processing Opportunity: ' + newOpp.Id);
            System.debug(LoggingLevel.INFO, 'New Acknowledgment Date: ' + newOpp.npsp__Acknowledgment_Date__c);
            System.debug(LoggingLevel.INFO, 'Old Acknowledgment Date: ' + oldOpp.npsp__Acknowledgment_Date__c);

            // Check if Acknowledgment_Date__c was populated and Letter_Sent__c is not already true
            if (newOpp.npsp__Acknowledgment_Date__c != null && 
                oldOpp.npsp__Acknowledgment_Date__c == null &&
                newOpp.Acknowledgement_Letter_Sent__c != true) {
                System.debug(LoggingLevel.INFO, 'Acknowledgment Date populated and Letter Sent is false. Adding to update list.');
                Opportunity oppToUpdate = new Opportunity(
                    Id = newOpp.Id,
                    Acknowledgement_Letter_Sent__c = true
                );
                opportunitiesToUpdate.add(oppToUpdate);
            }
        }

        if (!opportunitiesToUpdate.isEmpty()) {
            System.debug(LoggingLevel.INFO, 'Number of Opportunities to update: ' + opportunitiesToUpdate.size());
            dmlWrapper.objectsToUpdate.addAll(opportunitiesToUpdate);
        } else {
            System.debug(LoggingLevel.INFO, 'No Opportunities to update.');
        }

        return dmlWrapper;
    }
}
