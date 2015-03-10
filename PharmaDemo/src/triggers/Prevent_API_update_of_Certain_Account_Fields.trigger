trigger Prevent_API_update_of_Certain_Account_Fields on Account (before update) {

// Detect if its a specific integration point trying to update the Account record.
// Only Sys Admin can update
// Prevent changes for certain fields, and log the change attempts to a custom object, for manual review
// The administrator can later apply rejected changes from the related Log records on the Account if necessary.

string profile= UserInfo.getProfileId();
if (profile!= '00e200000014tznAAA') {
   List<Update_Log__c> log_records = new List<Update_Log__c>();
   for (Integer i=0; i<Trigger.new.size(); i++) {
       Account oldAcct = Trigger.old[i];
       Account newAcct = Trigger.new[i];
       // Do not allow the API to change an existing account name
       if (oldAcct.name != newAcct.name && oldAcct.name != null){
            log_records.Add(new Update_Log__c(Account__c = oldAcct.id, Conflicting_field__c = 'Account Name', Current_value__c=oldAcct.name, Rejected_value__c=newAcct.name));
            newAcct.name = oldAcct.name;
       }     
       // Do not allow the API to change an existing account site
       if (oldAcct.site != newAcct.site && oldAcct.site != null){
            log_records.Add(new Update_Log__c(Account__c = oldAcct.id, Conflicting_field__c = 'Account Site', Current_value__c=oldAcct.site, Rejected_value__c=newAcct.site));
            newAcct.site = oldAcct.site;
       }     
       // Do not allow the API to change an existing parent hierarchy link
       if (oldAcct.parentid != newAcct.parentid && oldAcct.parentid !=null){
            Account oldname = [SELECT name FROM account WHERE Id= : oldAcct.parentid];
            Account newname = [SELECT name FROM account WHERE Id= : newAcct.parentid];
            log_records.Add(new Update_Log__c(Account__c = oldAcct.id, Conflicting_field__c = 'Parent Account', Current_value__c=oldname.name, Rejected_value__c=newname.name, Rejected_refId__c=newAcct.parentId));
            newAcct.parentid = oldAcct.parentid;
       }     
       // Do not allow the API to change an existing billing/visiting address
       if (oldAcct.billingstreet != newAcct.billingstreet && oldAcct.billingstreet != null){
            log_records.Add(new Update_Log__c(Account__c = oldAcct.id, Conflicting_field__c = 'Billing Street', Current_value__c=oldAcct.billingstreet, Rejected_value__c=newAcct.billingstreet));
            newAcct.billingstreet = oldAcct.billingstreet;
       }     
       if (oldAcct.billingcity != newAcct.billingcity && oldAcct.billingcity != null){
            log_records.Add(new Update_Log__c(Account__c = oldAcct.id, Conflicting_field__c = 'BillingCity', Current_value__c=oldAcct.billingcity, Rejected_value__c=newAcct.billingcity));
            newAcct.billingcity = oldAcct.billingcity;
       }     
       if (oldAcct.billingcountry != newAcct.billingcountry && oldAcct.billingcountry != null){
            log_records.Add(new Update_Log__c(Account__c = oldAcct.id, Conflicting_field__c = 'BillingCountry', Current_value__c=oldAcct.billingcountry, Rejected_value__c=newAcct.billingcountry));
            newAcct.billingcountry = oldAcct.billingcountry;
       }     
       if (oldAcct.billingpostalcode != newAcct.billingpostalcode && oldAcct.billingpostalcode != null){
            log_records.Add(new Update_Log__c(Account__c = oldAcct.id, Conflicting_field__c = 'Billing Postal Code', Current_value__c=oldAcct.billingpostalcode, Rejected_value__c=newAcct.billingpostalcode));
            newAcct.billingpostalcode = oldAcct.billingpostalcode;
       }     
       
   }
   //Insert Log Records and catch exceptions nicely
   try {
   Database.insert(log_records);
   }
   catch (System.DmlException e) {
   System.debug(e);
   }    
}
}