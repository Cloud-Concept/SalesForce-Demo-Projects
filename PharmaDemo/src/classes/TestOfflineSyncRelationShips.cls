@isTest
private class TestOfflineSyncRelationShips {

    static testMethod void myUnitTest() {
        //tests for the trigger that will take care of opportunitylineitems coming in with a 'null' opportunity Id
        // (which is what happens with the developer preview of the offline client)
        //to solve this I created custom fields for the relationships. This trigger will use those to match opportunity products with opportunities before they go into the db
        
        //set up an opportunity
        Opportunity opp = new Opportunity();
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.today();
        opp.Amount = 100;
        opp.Name = 'Test Opp';
        opp.OfflineId__c = 'offlineidtest__xx';
        
        insert opp;
        
        //get a pricebook id - I don't care which one
        Pricebook2 pb = [Select p.Name, p.IsStandard, p.IsActive, p.Id From Pricebook2 p where  p.IsStandard = true limit 1];
        
        //create a product
        Product2 pr = new Product2();
        pr.Name ='test product';
        pr.IsActive = true;
        insert pr;
        
        //create a pricebookentry
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = pr.Id;
        pbe.Pricebook2Id = pb.Id;
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        
        insert pbe;
        
        //now create the opportunity products with null opportunity ids
        OpportunityLineItem li = new OpportunityLineItem();
        li.OpportunityOfflineId__c = 'offlineidtest__xx';
        li.Quantity = 10;
        li.PricebookEntryId = pbe.Id;
        li.UnitPrice = 100;
        
        insert li;
    }
}