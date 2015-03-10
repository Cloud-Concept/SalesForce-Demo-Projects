/**
*
* Used to update Person Account Brickname after deletion of references on Account.
*
* @author: Frederic Faisst
* @date: 2009/07/16
*
*/

trigger referenceUpdatePersonAccountBrickName_AD on Location__c (after delete) {

    //Set for unique contact Ids
    Set<Id> set_contactId = new Set<Id>();

    //Get Customer Ids
    for (Location__c r : Trigger.old){
        set_contactId.add(r.Contact__c);
    }
    
        Map<String, String> map_brickNames = new Map<String, String>();
        Set<String> set_customerBrick = new Set<String>();
        
        //Get Person Accounts with the corresponding references
        for (Location__c [] ref_User: [select r.Contact__c, r.Contact__r.AccountId, r.Id, r.Account__r.Brick_Name__c from Location__c r where r.Contact__c in :set_contactId and IsDeleted = false]){
                //Concatenate Person Account Ids with reference Bricknames separated by ','
                for (Location__c ref: ref_User){
                    set_customerBrick.add(ref.Contact__r.AccountId + ',' + ref.Account__r.Brick_Name__c);
                }
        }
        
        Set<String> set_personAccountIds2Update = new Set<String>();
        String[] d = new String[2];
        
            
        for (String a: set_customerBrick){
            d = a.split(',');
            String tmp_brick = '';
            
            //Concatenation of Bricknames and fill set_personAccountIds2Update with person Account Id
            if(map_brickNames.containsKey(d[0]))
                tmp_brick = map_brickNames.get(d[0]);
            tmp_brick += ' '+ d[1];
            map_brickNames.put(d[0], tmp_brick);
            set_personAccountIds2Update.add(d[0]);
        }
                
        List<Account> list_personAccounts = new List<Account>();
            
        //Get Person Accounts to update - Update Person Account Brick Name with result of concatenation in prior step. 
        for (Account a : [select Id, Person_Account_Brick_Name__c from Account where Id in :set_personAccountIds2Update]) {
            a.Person_Account_Brick_Name__c = map_brickNames.get(a.Id);
            list_personAccounts.add(a);
        }
        update list_personAccounts;
}