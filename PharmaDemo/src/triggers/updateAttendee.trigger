trigger updateAttendee on Call_Report__c (before update) {

    
    Map<Id, Call_Report__c> CRIds = new Map<Id, Call_Report__c>();

    // Trigger.new is a list of the Accounts that will be updated
    // This loop iterates over the list, and adds any that have new
    // addresses to the acctsWithNewAddresses map.

    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if ( (Trigger.old[i].CallDate__c != Trigger.new[i].CallDate__c)
             || (Trigger.old[i].Call_Notes__c != Trigger.new[i].Call_Notes__c)
             || (Trigger.old[i].Type__c != Trigger.new[i].Type__c)
             || (Trigger.old[i].Next_Call_Objective__c != Trigger.new[i].Next_Call_Objective__c)) {

            CRIds.put(Trigger.old[i].id, Trigger.new[i]);
        }
    }

    List<Call_Attendees__c> updatedAttendees = new List<Call_Attendees__c>();

    //Here we can see two syntatic features of Apex:
    // 1) iterating over an embedded SOQL query
    // 2) binding an array directly to a SOQL query with 'in'

    for (Call_Attendees__c ca : [SELECT id, Call_Report__c, Call_Notes__c, Next_Call_Objective__c, Call_Date__c, Type__c FROM Call_Attendees__c WHERE Call_Report__c in :CRIds.keySet()]) {

        Call_Report__c CR = CRIds.get(ca.Call_Report__c);
        ca.Call_Notes__c = CR.Call_Notes__c;
        ca.Next_Call_Objective__c = CR.Next_Call_Objective__c;
        ca.Call_Date__c = CR.CallDate__c;
        ca.Type__c = CR.Type__c;        

        // Rather than insert the contacts individually, add the
        // contacts to a list and bulk insert it. This makes the
        // trigger run faster and allows us to avoid hitting the
        // governor limit on DML statements

        updatedAttendees.add(ca);
    }       

    update updatedAttendees;
}