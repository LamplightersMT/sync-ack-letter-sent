@isTest
public class LMT_OpportunityAcknowledgement_TDTMTest {
    /**
     * Test method for LMT_OpportunityAcknowledgementTDTM.
     */
    @isTest
    static void testRun() {
        // Arrange
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            Amount = 100.00,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            npsp__Acknowledgment_Date__c = null,
            Acknowledgement_Letter_Sent__c = false
        );
        insert testOpportunity;

        // Update to set acknowledgment date (simulating the trigger scenario)
        testOpportunity.npsp__Acknowledgment_Date__c = Date.today();
        
        List<SObject> newList = new List<SObject>{ testOpportunity };
        List<SObject> oldList = new List<SObject>{ 
            new Opportunity(
                Id = testOpportunity.Id,
                npsp__Acknowledgment_Date__c = null,
                Acknowledgement_Letter_Sent__c = false
            )
        };

        // Act
        LMT_OpportunityAcknowledgement_TDTM handler = new LMT_OpportunityAcknowledgement_TDTM();
        npsp.TDTM_Runnable.DmlWrapper result = handler.run(
            newList, 
            oldList, 
            npsp.TDTM_Runnable.Action.AfterUpdate, 
            Opportunity.sObjectType.getDescribe()
        );

        // Assert
        Assert.isNotNull(result, 'DmlWrapper should not be null');
        Assert.areEqual(1, result.objectsToUpdate.size(), 'Should have 1 opportunity to update');

