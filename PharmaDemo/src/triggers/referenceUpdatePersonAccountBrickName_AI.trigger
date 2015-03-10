/**
*
* Used to actualize Person Account Brickname on Account.
*
* @author: Michael Ohme
* @date: 2009/07/14
*
*/

trigger referenceUpdatePersonAccountBrickName_AI on Location__c (after insert) {
    
    //Sets for unique ids for contact and organisation
    Set<Id> set_contactId = new Set<Id>();
    Set<Id> set_organisationId = new Set<Id>();

    //Collecting all ids from new references
    for (Location__c r : trigger.new){
        set_contactId.add(r.Contact__c);
        set_organisationId.add(r.Account__c);
    }
    
    //Map for contact(person account) and organisation, filled with data for all ids that are used by the trigger
    Map<Id,Contact> map_contact = new Map<Id,Contact>([select Id, AccountId, Account.Person_Account_Brick_Name__c from Contact where Id in :set_contactId]);
    Map<Id,Account> map_organisation = new Map<Id,Account>([select Id, Brick_Name__c from Account where ID in :set_organisationId]);

    //Set for unique account ids that have to be updated
    Set<Id> set_personAccountIds2Update = new Set<Id>();

    
    
    for (Location__c r : trigger.new){

        //Set for unique brick names that are stores on 'Person Account Brick Name'     
        Set<String> set_brickNames = new Set<String>();
        
        //Copy of actual trigger values for customer that is referenced to contact
        Contact c = map_contact.get(r.Contact__c);
        
        //Splitting large string of multiple brick names into single brick names 
        if (c.Account.Person_Account_Brick_Name__c != NULL)
            set_brickNames.addAll(c.Account.Person_Account_Brick_Name__c.split(' '));
                
        //Copy of actual trigger values for organisation that is referenced to account
        Account a = map_organisation.get(r.Account__c);
        
        //Does brick name at organisation exist at Person Account Brick Name?
        if (!set_brickNames.contains(a.Brick_Name__c)) {
            
            //Brick name does not exist and will be appended
            if (c.Account.Person_Account_Brick_Name__c == NULL){
                c.Account.Person_Account_Brick_Name__c = a.Brick_Name__c;
            }
            else
                c.Account.Person_Account_Brick_Name__c += ' ' + a.Brick_Name__c;
            
            //The AccountId is stored to set because there where changes 
            set_personAccountIds2Update.add(c.AccountId);
        }
        
        //Map_contact is updated with new data
        map_contact.put(r.Contact__c, c);
            
    }
    //List to store account informations for updating 
    List<Account> list_personAccounts = new List<Account>();

    //We fetch all accounts where changes have taken place
    for (Account a : [select Id, Person_Account_Brick_Name__c, (select Id from Contacts) from Account where Id in :set_personAccountIds2Update]) {

        //Copy contact from map_contact where id is equal to account.contact.id this can only be one
        Contact c = map_contact.get(a.Contacts[0].Id);
        
        //Copy personal account brick bame from contact reference to account
        a.Person_Account_Brick_Name__c = c.Account.Person_Account_Brick_Name__c;
        
        //Add new account data to list
        list_personAccounts.add(a);
        
    }
    
    //Update Account
    update list_personAccounts;
}