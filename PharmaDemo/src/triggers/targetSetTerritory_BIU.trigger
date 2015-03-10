/*
    - EMEA_SOW_Solvay_004 
    - Copy territory name of Med Rep into field Territory__c
    
    @author: Carsten Fichte
    @date: 2008/09/02
*/


trigger targetSetTerritory_BIU on Target__c (before insert, before update) {

 final Target__c[] updatedTarget = Trigger.new;
      
   for (Target__c tar : updatedTarget) {
        if (tar.MedRep__c != null){
        
        UserTerritory[] uTerr = [Select TerritoryId From UserTerritory where UserId =:tar.MedRep__c];
       
    for (UserTerritory userTerritory : uTerr) {    
        
        if (uTerr.size() >0) {
     System.debug('=== Territory Id is:'+ userTerritory.TerritoryId);   
        Territory [] terr = [Select Name From Territory  where Id =: userTerritory.TerritoryId]; 
       
         for (Territory territory : terr) {
            String territoryName = territory.Name;
     System.debug('=== Territory Name is:'+ territory.Name);
            if (territoryName == null)
                continue;
            tar.Territory__c = territoryName;
            }     
         }
       }   
     }
   }
}