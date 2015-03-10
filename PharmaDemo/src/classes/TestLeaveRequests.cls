@isTest
private class TestLeaveRequests {


	//test leave balance set extension
	private static testMethod void testLeaveBalanceSetExtension() {
		//set up a leave balance
		Leave_Balance__c lb = new Leave_Balance__c();
		lb.BalanceApprovedQuantity__c = 10;
		lb.BalanceAvailableQuantity__c = 20;
		lb.BalanceEntitlementQuantity__c = 30;
		lb.BalancePlannedQuantity__c = 5;
		lb.BalanceRequestedQuantity__c = 5;
		lb.BalanceUsedQuantity__c = 15;
		lb.TimeAccountType__c = '01';
		lb.TimeAccountTypeName__c = 'Vacation';
		lb.User__c = Userinfo.getUserId();
		insert lb;
				
		LeaveBalanceSetExtension lbse = new LeaveBalanceSetExtension();
		System.assertNotEquals(lbse.balances , null);
	}
	
	//test leave request detail controller
	private static testmethod void testleaverequestdetailcontroller() {		
		System.assertEquals(LeaveRequestDetailController.saveLeaveRequest(null, 'Vacation', Date.today(), Date.today().addDays(1), 'notes'), 'Saved');
	}
	
	//test leave request extension
	private static testmethod void testleaverequestextension() {
		Leave_Request__c lr = new Leave_Request__c();
		lr.From__c = Date.today();
		lr.To__c = Date.today().addDays(1);
		lr.Approval_Status__c = 'pending';
		
		insert lr;
		
		ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(lr);
		LeaveRequestExtension lre = new LeaveRequestExtension(con);
		//just run some methods
		lre.getFormattedFrom();
		lre.getFormattedTo();
		lre.save();
		lre.cancel();
		
		//create a new one - no id
		Leave_Request__c lr2 = new Leave_Request__c();
		lr2.From__c = Date.today();
		lr2.To__c = Date.today().addDays(1);
		lr2.Approval_Status__c = 'pending';
		
		ApexPages.Standardcontroller con2 = new ApexPages.Standardcontroller(lr2);
		LeaveRequestExtension lre2 = new LeaveRequestExtension(con2);
		lre2.save();
		lre2.cancel();
		
	}
	
	//test leave requestsetextension
	private static testmethod void testleaverequestsetextension() {
		Leave_Request__c lr = new Leave_Request__c();
		lr.From__c = Date.today();
		lr.To__c = Date.today().addDays(1);
		lr.Approval_Status__c = 'pending';
		
		insert lr;
		
		ApexPages.Standardsetcontroller con = new ApexPages.Standardsetcontroller([select Id, Name from Leave_Request__c limit 10]);
		LeaveRequestSetExtension lrse = new LeaveRequestSetExtension(con);
		System.assertNotEquals(lrse.getRequests(), null);
		
	} 

	//empty method test
	private static testMethod void testJsonController() {
		costcenter_json_controller cjc = new costcenter_json_controller();
		cjc.getCostcenters();
	}

}