public class Event_Controller {

Event call;

   public Event getcall() {
            event ev = [select id, callreportid__c from event where id=:System.currentPageReference().getParameters().get('id')];
            call.callreportid__c = ev.callreportid__c;
  return call;
   }
   
   

}