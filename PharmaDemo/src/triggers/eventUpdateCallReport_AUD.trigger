/**
*
* Updates related call report record when event record gets updated or deleted.
*
* @author: Maic Stohr
* @version: 0.1
*
*/

trigger eventUpdateCallReport_AUD on Event (after delete, after update) {
    
    // Check if call_report__c initiates the update or if it's the event object
    if (TriggerRecursionDefense.initiatingObject == null)
        TriggerRecursionDefense.initiatingObject = 'Event';
        
    if (TriggerRecursionDefense.initiatingObject == 'Event') { // If: Only update call reports if event is initiating
        Set<Id> set_impactedCallReportIds = new Set<Id>();
        
        /*
        * Determine trigger image
        */ 
        
        List<Event> list_triggerObjects;
        
        // based on update or delete
        if (Trigger.isUpdate) {
            list_triggerObjects = Trigger.new;
        }
        else {
            list_triggerObjects = Trigger.old;
        }
        
        /*
        * Prepare impacted set of call report ids
        */
        
        for (Event nEvent : list_triggerObjects) {  
            /*
            * Only if it's not a 1:1 otherwise report error that this cannot be moved or deleted
            */
            Event oEvent = Trigger.oldMap.get(nEvent.Id);
            
//            if (nEvent.Type__c == '1:1') {
                // When start date or duration changes we moved the event
                // If delete trigger, we deleted it!
//                if (nEvent.ActivityDateTime != oEvent.ActivityDateTime || oEvent.DurationInMinutes != oEvent.DurationInMinutes || Trigger.isDelete) {
//                    nEvent.addError('1:1 cannot be moved or deleted anymore. Please contact your administrator!');
//                }
//                else { // it's all ok, we move an appointment or change 1:1 fields that are not relevant
//                    set_impactedCallReportIds.add(nEvent.Related_Id__c);
//                }   
//            }
//            else {
                set_impactedCallReportIds.add(nEvent.Related_Id__c);
//            }


        }
        
        // Get a list of all impacted call reports by call report id
        Map<Id, Call_Report__c> map_callReportById = new Map<Id, Call_Report__c>([select Id, Date__c 
                                                                                from Call_Report__c
                                                                                where Id in :set_impactedCallReportIds]);
        
        /*
        * Collect impacted call reports and update them into a list
        */
        List<Call_Report__c> list_impactedCallReports = new List<Call_Report__c>();
        
        for (Event e : list_triggerObjects) {   
            if (map_callReportById.containsKey(e.Related_Id__c)) {
                Call_Report__c tcr = map_callReportById.get(e.Related_Id__c);
                tcr.Date__c = e.ActivityDateTime;
                list_impactedCallReports.add(tcr);
            }

        }
        
        
        // Delete or update the call reports based on is trigger update or delete
        
        if (Trigger.isUpdate) {
            update list_impactedCallReports;
        }
        else {
            delete list_impactedCallReports;
        }
    
    } // End If: Only update call reports if event is initiating

}