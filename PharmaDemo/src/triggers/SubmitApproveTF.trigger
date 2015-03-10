trigger SubmitApproveTF on TF__c (after update) {

for(TF__c tf: Trigger.new) {
    
    TF__c beforeUpdate = System.Trigger.oldMap.get(tf.Id);


    if (tf.status__c == 'Submitted' && tf.Proposed_Frequency__c != null && tf.status__c != beforeUpdate.status__c) {
        approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting Target for approval');
        req1.setObjectId(tf.id);
        approval.ProcessResult result = Approval.process(req1);
        }
        
   if (tf.ToBeApproved__c && tf.status__c == 'Submitted') {
        approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest ();
        ProcessInstanceWorkitem piw = [Select p.Id, p.ProcessInstanceId, p.ProcessInstance.TargetObjectId from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: tf.id];
        req2.setComments('Approving Target');
        req2.setAction('Approve');
        req2.setWorkitemId(piw.id);
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});        
        approval.ProcessResult result = Approval.process(req2);
        }       

   if (tf.reject__c && tf.status__c == 'Submitted') {
        approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest ();
        ProcessInstanceWorkitem piw = [Select p.Id, p.ProcessInstanceId, p.ProcessInstance.TargetObjectId from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: tf.id];
        req3.setComments('Reject Target');
        req3.setAction('Reject');
        req3.setWorkitemId(piw.id);
        req3.setNextApproverIds(new Id[] {UserInfo.getUserId()});        
        approval.ProcessResult result = Approval.process(req3);
        }             
    }

}