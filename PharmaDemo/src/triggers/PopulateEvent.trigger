trigger PopulateEvent on Event (before insert) {
    
    //pull info from accounts
    List<Account> acct = [Select Name, Id, BillingCity, BillingPostalCode, Best_Time__c, OwnerId From Account];
                  
    //pull old call reports
    List<Event> oldCalls = [Select Id, RecordTypeId, ActivityDate, LastModifiedDate, CreatedDate,WhoId, WhatId From Event where Visit_Made__c =: TRUE order by CreatedDate desc];
    
         
    for(integer x = 0; x < trigger.new.size(); x++){
        
        if(trigger.new.get(x).WhatId!= null){
            //select specific account
            Account acc = new Account();
            for(Account a: acct){
                if(a.Id ==  trigger.new.get(x).WhatId){
                    acc = a;
                } 
            }
            
//            if(acc.Id != null){
                
               
                
                
                //determine the date of the activity
                Date myDate = Date.today();
                Date weekStart = myDate.toStartofWeek();
                date activityDate;
                if((acc.Best_Time__c == '')||(acc.Best_Time__c == null)){
                     activityDate = weekStart.addDays(7);
                }else if(acc.Best_Time__c == 'Monday'){
                    activityDate = weekStart.addDays(7);
                }else if(acc.Best_Time__c == 'Tuesday'){
                    activityDate = weekStart.addDays(8);
                }else if(acc.Best_Time__c == 'Wednesday'){
                    activityDate = weekStart.addDays(9);
                }else if(acc.Best_Time__c == 'Thursday'){
                    activityDate = weekStart.addDays(10);
                }else if(acc.Best_Time__c == 'Friday'){
                    activityDate = weekStart.addDays(11);
                }
                
                //select last applicable call report
                //Account__c =: trigger.new.get(x).Account__c and
                List<Event> lastCall = new List<Event>();
                for(Event c: oldCalls){
                    if(c.WhatId == trigger.new.get(x).WhatId){
                        lastCall.add(c);
                    }
                }
                
                
                //determine the time for the activity
                Integer activitytime = 15;

                
                //make the activity
                DateTime startTime = datetime.newInstance(activityDate.year(), activityDate.month(), activityDate.day(), 9, 0, 0);
                DateTime endTime = startTime.addMinutes(activitytime);
//                Event e = new Event(OwnerId = acc.OwnerId, Subject = 'Call', StartDateTime = startTime , EndDateTime = endTime, DurationInMinutes = activitytime, WhatId = trigger.new.get(x).Id, RecordTypeId='012200000009bS8AAI', Postal_code__c = acc.BillingPostalCode, Location = acc.BillingCity);
                Event e = new Event(OwnerId = acc.OwnerId, Subject = 'Call', ActivityDateTime = datetime.now(), DurationInMinutes = 15, Location = acc.BillingCity, Postal_Code__c = acc.BillingPostalCode);
                insert e;
                
//            }
        }
    }
}