public with sharing class ExtCreateDepartments {

  private final ApexPages.standardController stdCtrl;  
    private final Account parentAccount;
    
    private List<Account> list_departments;
    
    private Id departmentRecordTypeId = [select Id from RecordType where SobjectType = 'Account' and DeveloperName = 'Department'].Id;

  public ExtCreateDepartments(ApexPages.StandardController stdCtrl) {
        this.stdCtrl = stdCtrl;
  
    this.parentAccount = [select Id, Name, ParentId, Brick__c, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry from Account where id = :stdCtrl.getRecord().Id];
    this.list_departments = new List<Account>();
    addDepartment();

  }
  
  private void addDepartment() {
    Account dp = new Account();
    dp.ParentId = this.parentAccount.Id;
    dp.Name = this.parentAccount.Name;
    dp.RecordTypeId = departmentRecordTypeId;
    dp.BillingStreet = this.parentAccount.BillingStreet;
    dp.BillingCity = this.parentAccount.BillingCity;
    dp.BillingPostalCode = this.parentAccount.BillingPostalCode;
    dp.BillingState = this.parentAccount.BillingState;
    dp.BillingCountry = this.parentAccount.BillingCountry;
    dp.Brick__c = this.parentAccount.Brick__c;
  
    this.list_departments.add(dp);
  }
  
  public PageReference addNew() {
    addDepartment();
    return null;
  }
  
  public PageReference save() {
    insert this.list_departments;
    
    return new PageReference('/' + parentAccount.id);
  }
  
  public List<Account> getDepartments() {
    return this.list_departments;
  }
  
  public void setDepartments(List<Account> dps) {
    this.list_departments = dps;
  }
  

}