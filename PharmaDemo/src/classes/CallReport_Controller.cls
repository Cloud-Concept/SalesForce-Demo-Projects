public class CallReport_Controller {

Call_Report__c call_report;
PageReference nextpage;


   public Call_Report__c getCall_Report() {
   string locationid = System.currentPageReference().getParameters().get('locationid');
   string contactid= System.currentPageReference().getParameters().get('contactid');
   string accountid = System.currentPageReference().getParameters().get('accountid');
   string UserId = userinfo.getUserId();
   
      if (call_report == null) call_report = new Call_Report__c();
        if (locationid == null)
        {
            call_report.location__c= accountid;
            call_report.contact__c= contactid;
        }
        else
        {
            location__c location = [select id, contact__c, account__c from location__c where id=:locationid];
            contactid = location.contact__c;
            accountid = location.account__c;
            call_report.contact__c = location.contact__c;
            call_report.location__c = location.account__c;
       }
        call_report.Type__c= System.currentPageReference().getParameters().get('type');
        contact contact = [select id, next_call_objective__c, call_notes__c from contact where id =:contactid];
        call_report.next_call_objective__c = contact.next_call_objective__c;
        call_report.call_notes__c = contact.call_notes__c;
        call_report.user__c = UserId;
        account account = [select id, brick__c from account where id =:accountid];
        call_report.brick__c = account.brick__c;
 
  
  return call_report;
   }
   
   
   public PageReference cancel() {
     nextpage = new PageReference('/'+call_report.contact__c);
     nextpage.setRedirect(true);
     return nextpage;
   }
   
   public PageReference save() {
     insert call_report;
     nextpage = new PageReference('/'+call_report.id);
     nextpage.setRedirect(true);
     return nextpage;
   }

}