public class PurchaseSetController
{
  public ApexPages.StandardSetController setCon 
  {
    get 
    {
      if (setCon == null) {
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
          [
            Select Resource_Project_Name__c, Starting_Date__c, Ending_Date__c, Cost_Center__c, Vendor__r.Name, Approval_Status__c
            From Purchase_Requisition__c
            Where OwnerId = :UserInfo.getUserId()
          ]
        ));
      }
      return setCon;
    }
    set;
  }
  public String status { get; set; }
  
  public Map<String, List<Purchase_Requisition__c>> getPurchases()
  {
    Map<String, List<Purchase_Requisition__c>> itemMap = new Map<String, List<Purchase_Requisition__c>>();
    for (Purchase_Requisition__c item : (List<Purchase_Requisition__c>)setCon.getRecords()) {
      if (status == 'All' || status == item.Approval_Status__c) {
        if (item.Approval_Status__c == null) item.Approval_Status__c = 'None';
        if (!itemMap.containsKey(item.Approval_Status__c))
          itemMap.put(item.Approval_Status__c, new List<Purchase_Requisition__c>());
        itemMap.get(item.Approval_Status__c).add(item);
      }
    }
    return itemMap;
  }
  
  public PurchaseSetController(ApexPages.StandardSetController c)
  {
    status = ApexPages.currentPage().getParameters().get('status');
    if (status == null) status = 'Draft';
  }
}