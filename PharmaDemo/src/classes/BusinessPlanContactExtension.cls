public class BusinessPlanContactExtension {

    private SFDC_Acct_Plan__c gm;
    private String addContactIds = '';
    private String removeContactIds = '';

    
    private String singleContactId = '';
    
    private List <Location__c> accountContacts = new List<Location__c>();
    
    private List <Additional_Business_Plan_Contacts__c> attendees = new List<Additional_Business_Plan_Contacts__c>();

    public BusinessPlanContactExtension (ApexPages.StandardController controller) {
        this.gm = (SFDC_Acct_Plan__c)controller.getRecord();
        string accountid = System.currentPageReference().getParameters().get('accountid');
        gm.Organisation__c = accountid;
    }

    public List <Additional_Business_Plan_Contacts__c> getAttendees() {
        attendees = [Select Id, Contact__c, Contact__r.Email, Contact__r.Phone, Contact__r.Name, Contact__r.Call_Indicator__c, Contact__r.Spec__c, Contact__r.KOL__c from Additional_Business_Plan_Contacts__c Where Business_Plan__c = :gm.Id];
        return attendees;
    } 
    
    public List <Location__c> getAccountContacts() {
        string accountid = System.currentPageReference().getParameters().get('accountid');
        if (this.gm.Organisation__c != null) {
            accountContacts = [select id,  Email__c ,  contact__c, Contact__r.Name, Contact__r.Phone, Contact__r.Call_Indicator__c, Contact__r.Last_Activity__c, Contact__r.Spec__c,  Contact__r.KOL__c from location__c where Account__c =:accountid];
        }
        return accountContacts;
    } 
    
    public void setAddContactIds(String ids) {
        addContactIds = ids;     
    }

    public String getAddContactIds() {
        return addContactIds;     
    }

    public void setRemoveContactIds(String ids) {
        removeContactIds = ids;     
    }

    public String getRemoveContactIds() {
        return removeContactIds;     
    }

    public void setSingleContactId(String id) {
        singleContactId = id;     
    }

    public String getSingleContactId() {
        return singleContactId;     
    }

        
    public string goback() {
    string tt = '/'+System.currentPageReference().getParameters().get('id');
        return tt;

    }
    
    public void addSingleContact() {
        if(singleContactId != '') {
            Contact contact = [Select Id, Name From Contact Where Id = :singleContactId];
            if (contact != null) {           
                Additional_Business_Plan_Contacts__c gma = new Additional_Business_Plan_Contacts__c();
                gma.Contact__c = contact.Id;
                gma.Business_Plan__c = this.gm.Id;
                Database.SaveResult result = Database.Insert(gma, false);
            }
        }           
    }
    
   public void addContacts() {
        String[] ids = addContactIds.split(','); 
        if (ids.size() > 0) {
            List <Additional_Business_Plan_Contacts__c> attendeesToUpdate = new List <Additional_Business_Plan_Contacts__c>();        
            List<Contact> contacts = [Select Id, Name from Contact Where Id In : ids];
            for(Contact contact : contacts) {
                Boolean found = false;
                for (Additional_Business_Plan_Contacts__c attendee: attendees) {
                    if (attendee.Contact__c == contact.Id) {
                        found = true;
                    }
                }
                if ( ! found ) {
                    Additional_Business_Plan_Contacts__c gma = new Additional_Business_Plan_Contacts__c();
                    gma.Contact__c = contact.Id;
                    gma.Business_Plan__c = this.gm.Id;
                    attendeesToUpdate.add(gma);                 
                }
            }
            Database.SaveResult[] results = Database.Insert(attendeesToUpdate, false);
        }
    }
    
    public void removeContacts() {
        String[] ids = removeContactIds.split(',');
        List<String> deleteIds = new List<String>();
        for (String id : ids) {
            if (id.length() == 18) {
                deleteIds.add(id);  
            }   
        }
        if (deleteIds.size() > 0) {
            Database.DeleteResult[] results = Database.delete(deleteIds, false);
        } 
    }
    
 
}