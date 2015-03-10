trigger Apply_Update on Update_Log__c (after update) {

       Set<Id> accountIds = new Set<Id>();

       //Loop through the Updates and build a list of AccountIds
       for(Update_Log__c ul: Trigger.new){
          if (ul.Update_applied__c) 
           accountIds.add(ul.account__c);
       } 
       //Return the SOQL query into a Map object for easy retrieval by Account Id
       Map<Id, Account> accountMap = new Map<Id, Account>([select Id, name, site, parentid, billingstreet, billingcity, billingcountry, billingpostalcode from Account where Id IN :accountIds]);

       //Now loop through the Trigger.new array of Updates and update the Accounts.
       for(Update_Log__c ul:Trigger.new){
          Account a = accountMap.get(ul.Account__c);
          if (ul.Conflicting_field__c == 'Account Name'){
             a.name=ul.Rejected_value__c;
          }
          else if (ul.Conflicting_field__c == 'Account Site'){
             a.site=ul.Rejected_value__c;
          }     
          else if (ul.Conflicting_field__c == 'Parent Account'){
             a.parentid=ul.Rejected_refId__c;
          }     
          else if (ul.Conflicting_field__c == 'Billing Street'){
             a.billingstreet=ul.Rejected_value__c;
          }     
          else if (ul.Conflicting_field__c == 'Billing City'){
             a.billingcity=ul.Rejected_value__c;
          }     
          else if (ul.Conflicting_field__c == 'Billing Postal Code'){
             a.billingpostalcode=ul.Rejected_value__c;
          }     
          else if (ul.Conflicting_field__c == 'Billing Country'){
             a.billingcountry=ul.Rejected_value__c;
          }  
          Account acct = accountMap.remove(ul.Account__c);
          accountMap.put(ul.Account__c,a);
       } 
        
       //Get all the Accounts we need to update into a List and update them from the Map we created above
       Account[] accounts =[select Id, name, site, parentid, billingstreet, billingcity, billingcountry, billingpostalcode from Account where Id IN :accountIds];
       Account[] accountsToUpdate = new Account[0];
       for (Account a: accounts){
          Account b = accountMap.get(a.Id);
          a=b; 
          accountsToUpdate.add(a);
       }    
       // Update the account records  
       try {
          Database.update(accountsToUpdate);
       }
       catch (System.DmlException e) {
          System.debug(e);
       } 
}