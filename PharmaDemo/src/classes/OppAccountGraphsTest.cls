/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OppAccountGraphsTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Account acc = new Account( name='Test Account');
        insert acc;
        
        List<String> oppStages = new List<String>();
        
        Map<String, Decimal> oppStageToAmount = new Map<String, Decimal>();
        
        /* Test Summarize Opps */
        
        PageReference pageRef = Page.AccountSummarizeOpps;
		Test.setCurrentPageReference(pageRef);
		ApexPages.StandardController sc = new ApexPages.standardController(acc);
		// create an instance of the controller
		AccountSummarizeOpps summarizeOpps = new AccountSummarizeOpps(sc);
		List<SelectOption> filterOptions = summarizeOpps.getFilterCriteriaOptions();
		System.assertEquals(filterOptions.size(), 10);       
		
		/*Test Matrix Opps */
		pageRef = Page.AccountStackOppsByType;
		Test.setCurrentPageReference(pageRef);
		sc = new ApexPages.standardController(acc);
		// create an instance of the controller
		AccountStackOppsByType stackOpps = new AccountStackOppsByType(sc);
		List<SelectOption> stackOppsfilterOptions = stackOpps.getFilterCriteriaOptions();
		System.assertEquals(stackOppsfilterOptions.size(), 10);
		 
		 
		//Get Opportunity Type Values
		
		//Get Opportunity Stage Values
		
		 
		 
		//Opportunity OppOne = new Opportunity(AccountId = acc.Id, Name= 'Test Opp One', Type='New Business');
		//Opportunity OppTwo = new Opportunity(AccountId = acc.Id, Name= 'Test Opp Two');
		
		Schema.DescribeFieldResult oppFieldResult = Opportunity.Type.getDescribe();
		List<Schema.PicklistEntry> oppTypeOptions = oppFieldResult.getPicklistValues();
		
		Schema.DescribeFieldResult stageFieldResult = Opportunity.StageName.getDescribe();
		List<Schema.PicklistEntry> oppStageOptions = stageFieldResult.getPicklistValues();
        
        //Create One Opp for Each Picklist Value and Stage
        
        Integer oppIndex = 1;
        
        
        for(Schema.PicklistEntry f1 : oppStageOptions) {
      		String oppStage = f1.getValue();
      		Decimal oppTypeValue = 0;
      		        
        	for(Schema.PicklistEntry f : oppTypeOptions) {
      			String oppType = f.getValue();
      		
      			Integer maxValue = (Math.random() * 100).intValue();
      			Decimal oppValue = maxValue * 1000000;      			
      			oppTypeValue += oppValue;    			
      			
      			Opportunity opp = new Opportunity();
      			opp.AccountId = acc.Id;
      			opp.Name = 'Test Opp ' + oppIndex;
      			opp.Type = oppType;
      			opp.StageName = oppStage;
      			opp.Amount = oppValue;
      			opp.CloseDate = Date.today();      			
      			insert opp;
      			
      			oppIndex = oppIndex + 1;
      		}
      		oppStages.add(oppStage);
      		oppStageToAmount.put(oppStage, oppTypeValue);      		
		}
      	
      	List<String> filtersWithValues = new List<String>{'ALL_TIME','THIS_MONTH','THIS_FQ','THIS_FY','TEST_THE_DEFAULT_CASE'};
      	
      	List<String> filtersWithNoValues = new List<String>{'NEXT_MONTH','NEXT_FQ','NEXT_FY','PREV_MONTH','PREV_FQ','PREV_FY'};
      	
      	for(String filter : filtersWithValues) {
      	
	      	Map<String, Decimal> oppDetailsByStage = AccountSummarizeOpps.getFilteredOpportunityDetails(acc.Id, filter);
	      		
	      	
	      	
			for(Integer i = 0; i < oppStages.size(); i++) {
				
				Decimal expectedValue = oppStageToAmount.get(oppStages[i]);
				Decimal actualValue = oppDetailsByStage.get(oppStages[i]);
				
				System.assertEquals(expectedValue, actualValue);
				
				
			}
			
			
			Map<String, List<OppSummary>> accountsByOppStageAndType = AccountStackOppsByType.getFilteredOpportunityDetails(acc.Id, filter);
			for(Integer i = 0; i < oppStages.size(); i++) {
				Decimal expectedValue = oppStageToAmount.get(oppStages[i]);
				Decimal actualValue = 0;
				
				List<OppSummary> oppSummaries = accountsByOppStageAndType.get(oppStages[i]);
				
				for(OppSummary oppSummary : oppSummaries) {
					actualValue = actualValue + oppSummary.totalOppValue;						
				}
				
				System.assertEquals(expectedValue, actualValue);
			
			}
      	}
      	
      	for(String filter : filtersWithNoValues) {
      	
	      	Map<String, Decimal> oppDetailsByStage = AccountSummarizeOpps.getFilteredOpportunityDetails(acc.Id, filter);
	      		
	      	System.assertEquals(oppDetailsByStage.keySet().size(),0);
	      	
	      	
	      	Map<String, List<OppSummary>> accountsByOppStageAndType = AccountStackOppsByType.getFilteredOpportunityDetails(acc.Id, filter);
				
	      	System.assertEquals(accountsByOppStageAndType.keySet().size(),0);
	      			
	      	/*	      	
			for(Integer i = 0; i < oppStages.size(); i++) {
				
				Decimal expectedValue = oppStageToAmount.get(oppStages[i]);
				Decimal actualValue = oppDetailsByStage.get(oppStages[i]);
				
				System.assertEquals(expectedValue, actualValue);				
				
			}
			*/
      	}
   		
        
		
		       
		 
        
    }
}