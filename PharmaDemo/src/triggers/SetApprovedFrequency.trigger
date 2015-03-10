trigger SetApprovedFrequency on TF__c ( before update) {
        for (TF__c newTF : Trigger.new) {
        if (newTF.status__c == 'Validated') {
            newTF.Frequency__c = newTF.Proposed_Frequency__c;
//            newTF.Actual_Calls__c = 8;
            }    
        }    
    }