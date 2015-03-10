trigger NameChangeLocation on Location__c (before insert, before update) {
    private Location__c[] newLocations = Trigger.new;
    
    for (Location__c newLocation : newLocations) {
    
//    newLocation.Name = NewLocation.Account_Name__c + ' - ' + NewLocation.Contact_Name__c;
    newLocation.Brick__c = NewLocation.BrickId__c;
    // when it is insert - close the visit


    }
}