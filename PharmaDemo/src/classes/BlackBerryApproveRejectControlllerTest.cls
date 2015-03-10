/*
* Developed by Timba Software Corp. www.timbasoftware.com admin@timbasoftware.com
*/
 
/**
* Test Class to cover code from BlackBerryApproveRejectController 
* @author Bruno Fagundez
*/ 
@IsTest private class BlackBerryApproveRejectControlllerTest {
	
	/**
	* Constructor
	*/ 
	public static testMethod void BlackBerryApproveRejectControlllerTest() {
		
		// Populate Approval objs
		BlackBerryApprovalTestUtility.genApproval();
        Test.startTest();
        
        System.currentPageReference().getParameters().put('id', BlackBerryApprovalTestUtil.workItemId);
        BlackBerryApproveRejectController bbar = new BlackBerryApproveRejectController();
         System.currentPageReference().getHeaders().put('USER-AGENT', 'ipad');
        bbar.redirectDesktops();
        
        System.currentPageReference().getHeaders().put('USER-AGENT', 'windows');
        bbar.redirectDesktops();
        bbar.getWORKITEM_ID();
        bbar.getCurrentStep();
        bbar.getObjDetail();
        bbar.getProcHistory();
        bbar.getDetailFields(BlackBerryApprovalTestUtil.workItemId);
        
       
        
        Test.stopTest();
        
	}
}