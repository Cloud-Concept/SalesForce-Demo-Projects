/**
*
* Used to calculate actual calls in Target Frequence object (TF__c).
*
* @author: Maic Stohr
* @date: 2009/07/01
*
*/

trigger callreportCalculateTargetActualCalls_AUI on Call_Report__c (before insert, before update) {

    /*
    * Determine target frequencies and count call reports by target frequency 
    */
    
    // Set of unique ids of targets/customers to be updated of format: Target__c|Customer__c
    Set <String> set_strTargetFrequencyIds = new Set <String>(); 
    
    // Map of target frequency id to counter
    Map<String,TF__c> map_counterByTargetFrequencyId = new Map<String,TF__c>();
    
    for (Call_Report__c c : trigger.new) {
        
        // we only count 1:1 records and not yet counted
        if (c.Type__c == '1:1' && !c.Counted_For_Target_Actual__c) {
            
            // Do we have a target set for this user? Maybe its an administration user
            if (c.user__c != null) {
                // Identifies target frequency via Unique_Id__c field
                String strTargetFrequencyId = ((String) c.user__c).substring(0,15) + '|' + ((String) c.Contact__c).substring(0,15);
                
                // Collect all unique target frequencies
                set_strTargetFrequencyIds.add(strTargetFrequencyId);
                
                TF__c counterTargetFreq;
                
                // If a previous call report record of this trigger batched for same target frequency
                if (map_counterByTargetFrequencyId.containsKey(strTargetFrequencyId)) {
                     counterTargetFreq = map_counterByTargetFrequencyId.get(strTargetFrequencyId);
                     counterTargetFreq.Actual_Calls__c++;
                     
                     // Remember last call date
                     if (counterTargetFreq.Last_Call_Report_Date__c < c.CallDate__c)
                        counterTargetFreq.Last_Call_Report_Date__c = c.CallDate__c;
                }
                else {
                    counterTargetFreq = new TF__c();
                    counterTargetFreq.Unique_Id__c = strTargetFrequencyId;
                    counterTargetFreq.Actual_Calls__c = 1;
                    counterTargetFreq.Last_Call_Report_Date__c = c.CallDate__c;
                }
                
                // update counter for this target frequency
                map_counterByTargetFrequencyId.put(strTargetFrequencyId, counterTargetFreq);
                
                c.Counted_For_Target_Actual__c = true;
            }
            
        }
    }
        

    /*
    * Update target frequency records
    */ 
    
    List<TF__c> list_impactedTgtFrequencies = new List<TF__c>();
    
    // Query all impacted target frequency records and update into a list
    for (TF__c tf : [select Id, Actual_Calls__c, Unique_Id__c, Last_Call_Report_Date__c
                    from TF__c
                    where Unique_Id__c in :set_strTargetFrequencyIds]) {

        TF__c tmpTargetFreq = map_counterByTargetFrequencyId.get(tf.Unique_Id__c);

        // Increment actual calls counter
        if (tf.Actual_Calls__c == null) { // In case actual calls is null, initialize with 0
            tf.Actual_Calls__c = 0;
        }       
        tf.Actual_Calls__c += tmpTargetFreq.Actual_Calls__c;
        
        // Set last call date
        if (tf.Last_Call_Report_Date__c == null || tf.Last_Call_Report_Date__c < tmpTargetFreq.Last_Call_Report_Date__c)
            tf.Last_Call_Report_Date__c = tmpTargetFreq.Last_Call_Report_Date__c;
        
        list_impactedTgtFrequencies.add(tf);
    }
    
    // Update in database
    update list_impactedTgtFrequencies;
}