        Opportunity oppToUpdate = (Opportunity)result.objectsToUpdate[0];
        Assert.areEqual(testOpportunity.Id, oppToUpdate.Id, 'Should update the correct opportunity');
        Assert.areEqual(true, oppToUpdate.Acknowledgement_Letter_Sent__c, 'Acknowledgement_Letter_Sent__c should be set to true');
    }
    
    @isTest
    static void testAfterInsert_WithAcknowledgmentDate() {
        // Arrange
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            npsp__Acknowledgment_Date__c = Date.today(),
            Acknowledgement_Letter_Sent__c = false
        );

        List<SObject> newList = new List<SObject>{ opp };
        List<SObject> oldList = new List<SObject>(); // Empty for AfterInsert

        // Act
        LMT_OpportunityAcknowledgement_TDTM handler = new LMT_OpportunityAcknowledgement_TDTM();
        npsp.TDTM_Runnable.DmlWrapper result = handler.run(
            newList, 
            oldList, 
            npsp.TDTM_Runnable.Action.AfterInsert, 
            Opportunity.sObjectType.getDescribe()
        );

        // Assert
        Assert.isNotNull(result, 'DmlWrapper should not be null');
        Assert.areEqual(1, result.objectsToUpdate.size(), 
            'Expected: 1, Actual: ' + result.objectsToUpdate.size() + ' - Should have 1 opportunity to update');

        Opportunity oppToUpdate = (Opportunity)result.objectsToUpdate[0];
        Assert.areEqual(true, oppToUpdate.Acknowledgement_Letter_Sent__c, 
            'Expected: true, Actual: ' + oppToUpdate.Acknowledgement_Letter_Sent__c + 
            ' - Acknowledgement_Letter_Sent__c should be set to true');
    }

    @isTest
    static void testAfterInsert_WithoutAcknowledgmentDate() {
        // Arrange
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            Acknowledgement_Letter_Sent__c = false
        );

        List<SObject> newList = new List<SObject>{ opp };
        List<SObject> oldList = new List<SObject>(); // Empty for AfterInsert

        // Act
        LMT_OpportunityAcknowledgement_TDTM handler = new LMT_OpportunityAcknowledgement_TDTM();
        npsp.TDTM_Runnable.DmlWrapper result = handler.run(
            newList, 
            oldList, 
            npsp.TDTM_Runnable.Action.AfterInsert, 
            Opportunity.sObjectType.getDescribe()
        );

        // Assert
        Assert.isNotNull(result, 'DmlWrapper should not be null');
        Assert.areEqual(0, result.objectsToUpdate.size(), 
            'Expected: 0, Actual: ' + result.objectsToUpdate.size() + 
            ' - Should have no opportunities to update');
    }

    @isTest
    static void testAfterInsert_LetterAlreadySent() {
        // Arrange
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            npsp__Acknowledgment_Date__c = Date.today(),
            Acknowledgement_Letter_Sent__c = true
        );

        List<SObject> newList = new List<SObject>{ opp };
        List<SObject> oldList = new List<SObject>(); // Empty for AfterInsert

        // Act
        LMT_OpportunityAcknowledgement_TDTM handler = new LMT_OpportunityAcknowledgement_TDTM();
        npsp.TDTM_Runnable.DmlWrapper result = handler.run(
            newList, 
            oldList, 
            npsp.TDTM_Runnable.Action.AfterInsert, 
            Opportunity.sObjectType.getDescribe()
        );

        // Assert
        Assert.isNotNull(result, 'DmlWrapper should not be null');
        Assert.areEqual(0, result.objectsToUpdate.size(), 
            'Expected: 0, Actual: ' + result.objectsToUpdate.size() + 
            ' - Should have no opportunities to update when letter already sent');
    }

    @isTest
    static void testAfterUpdate_FieldChange() {
        // Arrange
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            Amount = 100.00,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            npsp__Acknowledgment_Date__c = null,
            Acknowledgement_Letter_Sent__c = false
        );
        insert testOpportunity; // Insert to get valid Id

        // Create old opportunity state (before acknowledgment date set)
        Opportunity oldOpportunity = new Opportunity(
            Id = testOpportunity.Id,
            npsp__Acknowledgment_Date__c = null,
            Acknowledgement_Letter_Sent__c = false
        );

        // Update to set acknowledgment date (simulating the trigger scenario)
        testOpportunity.npsp__Acknowledgment_Date__c = Date.today();
        
        List<SObject> newList = new List<SObject>{ testOpportunity };
        List<SObject> oldList = new List<SObject>{ oldOpportunity };

        // Act
        LMT_OpportunityAcknowledgement_TDTM handler = new LMT_OpportunityAcknowledgement_TDTM();
        npsp.TDTM_Runnable.DmlWrapper result = handler.run(
            newList, 
            oldList, 
            npsp.TDTM_Runnable.Action.AfterUpdate, 
            Opportunity.sObjectType.getDescribe()
        );

        // Assert
        Assert.isNotNull(result, 'DmlWrapper should not be null');
        Assert.areEqual(1, result.objectsToUpdate.size(), 
            'Expected: 1, Actual: ' + result.objectsToUpdate.size() + ' - Should have 1 opportunity to update');

        Opportunity oppToUpdate = (Opportunity)result.objectsToUpdate[0];
        Assert.areEqual(true, oppToUpdate.Acknowledgement_Letter_Sent__c, 
            'Expected: true, Actual: ' + oppToUpdate.Acknowledgement_Letter_Sent__c + 
            ' - Acknowledgement_Letter_Sent__c should be set to true');
    }

    @isTest
    static void testAfterUpdate_NoFieldChange() {
        // Arrange
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            Amount = 100.00,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            npsp__Acknowledgment_Date__c = Date.today(),
            Acknowledgement_Letter_Sent__c = false
        );
        insert testOpportunity; // Insert to get valid Id

        // Create old opportunity state (same acknowledgment date)
        Opportunity oldOpportunity = new Opportunity(
            Id = testOpportunity.Id,
            Name = 'Test Opportunity',
            npsp__Acknowledgment_Date__c = Date.today(),
            Acknowledgement_Letter_Sent__c = false
        );

        // Update name only, acknowledgment date unchanged
        testOpportunity.Name = 'Updated Test Opportunity';
        
        List<SObject> newList = new List<SObject>{ testOpportunity };
        List<SObject> oldList = new List<SObject>{ oldOpportunity };

        // Act
        LMT_OpportunityAcknowledgement_TDTM handler = new LMT_OpportunityAcknowledgement_TDTM();
        npsp.TDTM_Runnable.DmlWrapper result = handler.run(
            newList, 
            oldList, 
            npsp.TDTM_Runnable.Action.AfterUpdate, 
            Opportunity.sObjectType.getDescribe()
        );

        // Assert
        Assert.isNotNull(result, 'DmlWrapper should not be null');
        Assert.areEqual(0, result.objectsToUpdate.size(), 
            'Expected: 0, Actual: ' + result.objectsToUpdate.size() + 
            ' - Should have no opportunities to update when acknowledgment date unchanged');
    }
}
