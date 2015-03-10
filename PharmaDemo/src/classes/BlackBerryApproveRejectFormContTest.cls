/*
* Developed by Timba Software Corp. www.timbasoftware.com admin@timbasoftware.com
*/
 
/**
* Test Class to cover code from BlackBerryApproveRejectFormController 
* @author Bruno Fagundez
*/
@IsTest private class BlackBerryApproveRejectFormContTest
{	
	/**
	* Constructor
	*/ 
	public static testMethod void BlackBerryApproveRejectFormContTest()
	{
		// Populate Approval objs
		BlackBerryApprovalTestUtility.genApproval();
        Test.startTest();
        
        System.currentPageReference().getParameters().put('id', BlackBerryApprovalTestUtil.workItemId);
        System.currentPageReference().getParameters().put('approverId', Userinfo.getUserId());
        System.currentPageReference().getParameters().put('comments','lorem ipsum');
        System.currentPageReference().getParameters().put('action', 'Approve');
        
        BlackBerryApproveRejectFormController barfc = new BlackBerryApproveRejectFormController();        
        barfc.readFormData();
        barfc.getObjDetail();
        
        System.currentPageReference().getParameters().put('id', BlackBerryApprovalTestUtil.workItemId);
        System.currentPageReference().getParameters().put('approverId', Userinfo.getUserId());
        System.currentPageReference().getParameters().put('comments','lorem ipsum');
        System.currentPageReference().getParameters().put('action', 'otro');
        try
		{
	        BlackBerryApproveRejectFormController barfc2 = new BlackBerryApproveRejectFormController();        
	        barfc2.readFormData();
	        barfc2.getObjDetail();
        }
		catch (Exception e)
		{
		}
	        
        System.currentPageReference().getParameters().put('id', null );
        System.currentPageReference().getParameters().put('approverId',null );
        System.currentPageReference().getParameters().put('comments',null); 
        
        BlackBerryApproveRejectFormController barfcnulled = new BlackBerryApproveRejectFormController();
        barfcnulled.readFormData();
        barfcnulled.getObjDetail();
	}
}