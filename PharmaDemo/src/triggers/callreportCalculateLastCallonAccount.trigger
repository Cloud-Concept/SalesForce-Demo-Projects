/**
*
* Used to calculate actual calls in Target Frequence object (TF__c).
*
* @author: Maic Stohr
* @date: 2009/07/01
*
*/

trigger callreportCalculateLastCallonAccount on Call_Report__c (before insert, before update) {

    
    // Set of unique ids of targets/customers to be updated of format: Target__c|Customer__c
    Set <String> set_AccountIds = new Set <String>(); 
    
    // Map of target frequency id to counter
    Map<String,Account> map_counterByAccountId = new Map<String,Account>();
    
    for (Call_Report__c c : Trigger.new) {
        
        // we only count 1:1 records and not yet counted
        if (c.Type__c == '1:1' && !c.Counted_for_Account_Frequency__c)
         {
            // Identifies target frequency via Unique_Id__c field
//            String strAccountId = ((String) c.Location__c).substring(0,15);
              String strAccountId = c.Location__c;
            
            // Collect all unique target frequencies
            set_AccountIds.add(strAccountId);
            
            Account counterFreq;
            
            // If a previous call report record of this trigger batched for same target frequency
            if (map_counterByAccountId.containsKey(strAccountId)) {
                 counterFreq = map_counterByAccountId.get(strAccountId);
                 counterFreq.Actual_Calls__c++;
                 
                 // Remember last call date
                 if (counterFreq.Last_Call_Report_Date__c < c.CallDate__c)
                    counterFreq.Last_Call_Report_Date__c = c.CallDate__c;
            }
            else {
                counterFreq = new Account();
//                counterFreq.Id = strAccountId;
                counterFreq.Actual_Calls__c = 1;
                counterFreq.Last_Call_Report_Date__c = c.CallDate__c;
            }
            
            // update counter for this target frequency
            map_counterByAccountId.put(strAccountId, counterFreq);
            
            c.Counted_for_Account_Frequency__c = true;
            
        }
    }
    

    /*
    * Update target frequency records
    */ 
    
    List<Account> list_impactedAccounts = new List<Account>();
    
    // Query all impacted target frequency records and update into a list
    for (Account acc : [select Id, Actual_Calls__c, Last_Call_Report_Date__c
                    from Account
                    where Id in :set_AccountIds]) {

        Account tmpTargetFreq = map_counterByAccountId.get(acc.Id);

        // Increment actual calls counter 
        if (acc.Actual_Calls__c == null) { // In case actual calls is null, initialize with 0 
         acc.Actual_Calls__c = 0;     
        } 
        acc.Actual_Calls__c += tmpTargetFreq.Actual_Calls__c;
        
        // Set last call date
        if (acc.Last_Call_Report_Date__c == null || acc.Last_Call_Report_Date__c < tmpTargetFreq.Last_Call_Report_Date__c)
            acc.Last_Call_Report_Date__c = tmpTargetFreq.Last_Call_Report_Date__c;

             
        
        list_impactedAccounts.add(acc);
    }
    
    // Update in database
    update list_impactedAccounts;
}