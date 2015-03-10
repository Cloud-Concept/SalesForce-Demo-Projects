trigger removeExtraContacts on Call_Summary_sigcap_WM__c (before insert, before update) {
    For (Call_Summary_sigcap_WM__c ncall:Trigger.new){
                 
        If (nCall.Contact_1__c == nCall.Contact_2__c) {   
        // Set contact 2 and 3 to null
        ncall.Contact_2__c = null;
        ncall.Contact_3__c = null;
        }
    }
    }