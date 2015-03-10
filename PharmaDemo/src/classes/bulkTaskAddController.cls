// Jonathan Hersh - jhersh@salesforce.com
// October 8, 2008

public class bulkTaskAddController {
    public SFDC_Acct_Plan__c o { get; set; }
    public Task[] t { get; set; }
    public final integer pagesize = 5;
    
    public bulkTaskAddController() {
        o = [select id, name from SFDC_Acct_Plan__c where id =
            :ApexPages.currentpage().getParameters().get('id')];    
        t = new Task[] {};
        
        for( integer x = 0; x < pagesize; x++ )
            t.add( new Task( whatid = o.id, status = 'Not Started' ) );
    }
    
    public pageReference save() {
        Task[] to_add = new Task[] {};
        
        for( Task tmp : t )
            if( tmp.ownerid != null )
                to_add.add( tmp );
                
        try {
            insert to_add;
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
    
    public static testMethod void testAdd() {
            pageReference p = Page.bulkTaskAdd;
            p.getParameters().put('id', [select id from SFDC_Acct_Plan__c LIMIT 1].id );
            
            test.setCurrentPage( p );
            
            bulkTaskAddController btac = new bulkTaskAddController();
            SFDC_Acct_Plan__c otest = btac.o;
            Task[] ttest = btac.t;
            
            btac.save();
            btac.cancel();
    }
}