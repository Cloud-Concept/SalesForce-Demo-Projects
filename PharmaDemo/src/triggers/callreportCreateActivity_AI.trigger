/**
*
* Creates a corresponding event record when a in-field activity is created and links
* both records via field CallReportId__c in Event.
*
* @author: Maic Stohr
* @version: 0.1
*
*/

trigger callreportCreateActivity_AI on Call_Report__c (after insert) {
   
    
    /*
    * Determine unique list of reference records for given call reports
    */ 
    
    Set<String> set_referenceIds = new Set<String>();
    
    for (Call_Report__c nCall : Trigger.new) {  
        String sReferenceId =  ((String) nCall.Contact__c).substring(0,15) + '|' +  ((String) nCall.Location__c).substring(0,15);
        set_referenceIds.add(sReferenceId);
    }
    
    Map<String,String> map_BestTimeByReferenceId = new Map<String,String>();
       
    for (Location__c r : [select Id, Unique_id__c, Best_Time__c from Location__c where Unique_Id__c in :set_referenceIds]) {
        if (!map_BestTimeByReferenceId.containsKey(r.Unique_Id__c)) {
            map_BestTimeByReferenceId.put(r.Unique_Id__c, r.Best_Time__c);
        }
    }
    
    if ( ! Utilities.getAlreadyUpdatingEvents() ) {
    List<Event> list_events = new List<Event>();
    
    for (Call_Report__c nCall : Trigger.new) {
        String sReferenceId =  ((String) nCall.Contact__c).substring(0,15) + '|' +  ((String) nCall.Location__c).substring(0,15);
        
        String sTmpBestTime = '';
        if (map_BestTimeByReferenceId.containsKey(sReferenceId)) {
            sTmpBestTime = map_BestTimeByReferenceId.get(sReferenceId);
        }
        
        Event nEvent = new Event();
        nEvent.WhoId = nCall.Contact__c;
        nEvent.WhatId= nCall.Location__c;
        nEvent.Subject = nCall.Type__c;
        nEvent.ActivityDateTime = nCall.Date__c;
        nEvent.Related_Id__c = ncall.Id; 
        nEvent.DurationInMinutes = Integer.valueOf(nCall.Duration__c);
        nEvent.OwnerId= nCall.User__c;
        nEvent.Type1__c = nCall.Type__c;
        nEvent.Best_Time__c = sTmpBestTime;
        nEvent.Accompanied_Call__c = ncall.Accompanied_Call__c;
        
        list_events.add(nEvent);
    }
                   insert list_events;
    }
    List<Call_Attendees__c> list_attendees = new List<Call_Attendees__c>();
    
    for (Call_Report__c nCall : Trigger.new) {
        
        Call_Attendees__c nCallAttendee = new Call_Attendees__c();
        nCallAttendee.Call_Report__c = ncall.Id;
        nCallAttendee.Call_Date__c = nCall.CallDate__c;
        nCallAttendee.Type__c = nCall.Type__c;
        nCallAttendee.Contact__c = nCall.Contact__c;
        nCallAttendee.Next_Call_Objective__c = nCall.Next_Call_Objective__c;
        nCallAttendee.Call_Notes__c = nCall.Call_Notes__c;
//        nCallAttendee.Name = nCall.FullName__c;
        
        
        list_attendees.add(nCallAttendee);
    }    
    

                insert list_attendees;

            }