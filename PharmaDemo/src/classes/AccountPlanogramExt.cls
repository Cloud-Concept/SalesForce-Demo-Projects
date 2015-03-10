public with sharing class AccountPlanogramExt {
    private final Account act;
    public List<Planogram__c> planogramEntries {get; set;}
    
    public AccountPlanogramExt(ApexPages.StandardController controller) {
        act = (Account) controller.getRecord();
        planogramEntries = new List<Planogram__c>();
        Account a = [Select (Select Id, Name, Index__c, Product_Group_Image__c, Product__c, Space_Slot_Number__c From Planograms__r order by Index__c ASC) From Account a where id=:act.id];
        for(Planogram__c planogram : a.Planograms__r) {
            planogramEntries.add(planogram);
        }
        
        
    }

}