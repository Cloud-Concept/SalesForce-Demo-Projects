public class CallReportAddContacts {






    Account acc;
    Call_Report__c crc;
    String loc;
    String newContact;
    Call_Attendees__c newAttendee;
    
    public Account getAccount() {
       Call_Report__c crc = [Select c.Name, c.Location__r.Name, c.Location__r.Id, c.Location__c, c.Id From Call_Report__c c where c.id = :System.currentPageReference().getParameters().get('id')];
       Account acc = [Select a.Name, a.Id From Account a where a.id =: crc.Location__r.Id];
       return acc;

        
    }
       public Call_Report__c getCallReport() {
       Call_Report__c crc = [Select c.Name, c.Location__r.Name, date__c,c.Location__r.Id, c.Location__c, c.Id From Call_Report__c c where c.id = :System.currentPageReference().getParameters().get('id')];
       return crc;

        
    }
    public list<Location__c> getContacter(){
        Call_Report__c crc = [Select c.Name, c.Location__r.Name, c.Location__r.Id, c.Location__c, c.Id From Call_Report__c c where c.id = :System.currentPageReference().getParameters().get('id')];

        return [Select Contact__c, Contact_Name__c From Location__c where Account__c =:crc.Location__r.id];

    }
    public list<Call_Attendees__c> getselectedContacts(){
        
        return [Select c.Id, c.Contact__r.Name, c.Contact__c, c.Call_Report__c From Call_Attendees__c c where c.Call_Report__c=:System.currentPageReference().getParameters().get('id')];
    }
    public PageReference addContactToCallReport(){
       //Call_Attendees__c newAttendee2;
      //      newContact=System.currentPageReference().getParameters().get('contactid');
     //    newAttendee2.Contact__c =newContact;
     //   newAttendee2.Call_Report__c=System.currentPageReference().getParameters().get('id');
    //    insert newAttendee2;
        return null;
    }
    
    public string delContact() {
        Call_Attendees__c delattendee = [select id from Call_Attendees__c where id=:System.currentPageReference().getParameters().get('attid')];
        delete delattendee;
        return null;
    }
    public string testparam(){
        newContact =System.currentPageReference().getParameters().get('contactid');
        Call_Attendees__c newAttendee2 = new Call_Attendees__c();
        newAttendee2.Contact__c=newContact;
        Call_Report__c c2 = [select id,calldate__c, Type__c from Call_report__c where id=:System.currentPageReference().getParameters().get('id')];
        newAttendee2.Call_Date__c = c2.callDate__c;
        newAttendee2.Type__c = c2.Type__c;        
        newAttendee2.Call_Report__c = c2.id;
        //newAttendee2.Call_Report__c=System.currentPageReference().getParameters().get('id');
        insert newAttendee2;
        return null;
    }
    public string getContactSelected(){
        return newContact ;
    }
    public string goback() {
    string tt = '/'+System.currentPageReference().getParameters().get('id');
        return tt;

    }
}