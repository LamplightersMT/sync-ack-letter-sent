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

        switch on triggerAction {
            when AfterInsert {
                processAfterInsert(newlist, dmlWrapper);
            }
            when AfterUpdate {
                processAfterUpdate(newlist, oldlist, dmlWrapper);
            }
            when else {
                System.debug(LoggingLevel.INFO, 'Skipping processing as Trigger Action is not AfterInsert or AfterUpdate');
            }
        }

        return dmlWrapper;
    }

    private void processAfterInsert(List<SObject> newlist, npsp.TDTM_Runnable.DmlWrapper dmlWrapper) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (SObject newRecord : newlist) {
            Opportunity newOpp = (Opportunity) newRecord;
            if (newOpp.npsp__Acknowledgment_Date__c != null && 
                newOpp.Acknowledgement_Letter_Sent__c != true) {
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
    }

    private void processAfterUpdate(List<SObject> newlist, List<SObject> oldlist, 
                                    npsp.TDTM_Runnable.DmlWrapper dmlWrapper) {
        Map<Id, SObject> oldMap = new Map<Id, SObject>(oldlist);
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (SObject newRecord : newlist) {
            Opportunity newOpp = (Opportunity) newRecord;
            if (newOpp.Id == null) {
                System.debug(LoggingLevel.WARN, 'Skipping record with null Id');
                continue;
            }
            Opportunity oldOpp = (Opportunity) oldMap.get(newOpp.Id);
            if (newOpp.npsp__Acknowledgment_Date__c != null && 
                oldOpp != null && oldOpp.npsp__Acknowledgment_Date__c == null &&
                newOpp.Acknowledgement_Letter_Sent__c != true) {
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
    }
}
