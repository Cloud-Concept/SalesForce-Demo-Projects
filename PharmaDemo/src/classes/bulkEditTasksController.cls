// Jonathan Hersh - jhersh@salesforce.com
// October 8, 2008

public class bulkEditTasksController {
    public SFDC_Acct_Plan__c o { get; set; }
    public Task[] t { get; set; }

    public bulkEditTasksController() {
        o = [select id, name from SFDC_Acct_Plan__c where id =
            :ApexPages.currentpage().getParameters().get('id')];    
        t = [select id, ownerid, subject, status, description, activitydate, whoid
            from Task where isclosed = false and whatid = :o.id];
            
        if( t.size() == 0 )
            t = new Task[] {};
    }
    
    public pageReference save() {
        try {
            update t;
        } catch( Exception e ) {}
        
        pageReference pr = new pageReference('/'+ o.id);
        pr.setredirect(true);
        return pr;  
    }
    
    public pageReference cancel() {
        pageReference pr = new pageReference('/'+ o.id);
        pr.setredirect(true);
        return pr;  
    }
    
    public static testMethod void testEdit() {
            pageReference p = Page.bulkEditTasks;
            p.getParameters().put('id', [select id from SFDC_Acct_Plan__c LIMIT 1].id );
            
            test.setCurrentPage( p );
            
            bulkEditTasksController betc = new bulkEditTasksController();
            SFDC_Acct_Plan__c otest = betc.o;
            Task[] ttest = betc.t;
            
            betc.save();
            betc.cancel();
    }
}