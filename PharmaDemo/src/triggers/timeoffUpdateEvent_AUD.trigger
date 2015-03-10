/**
*
* Updates related event record when corresponding time off territory record gets updated or deleted.
*
* @author: Maic Stohr
* @version: 0.1
*
*/

trigger timeoffUpdateEvent_AUD on Time_off_Territory__c (after delete, after update) {
    
    
    if (TriggerRecursionDefense.initiatingObject == null)
        TriggerRecursionDefense.initiatingObject = 'Time_off_Territory__c';
            
    // Check if map_oldCallReports is already set
    if (TriggerRecursionDefense.map_oldTimeOffs == null)
        TriggerRecursionDefense.map_oldTimeOffs = Trigger.oldMap;
        
    if (TriggerRecursionDefense.initiatingObject == 'Time_off_Territory__c') { // If: Only update events if time off territory is initiating

        /*
        * Determine trigger image
        */ 
        
        List<Time_off_Territory__c> list_triggerObjects;
        
        // based on update or delete
        if (Trigger.isUpdate) {
            list_triggerObjects = Trigger.new;
        }
        else {
            list_triggerObjects = Trigger.old;
        }
        
    
        Set<Id> set_timeOffIds = new Set<Id>(); // contains all time off territory ids that are changed by this trigger
        
        /*
        * Determine call report ids and collect in set set_timeOffIds
        */
        
        for (Time_off_Territory__c nTimeOff : list_triggerObjects) {
            /*
            * Only if it's not yet locked otherwise report error that this cannot be moved or deleted
            */
            
            Time_off_Territory__c oTimeOff = TriggerRecursionDefense.map_oldTimeOffs.get(nTimeOff.Id);
            
            if (nTimeOff.Type__c == 'Closed' || nTimeOff.Type__c == 'Submit') {
                // When start date or duration changes we moved the event
                // If delete trigger, we deleted it!
                
                if (oTimeOff != null) { // If we submit a record the workflow rule executes an update where oTimeOff is null
                    if ((oTimeOff.Type__c == 'Closed' && (nTimeOff.Start_Date__c != oTimeOff.Start_Date__c || nTimeOff.End_Date__c != oTimeOff.End_Date__c || Trigger.isDelete)) || 
                        (oTimeOff.Type__c == 'Submit' && (nTimeOff.End_Date__c != oTimeOff.End_Date__c || Trigger.isDelete))) {
                        nTimeOff.addError('Submitted records cannot be moved or deleted anymore. Please contact your administrator!');
                    }
                    else { // it's all ok, we move an open record
                        set_timeOffIds.add(nTimeOff.Id);
                    }
                }  
            }
            else {
                set_timeOffIds.add(nTimeOff.Id);
            }

        }
        
        /*
        * Determine corresponding event ids and build up a map of events
        */
        
        // Query events to be changed
        List<Event> list_events = [select Id, Subject, Description, StartDateTime, EndDateTime, Related_Id__c 
                                    from Event 
                                    where Related_Id__c in :set_timeOffIds];
                                    
        Map<Id, List<Event>> map_eventsByTimeOffId = new Map<Id, List<Event>>();
        
        // Build map
        for (Event e : list_events) {
            
            List<Event> list_tmpEvents;
            
            // if we have one time off record link to several events 
            // this should not happen in practice, let's only stick with the population of a map pattern!!!
            if (map_eventsByTimeOffId.containsKey(e.Related_Id__c)) {
                list_tmpEvents = map_eventsByTimeOffId.get(e.Related_Id__c);
            }
            else { // normal case
                list_tmpEvents = new List<Event>();
            }
            // add to temporary list
            list_tmpEvents.add(e);
            
            // add the list to current time off record
            map_eventsByTimeOffId.put(e.Related_Id__c, list_tmpEvents);
            
        }
        
        // Let's free up the list_events, don't use it anymore, so the garbage collector can delete it
        list_events.clear();
        
        /*
        * Update events per call report
        */
        
        List<Event> list_changedEvents = new List<Event>(); 
        
        // collect a list of events to update or delete
        for (Time_off_Territory__c t : list_triggerObjects){
            // As we have our map, we can now pick the event from the map based on the time off id
            
            List<Event> list_tmpEvents = map_eventsByTimeOffId.get(t.Id);
            
            // Update all events in the list with the information of the current time off record
            if (list_tmpEvents != null) {
                for (Event e : list_tmpEvents) {
                    
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

                    
                    e.Subject=subject;
                    e.Type = 'Time Off';
                    //e.WhatId = t.Id;
                    e.OwnerId = t.OwnerId;
                    e.Related_Id__c = t.Id;
                    e.Description = description;
                    
                    e.StartDateTime = DateTime.newInstanceGmt(t.Start_Date__c.year(),t.Start_Date__c.month(),t.Start_Date__c.day());
                    e.EndDateTime = DateTime.newInstanceGmt(t.End_Date__c.year(),t.End_Date__c.month(),t.End_Date__c.day());
                    
                    // add event to update list
                    list_changedEvents.add(e);
                }
            }   
            
        }
        
        // Delete or update the events based on is trigger update or delete
        
        if (Trigger.isUpdate) {
            update list_changedEvents;
        }
        else {
            delete list_changedEvents;
        }
    
    } // End If: Only update events if call report is initiating
            
            
}