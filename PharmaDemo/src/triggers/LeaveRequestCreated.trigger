trigger LeaveRequestCreated on Leave_Request__c (before insert) {
    
    
    try {
        Leave_Request__c leavereq = Trigger.new[0];
        User u = [select Id, ManagerID, SAP_EmployeeID__c from User u where u.Id =:leavereq.OwnerId];
        
        for(Leave_Request__c lr:Trigger.new) {
            if(lr.ApproverEmployeeID__c != null) {
                //for the poc the managers won't change. This would need to be a lookup based on the SAP Employee Id on the Leave Request
                lr.Approver__c = u.ManagerID;
                lr.SAP_EmloyeeID__c = u.SAP_EmployeeID__c;
            }
            else {
                //newly inserted Leave Request in UI
                lr.Approver__c = u.ManagerID;
                lr.SAP_EmloyeeID__c = u.SAP_EmployeeID__c;
            }
        }
    }
    catch(Exception ex) {
        System.debug('Exception in LeaveRequestCreated trigger' +ex.getMessage());
    }
    
}