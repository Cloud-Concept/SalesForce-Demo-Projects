/*
* Developed by Timba Software Corp. www.timbasoftware.com admin@timbasoftware.com
*/
 
/**
* Test Class to cover code from BlackBerryApprovalListController 
* @author Bruno Fagundez
*/ 
@IsTest private class BlackBerryApprovalListControllerTest
{	
	/**
	* Constructor
	*/ 
	public static testMethod void BlackBerryApprovalListControllerTest() 
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		
		User manager = new User(Alias = 'mgr', Email='mgr@testorg.com', 
	      EmailEncodingKey='UTF-8', LastName='mgr', LanguageLocaleKey='en_US', 
	      LocaleSidKey='en_US', ProfileId = p.Id, 
	      TimeZoneSidKey='America/Los_Angeles', UserName='mgr@testorg.com');
	      
	      insert manager;
		
	      User employee = new User(Alias = 'emp', Email='emp@testorg.com', 
	      EmailEncodingKey='UTF-8', LastName='emp', LanguageLocaleKey='en_US', 
	      LocaleSidKey='en_US', ProfileId = p.Id, 
	      TimeZoneSidKey='America/Los_Angeles', UserName='emp@testorg.com', ManagerId=manager.Id);

		insert employee;

      System.runAs(employee) {
      	// Populate Approval objs
		BlackBerryApprovalTestUtility.genApproval();
		
      	Leave_Request__c lr2 = new Leave_Request__c();
		lr2.From__c = Date.today();
		lr2.To__c = Date.today().addDays(1);
		lr2.Approval_Status__c = 'Pending';
		
		insert lr2;
		
		Approval.ProcessSubmitRequest areq = new Approval.ProcessSubmitRequest();
        areq.setComments('Submitted for approval. Please approve.');
        areq.setObjectId(lr2.Id);
        // submit the approval request for processing
        Approval.ProcessResult result = Approval.process(areq);
      }
		

		
		
		

		
        Test.startTest();
        
        // Instantiate and call class methods
        System.runAs(manager) {
        	BlackBerryApprovalListController bbal = new BlackBerryApprovalListController();
			bbal.getApprovalItemsCollection();   
			bbal.getNoRecordsToShow();
        }
		
		Test.stopTest();
	}
}