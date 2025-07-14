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
}
