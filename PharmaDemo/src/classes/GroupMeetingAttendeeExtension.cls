public class GroupMeetingAttendeeExtension {
    public PharmaProduct__c[] plans {get;set;}
    public ProdSect[] selection {get; set;}
    public Sample__c[] samplenames {get;set;}
    public SampleSect[] samp {get;set;}
    public Promotional_Product__c[] promonames {get;set;}
    public PromoSect[] promo {get;set;}


    private Call_Report__c gm;
    private String addContactIds = '';
    private String removeContactIds = '';

    
    private String singleContactId = '';
    
    private List <Location__c> accountContacts = new List<Location__c>();
    
    private List <Call_Attendees__c> attendees = new List<Call_Attendees__c>();

    public GroupMeetingAttendeeExtension (ApexPages.StandardController controller) {
        this.gm = (Call_Report__c)controller.getRecord();
        
        
        
        selection = new ProdSect[]{};
        plans = [select Name
             from PharmaProduct__c ];
        
        for (PharmaProduct__c p : plans){
            
            
                    selection.add(new ProdSect(new Product_Detail__c(),p,false));
                    
    
        }
        
        
        
        
        
        samp = new SampleSect[]{};  
        samplenames = [select Name, Cost__C
                    from Sample__c];                
        for (Sample__c s : samplenames){
            
                    samp.add(new SampleSect(new Sample_Item__c(),s,false));
                    
        
        }
        
        promo = new PromoSect[]{};
        promonames=[select Name, Cost__c
                    from Promotional_Product__c];
        for (Promotional_Product__c pr : promonames){
        
                 promo.add(new PromoSect(new Promotional_Item__c(), pr, false));
            
        }
        
        
        
        
        
    }

    public List <Call_Attendees__c> getAttendees() {
        attendees = [Select Id, Contact__c, Contact__r.Email, Contact__r.Phone, Contact__r.Name, Contact__r.Call_Indicator__c,  Contact__r.Spec__c, Contact__r.KOL__c from Call_Attendees__c Where Call_Report__c = :gm.Id];
        return attendees;
    } 
    
    public List <Location__c> getAccountContacts() {
    
        if (this.gm.Location__c != null) {
            accountContacts = [select id,  Email__c ,  contact__c, Contact__r.Name, Contact__r.Phone, Contact__r.Call_Indicator__c, Contact__r.Last_Activity__c, Contact__r.Spec__c, Contact__r.KOL__c from location__c where Account__c =:this.gm.Location__c];
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
                Call_Attendees__c gma = new Call_Attendees__c();
                gma.Contact__c = contact.Id;
                    Call_Report__c c2 = [select id,calldate__c, Type__c from Call_report__c where id=:this.gm.Id];        
                    gma.Type__c = c2.Type__c;                         
                    gma.Call_Date__c = c2.CallDate__c;
                    gma.Name = contact.Name;                         
                gma.Call_Report__c = this.gm.Id;
                Database.SaveResult result = Database.Insert(gma, false);
            }
        }           
    }
    
   public void addContacts() {
        String[] ids = addContactIds.split(','); 
        if (ids.size() > 0) {
            List <Call_Attendees__c> attendeesToUpdate = new List <Call_Attendees__c>();        
            List<Contact> contacts = [Select Id, Name from Contact Where Id In : ids];
            for(Contact contact : contacts) {
                Boolean found = false;
                for (Call_Attendees__c attendee: attendees) {
                    if (attendee.Contact__c == contact.Id) {
                        found = true;
                    }
                }
                if ( ! found ) {
                    Call_Attendees__c gma = new Call_Attendees__c();
                    gma.Contact__c = contact.Id;
                    Call_Report__c c2 = [select id,calldate__c, Type__c from Call_report__c where id=:this.gm.Id];        
                    gma.Type__c = c2.Type__c;                         
                    gma.Call_Date__c = c2.CallDate__c;                         
                    gma.Call_Report__c = this.gm.Id;
                    gma.Name = contact.Name;
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
    
    
    
    
    
    public pageReference save(){
        
    Product_Detail__c[] newPD = new Product_Detail__c[]{};
    Sample_Item__c[] newSI = new Sample_Item__c[]{};
    Promotional_Item__c[] newPI = new Promotional_Item__c[]{};
    
     String url = '/' + gm.Id;
     
     for (ProdSect PS: selection){
        
//        if(PS.selected == true){
        if(PS.prodD.Sequence__c > 0){
            PS.prodD.Name = PS.Product.Name;  
            PS.prodD.Product__c = PS.Product.Id;
            PS.prodD.Call_Report__c = gm.ID;
            newPD.add(PS.ProdD);

        }
     }
     
     insert newPD;
     
      for (SampleSect PS: samp){
        
//        if(PS.selected == true){
        if(PS.SI.Quantity__c >0){   
            PS.SI.Name = PS.Sample.Name;   
            PS.SI.Sample__c = PS.Sample.Id;
            PS.SI.Call_Report__c = gm.ID;
            PS.SI.Contact__c = gm.Contact__c;
            PS.SI.Cost__c = PS.Sample.Cost__c;
            newSI.add(PS.SI);

        }
     }
     
     insert newSI;
     
      for (PromoSect PS: promo){
//        if(PS.selected == true){
        if(PS.PI.Qty__c > 0){
            PS.PI.Name = PS.promoprod.Name;           
            PS.PI.Promotional_Product__c = PS.promoprod.Id;
            PS.PI.Call_Report__c = gm.ID;
            PS.PI.Contact__c = gm.Contact__c;   
            PS.PI.Cost__c = PS.promoprod.Cost__c;
            newPI.add(PS.PI);
        }
     }
     
     insert newPI;
     
    
    pageReference pr = new pageReference(url); 
    pr.setRedirect(true);
    return pr;
        
    //return null;  
        
        
        
    }
    
    
    
    
    
    public class ProdSect{
        
        
        public boolean selected {get; set;}
        public Product_Detail__c prodD {get; set;}
        public PharmaProduct__c product {get;set;}
        
        
        
        public ProdSect(Product_Detail__c p, PharmaProduct__c item, boolean checkbox){
            prodD = p;
            product = item;
            checkbox = selected;
            
                
        }
        
    }
    
    
    
    
    
    public class SampleSect{
        
        
        public boolean selected {get; set;}
        public Sample_Item__c SI {get; set;}
        public Sample__c sample {get;set;}
        
        
        
        public SampleSect(Sample_Item__c p, Sample__c item, boolean checkbox){
            SI = p;
            sample = item;
            checkbox = selected;
            
                
        }   
    }
    
    
     public class PromoSect{
        
        
        public boolean selected {get; set;}
        public Promotional_Item__c PI {get; set;}
        public Promotional_Product__c promoprod {get;set;}
        
        
        
        public PromoSect(Promotional_Item__c p, Promotional_Product__c item, boolean checkbox){
            PI = p;
            promoprod = item;
            checkbox = selected;
            
                
        }   
    }
}