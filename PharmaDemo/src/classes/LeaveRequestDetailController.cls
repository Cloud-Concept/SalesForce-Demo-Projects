public with sharing class LeaveRequestDetailController {

	@RemoteAction
	public static String saveLeaveRequest(String id, String leavetype, Date fromdate, Date todate, String notes) {
		
		Leave_Request__c lr;
		//see it this Leave Request Already exists
		try {
			lr = [select Id from Leave_Request__c where id =:id];
		}
		catch(Exception ex) {
			lr = new Leave_Request__c();	
		}
		
		//fill in the new data
		lr.Leave_Type__c = leavetype;
		lr.From__c = fromdate;
		lr.To__c = todate;
		lr.Notes__c = notes;
		
		//and save
		upsert(lr);
		
		return 'Saved';
	}

}