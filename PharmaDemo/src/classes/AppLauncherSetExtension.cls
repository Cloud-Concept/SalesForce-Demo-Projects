public class AppLauncherSetExtension
{
  public ApexPages.StandardSetController setCon 
  {
    get 
    {
      if (setCon == null) {
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
          [
            Select Name, Icon__c, Category__c, Url__c
            From AppLauncher__c
            Order by Name
          ]
        ));
      }
      return setCon;
    }
    set;
  }
  public String cat { get; set; }
  
  public Map<String, List<AppLauncher__c>> getApps()
  {
    Map<String, List<AppLauncher__c>> itemMap = new Map<String, List<AppLauncher__c>>();
    for (AppLauncher__c item : (List<AppLauncher__c>)setCon.getRecords()) {
      if (cat == 'All' || cat == item.Category__c) {
        if (item.Category__c == null) item.Category__c = 'None';
        if (!itemMap.containsKey(item.Category__c))
          itemMap.put(item.Category__c, new List<AppLauncher__c>());
        itemMap.get(item.Category__c).add(item);
      }
    }
    return itemMap;
  }
  
  public AppLauncherSetExtension(ApexPages.StandardSetController c)
  {
    cat = ApexPages.currentPage().getParameters().get('category');
    if (cat == null) cat = 'HR';
  }
}