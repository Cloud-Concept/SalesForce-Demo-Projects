@isTest
/*
* Developed by Timba Software Corp. www.timbasoftware.com admin@timbasoftware.com
*/
 
/**
* Aux class to generate the items needed for code coverage tests.
* @author Bruno Fagundez
*/ 
public with sharing class BlackBerryApprovalTestUtility {
	
	/**
	* Method to generate the enviroment to run tests on empty orgs.
	*/ 
	public static testMethod void genApproval()
	{
		
		/**
		// Insert a dummy Account 
		Account acct = new Account();
		acct.Name = 'Test Method Account';
		insert acct;
		
		// Insert a dummy Contact
		Contact contact = new Contact();
		contact.AccountId = acct.id;
		contact.LastName = 'Test Method Contact';
		insert contact;
		**/
		
		//insert some leave requests
		Leave_Request__c lr = new Leave_Request__c();
		lr.From__c = Date.today();
		lr.To__c = Date.today().addDays(1);
		lr.Leave_Type__c = 'Vacation';
		lr.Notes__c = 'notes';
		
		insert lr;
		
		Leave_Request__c lr2 = new Leave_Request__c();
		lr2.From__c = Date.today();
		lr2.To__c = Date.today().addDays(1);
		lr2.Leave_Type__c = 'Vacation';
		lr2.Notes__c = 'notes';
		
		insert lr2;
		
		// Insert 2 Approval proccesses.
		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('lorem ipsum');
		req1.setObjectId(lr.Id);
		req1.setNextApproverIds(new Id[] {Userinfo.getUserId()});
		
		Approval.ProcessResult result = Approval.process(req1);
		
		Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
		req2.setComments('lorem ipsum');
		req2.setObjectId(lr2.Id);
		req2.setNextApproverIds(new Id[] {Userinfo.getUserId()});
		
		Approval.ProcessResult result2 = Approval.process(req2);
		
		List<Id> newWorkItemIds = result.getNewWorkitemIds();
		 
		BlackBerryApprovalTestUtil.workitemId = newWorkItemIds[0];
		 
	}
}