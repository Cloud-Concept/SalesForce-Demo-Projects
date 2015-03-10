/**
*
* Creates a corresponding event record when a Time off Territory is created 
*
* @author: Michael Ohme
* @version: 0.1
*
*/

trigger timeoffCreateEvent_AI on Time_off_Territory__c (after insert) {
    
    // Get Event Record Type    
    Id eventRecordTypeId = [Select Id from RecordType where SobjectType = 'Event' and DeveloperName = 'TimeOffTerritory'][0].Id;
    
    //List for events that shall be inserted
    List<Event> list_events = new List<Event>();
    //Map for storing submitted times
    List<Time_off_Territory__c> list_submitted = new List<Time_off_Territory__c>();

    for (Time_off_Territory__c t: trigger.new){
        
        //we only have to insert new time off events - Submit must not be inserted
        if (t.Type__c == 'Open'){
            /*
            * Compile Subject and Description
            */
            
            String subject = '';
            String description = '';
            //List of four elements to store values of quarters
            List<String> periods = new String[4];
            //If All Day is checked, only 1/4 is to be used
            if(t.All_Day__c){
                subject=t.Type_First_Quarter__c;
                periods.set(0,'All-day: ' + t.Type_First_Quarter__c);
            }
            else {
                //Values of quarters are copied to period for easily work with it 
                periods.add(0,t.Type_First_Quarter__c);
                periods.add(1,t.Type_Second_Quarter__c);
                periods.add(2,t.Type_Third_Quarter__c);
                periods.add(3,t.Type_Fourth_Quarter__c);
                
                                        
                Integer i = 0;
                for (String p : periods) {
                    if (p != null) {
                        //Subject set to static Time-off Territory
                        subject = 'Time-off Territory';
                        i++;
                        //Period is changed to show period and value on Description
                        description += i + '/4: ' + p + '\n\r';
                    }
                }                           
            }
            /*
            Data for event are stored from trigger          
            */
            
            Event nEvent = new Event();
            nEvent.Subject=subject;
            nEvent.Type = 'Time Off';
            //nEvent.WhatId = t.Id;
            nEvent.OwnerId = t.OwnerId;
            nEvent.IsAllDayEvent = true;
            nEvent.ShowAs='OutOfOffice';
            nEvent.Related_Id__c = t.Id;
            nEvent.Description = description;
            nEvent.RecordTypeId = eventRecordTypeId;
            
            nEvent.StartDateTime = DateTime.newInstanceGmt(t.Start_Date__c.year(),t.Start_Date__c.month(),t.Start_Date__c.day());
            nEvent.EndDateTime = DateTime.newInstanceGmt(t.End_Date__c.year(),t.End_Date__c.month(),t.End_Date__c.day());
            
            //t.addError('Start Date: ' + nEvent.StartDateTime);
            
            //All informations for event stored om list
            list_events.add(nEvent);
        }
    }
    /*
    events are inserted
    */
    if (list_events != null)
        insert list_events;
  
}