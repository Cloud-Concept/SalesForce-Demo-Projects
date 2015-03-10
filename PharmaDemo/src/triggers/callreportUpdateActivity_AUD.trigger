/**
*
* Updates related event record when call report record gets updated or deleted.
*
* @author: Maic Stohr
* @version: 0.1
*
*/

trigger callreportUpdateActivity_AUD on Call_Report__c (after delete, after update) {

    // Check if call_report__c initiates the update or if it's the event object
    if (TriggerRecursionDefense.initiatingObject == null)
        TriggerRecursionDefense.initiatingObject = 'Call_Report__c';
        
    // Check if map_oldCallReports is already set
    if (TriggerRecursionDefense.map_oldCallReports == null)
        TriggerRecursionDefense.map_oldCallReports = Trigger.oldMap;
        
    if (TriggerRecursionDefense.initiatingObject == 'Call_Report__c') { // If: Only update events if call report is initiating

        /*
        * Determine trigger image
        */ 
        
        List<Call_Report__c> list_triggerObjects;
        
        // based on update or delete
        if (Trigger.isUpdate) {
            list_triggerObjects = Trigger.new;
        }
        else {
            list_triggerObjects = Trigger.old;
        }
        
    
        Set<Id> set_callReportIds = new Set<Id>(); // contains all call report ids that are changed by this trigger
        
        /*
        * Determine call report ids and collect in set setCallReportIds
        */
        
        for (Call_Report__c nCall : list_triggerObjects) {
            /*
            * Only if it's not a 1:1 otherwise report error that this cannot be moved or deleted
            */
            Call_Report__c oCall = TriggerRecursionDefense.map_oldCallReports.get(nCall.Id);
            
//            if (nCall.Type__c == '1:1') {
                // When start date or duration changes we moved the event
                // If delete trigger, we deleted it!
//                if (oCall.Type__c == '1:1' && (nCall.Date__c != oCall.Date__c || nCall.Duration__c != oCall.Duration__c || Trigger.isDelete)) {
//                    nCall.addError('1:1 cannot be moved or deleted anymore. Please contact your administrator!');
//                }
//                else { // it's all ok, we move an appointment or change 1:1 fields that are not relevant
                    set_callReportIds.add(nCall.Id);
//                }   
//            }
//            else {
                set_callReportIds.add(nCall.Id);
//            }

        }
        
        /*
        * Determine corresponding event ids and build up a map of events
        */
        
        // Query events to be changed
        List<Event> list_events = [select Id, Subject, ActivityDateTime, DurationInMinutes, CallReportId__c 
                                    from Event 
                                    where CallReportId__c in :set_callReportIds];
                                               
        Map<Id, List<Event>> map_eventsByCallReportId = new Map<Id, List<Event>>();        
        
        // Build map
        for (Event e : list_events) {
            
            List<Event> list_tmpEvents;
            
            // if we have one call report link to several events 
            // this should not happen in practice, let's only stick with the population of a map pattern!!!
            if (map_eventsByCallReportId.containsKey(e.CallReportId__c)) {
                list_tmpEvents = map_eventsByCallReportId.get(e.CallReportId__c);
            }
            else { // normal case
                list_tmpEvents = new List<Event>();
            }
            // add to temporary list
            list_tmpEvents.add(e);
            
            // add the list to current call report
            map_eventsByCallReportId.put(e.CallReportId__c, list_tmpEvents);
            
        }
        
        // Let's free up the list_events, don't use it anymore, so the garbage collector can delete it
        list_events.clear();
        
        /*
        * Update events per call report
        */
        
        List<Event> list_changedEvents = new List<Event>(); // Remember we have only call reports times # of events by call report <= 1000 entries max we can change here
        
        // collect a list of events to update or delete
        for (Call_Report__c nCall : list_triggerObjects){
            // As we have our map, we can now pick the event from the map based on the call report id
            
            List<Event> list_tmpEvents = map_eventsByCallReportId.get(nCall.Id);
            
            // Update all events in the list with the information of the current call report
            if (list_tmpEvents != null) {
                for (Event e : list_tmpEvents) {
                    e.WhoId = nCall.Contact__c;
                    e.WhatId= nCall.Location__c;
                    e.Subject = nCall.Type__c;
                    e.ActivityDateTime = nCall.Date__c;
                    e.Type1__c = nCall.Type__c;
                    e.DurationInMinutes = Integer.valueOf(nCall.Duration__c);
                    e.OwnerId= nCall.User__c;
                    
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