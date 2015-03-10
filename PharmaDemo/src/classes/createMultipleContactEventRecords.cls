public class createMultipleContactEventRecords {

    ApexPages.StandardSetController con;
    public List<Event> newCalls {get; set;}
    public List<CampaignMember> newCampMem {get; set;}    
    public List<Event> calls {get;set;} 
    public List<Contact> selectedContacts {get; set;}
    
    //Constructor
    public createMultipleContactEventRecords(ApexPages.StandardSetController controller) {
        
        con = controller;
        
        if(this.con.getResultSize() > 0 ){ 
            this.con.setPageSize(5);
        } 
        //createCallReports();
    }
    
    //Create the Call Reports
    public void createCallReports() {
//            selectedAccounts = (List<Account>)con.getSelected();
            
            selectedContacts = (List<Contact>)con.getSelected();
            List<ID> ContactIds = new List<ID> ();
            for (Contact cnct : selectedContacts)
            ContactIds.add (cnct.id);
            selectedContacts = [select id, Account.Id, Account.ownerId, Best_Time__c, MailingPostalCode, MailingCity from Contact where id in :ContactIds];


            
            //set up an empty list to hold the opportunities
            newCalls = new List<Event>();
            newCampMem = new List<CampaignMember>();
            integer Counter;
            integer MonCounter;
            integer TuesCounter;
            integer WedsCounter;
            integer ThursCounter;
            integer FriCounter;                                    
            Counter = 0;
            MonCounter = 0;
            TuesCounter = 0;            
            WedsCounter = 0;
            ThursCounter = 0;
            FriCounter = 0;                                    
            for(Contact a: selectedContacts){
            Date myDate = Date.today();
            Date weekStart = myDate.toStartofWeek();
            date activityDate;
            activityDate = weekStart.addDays(7);
            if((a.Best_Time__c == '')||(a.Best_Time__c == null)){
                     activityDate = weekStart.addDays(7);
                    MonCounter = MonCounter + 1;
                    Counter = MonCounter;                     
                }else if(a.Best_Time__c == 'Monday'){
                    activityDate = weekStart.addDays(7);
                    MonCounter = MonCounter + 1;
                    Counter = MonCounter;
                }else if(a.Best_Time__c == 'Tuesday'){
                    activityDate = weekStart.addDays(8);
                    TuesCounter = TuesCounter + 1;
                    Counter = TuesCounter;                   
                }else if(a.Best_Time__c == 'Wednesday'){
                    activityDate = weekStart.addDays(9);
                    WedsCounter = WedsCounter + 1;
                    Counter = WedsCounter;                    
                }else if(a.Best_Time__c == 'Thursday'){
                    activityDate = weekStart.addDays(10);
                    ThursCounter = ThursCounter + 1;
                    Counter = ThursCounter;                    
                }else if(a.Best_Time__c == 'Friday'){
                    activityDate = weekStart.addDays(11);
                    FriCounter = FriCounter + 1;
                    Counter = FriCounter;                    
                }            
            DateTime startTime = datetime.newInstance(activityDate.year(), activityDate.month(), activityDate.day(), 8 + counter, 0, 0);

                newCalls.add(new Event(Subject = 'CSR - Call', Type = 'CSR - Call',WhatId = a.Account.Id, WhoId = a.Id, StartDateTime = startTime, StartDT__c = startTime, Location = a.MailingCity, Postal_Code__c = a.MailingPostalCode, DurationInMinutes = 15, ownerId = a.Account.ownerId, recordTypeid='01220000000UUTVAA4'));
                newCampMem.add(new CampaignMember (CampaignId = '70120000000ZoNBAA0', Status = 'Member', ContactId = a.id));
            }
            
            //insert into the db
            insert newCalls;
//            insert newCampMem;
            pullRecords();
    }
    
    public PageReference pullRecords(){
        calls = new List<Event>();
        List<Event> temp  = [Select Id, Subject, ActivityDate, StartDate__c, WhoId, WhatId, ownerid, AccountId, Location, Postal_Code__c From Event order by StartDate__c];
        
        for(Event i: temp){
            for(Event j: newCalls){
                if(i.Id == j.Id){
                    calls.add(i);
                }
            }
        }
        
        return null;
    }

}