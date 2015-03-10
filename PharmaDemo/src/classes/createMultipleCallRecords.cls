public class createMultipleCallRecords {

  ApexPages.StandardSetController con;
  string UserId = userinfo.getUserId();      
  public List<Call_Report__c> newCalls {get; set;}
  public List<Call_Report__c> calls {get;set;}
  public List<Location__c> selectedContacts {get; set;}
  
  //Constructor
    public createMultipleCallRecords(ApexPages.StandardSetController controller) {
      
      con = controller;
      
      if(this.con.getResultSize() > 0 ){ 
      this.con.setPageSize(5);
    } 
    //createCallReports();
    }
    
    //Create the Call Reports
    public void createCallReports() {

        //get the selected assets
        selectedContacts = (List<Location__c>)con.getSelected();
        List<ID> ContactIds = new List<ID> ();
        for (Location__c L : selectedContacts)
            ContactIds.add (L.id);
        selectedContacts = [select id, contact__c, account__c, best_time__c from Location__c where id in :ContactIds];
        
        //set up an empty list to hold the opportunities
        newCalls = new List<Call_Report__c>();
        
        
        
        for(Location__c c: selectedContacts){
              Date myDate = Date.today();
              Date weekStart = myDate.toStartofWeek();
              Integer hours = 0;
              date activityDate;

             if((c.Best_Time__c == '')||(c.Best_Time__c == null)){
                   activityDate = weekStart.addDays(7);
                   hours = 9;
              }else if(c.Best_Time__c == 'Monday - AM'){
                  activityDate = weekStart.addDays(7);
                  hours = 9;
              }else if(c.Best_Time__c == 'Monday - PM'){
                  activityDate = weekStart.addDays(7);
                  hours = 13;                  
              }else if(c.Best_Time__c == 'Tuesday - AM'){
                  activityDate = weekStart.addDays(8);
                  hours = 9;
              }else if(c.Best_Time__c == 'Tuesday - PM'){
                  activityDate = weekStart.addDays(7);
                  hours = 13;                                    
              }else if(c.Best_Time__c == 'Wednesday - AM'){
                  activityDate = weekStart.addDays(9);
                  hours = 9;
              }else if(c.Best_Time__c == 'Wednesday - PM'){
                  activityDate = weekStart.addDays(7);
                  hours = 13;                                    
              }else if(c.Best_Time__c == 'Thursday - AM'){
                  activityDate = weekStart.addDays(10);
                  hours = 9;                  
              }else if(c.Best_Time__c == 'Thursday - PM'){
                  activityDate = weekStart.addDays(7);
                  hours = 13;                                                     
              }else if(c.Best_Time__c == 'Friday - AM'){
                  activityDate = weekStart.addDays(11);
                  hours = 9;                  
              }else if(c.Best_Time__c == 'Friday- PM'){
                  activityDate = weekStart.addDays(7);
                  hours = 13;                                                     
              }
                  
             
              DateTime CallDate= datetime.newInstance(activityDate.year(), activityDate.month(), activityDate.day(), hours, 0, 0);             
          newCalls.add(new Call_Report__c(Contact__c = c.contact__c, location__c=c.account__c, Duration__c = '10', OwnerId=UserId, User__c=UserId, date__c = CallDate));
        }
        
        //insert into the db
        insert newCalls;
        pullRecords();
    }
    
    public PageReference pullRecords(){
      calls = new List<Call_Report__c>();
      List<Call_Report__c> temp  = [Select Type__c,Id, Location__c, Location__r.id, Location__r.Name, contact__c, contact__r.id, contact__r.Full_Name__c, Date__c, Calldate__c, User__c From Call_Report__c];
      
      for(Call_Report__c i: temp){
        for(Call_Report__c j: newCalls){
          if(i.Id == j.Id){
            calls.add(i);
          }
        }
      }
      
      return null;
    }

}