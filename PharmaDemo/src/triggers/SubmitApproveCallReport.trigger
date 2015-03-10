trigger SubmitApproveCallReport on call_report__c (after update) {

for(Call_Report__c CR: Trigger.new) {
    
    Call_Report__c beforeUpdate = System.Trigger.oldMap.get(CR.Id);


    if (CR.closed__c && CR.closed__c != beforeUpdate.closed__c ) {
        approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Locking Call');
        req1.setObjectId(CR.id);
        approval.ProcessResult result = Approval.process(req1);
        }
    }

}