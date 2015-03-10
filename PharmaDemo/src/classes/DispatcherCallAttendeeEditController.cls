public class DispatcherCallAttendeeEditController{
 
    public DispatcherCallAttendeeEditController(ApexPages.StandardController controller) {
        this.controller = controller;
    }
 
    public PageReference getRedir() {
        Call_Attendees__c att = [select id, Call_Report__c from Call_Attendees__c where id = :ApexPages.currentPage().getParameters().get('id')];     
        Call_Report__c c = [Select id, closed__c From call_report__c Where Id =: att.Call_Report__c];
 
        PageReference newPage;
 
        if (c.closed__c) {
            newPage = Page.NoEdit;
        } else {
            newPage = new PageReference('/' + att.id);
            newPage.getParameters().put('nooverride', '1');
        }
 
        newPage.getParameters().put('id', att.id);
        return newPage.setRedirect(true);
 
    }
 
    private final ApexPages.StandardController controller;
 
}