public with sharing class chatterFiles {


    public List<ContentDocumentLink> filePosts{get;set;}
    
    public class superCDL{
    	Public ContentDocumentLink cdl{get;set;}
    	
    }
    
    
    
    public chatterFiles(ApexPages.StandardController std)
    {
        Sobject c = std.getRecord();
        fileposts = database.query('select id, contentDocumentID, contentDocument.title, contentDocument.createdBy.Name, contentDocument.latestPublishedVersion.filetype, contentDocument.latestPublishedVersionID, contentDocument.createdDate from ContentDocumentLink where linkedEntityID = \'' + c.get('id') + '\' order by contentDocument.createdDate desc');
     
    }
    
    static testMethod void testItOut(){
    	Account a = new Account();
    	a.name = 'test';
    	insert a;
    	ApexPages.StandardController std = new ApexPages.StandardController(a);
    	
    	chatterFiles cf = new chatterFiles(std);
    }

}