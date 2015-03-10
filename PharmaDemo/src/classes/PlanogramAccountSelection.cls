public with sharing class PlanogramAccountSelection {

    public List<Account> allAccounts {get; set;}
    public String searchString {get; set;}
    public Integer resultsPerPage {get; set;}
    
    
    public PlanogramAccountSelection() {
        allAccounts = [select id, Name, BillingStreet, BillingCity, BillingState, Phone, Target__c, Brick_Name__c, Target_Calls__c, Actual_Calls__c from Account where RecordTypeId='012200000009bSCAAY' order by Name Asc];
        searchString = '';      
        resultsPerPage = 10;
        
        
    }
    
    public List<Account> getAccResults() {
        List<Account> results = new List<Account>();
        if(searchString == '') {
            for(Account a : allAccounts) {
                results.add(a);
                if(results.size() >= resultsPerPage) {
                    break;
                }
                
            }
        } else {
            for(Account a : allAccounts) {
                if(a.Name.toUpperCase().contains(searchString.toUpperCase())) {
                    results.add(a);
                    if(results.size() >= resultsPerPage) {
                        break;
                    }
                }                               
            }                               
        }
        return results;
    }
    
    
}