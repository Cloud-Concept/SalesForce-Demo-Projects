/*
* Developed by Timba Software Corp. www.timbasoftware.com admin@timbasoftware.com
*/
 
/**
* Test Class to cover code from BlackBerryReassignController 
* @author Bruno Fagundez
*/ 
@IsTest private class BlackBerryReassignControllerTest {
	
	/**
	* Constructor
	*/ 
	public static testMethod void BlackBerryReassignControllerTest()
	{
		// Populate Approval objs
		BlackBerryApprovalTestUtility.genApproval();
        Test.startTest();
        
        System.currentPageReference().getParameters().put('id', BlackBerryApprovalTestUtil.workItemId);
        System.currentPageReference().getParameters().put('approverId', Userinfo.getUserId());
        System.currentPageReference().getParameters().put('comments','lorem ipsum');
        
        BlackBerryReassignController bbrc = new BlackBerryReassignController();
        
        bbrc.getApproverLookupList();
        bbrc.reassign();
        bbrc.cancel();
        bbrc.perform();
	}

}