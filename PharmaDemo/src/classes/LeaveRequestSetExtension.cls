public class LeaveRequestSetExtension
{
    
    public String castironurl {get;set;}

  public ApexPages.StandardSetController setCon 
  {
  	get 
  	{
  		if (setCon == null) {
  			setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
          [
            Select Name, Owner.Name, Approval_Status__c, Approver__c, Approver__r.Name, Approver__r.SmallPhotoUrl, From__c, Leave_Type__c, Notes__c, Short_Title__c, To__c
            From Leave_Request__c
            Where OwnerId = :UserInfo.getUserId() order by From__c desc
          ]
  			));
  		}
  		return setCon;
  	}
  	set;
  }
  public String status { get; set; }
  
  public Map<String, List<Leave_Request__c>> getRequests()
  {
  	Map<String, List<Leave_Request__c>> l = new Map<String, List<Leave_Request__c>>();
  	for (Leave_Request__c lr : (List<Leave_Request__c>)setCon.getRecords()) {
  		if (status == 'All' || status == lr.Approval_Status__c) {
  			if (lr.Approval_Status__c == null) lr.Approval_Status__c = 'None';
	  		if (!l.containsKey(lr.Approval_Status__c))
	  		  l.put(lr.Approval_Status__c, new List<Leave_Request__c>());
	  		l.get(lr.Approval_Status__c).add(lr);
  		}
  	}
  	return l;
  }

  public LeaveRequestSetExtension(ApexPages.StandardSetController c)
  {
    status = ApexPages.currentPage().getParameters().get('status');
    if (status == null) status = 'Pending';
    
    //just provide the UI with the CI url, it can do the callout itself
    //String empid = [select Id, SAP_EmployeeID__c from User where Id =:UserInfo.getUserId()].SAP_EmployeeID__c;
    //String endpointUrl = 'https://castironpoc.w2k.nestle.net/userStatusAndInfo';
    //castironurl =  endpointUrl+'?EmployeeID='+empid+'&sfid='+UserInfo.getUserId();
  }
    
  //DVP : Method that calls Cast Iron / SAP to get the latest Leave Requests and Balances for the current user
  
    public void calloutIbmci() {
		/**
        //get the current leave balances, we'll delete those after the callout
        //List<Leave_Balance__c> bls = [select Id from Leave_Balance__c where User__c =:UserInfo.getUserId()];
        
        String empid = [select Id, SAP_EmployeeID__c from User where Id =:UserInfo.getUserId()].SAP_EmployeeID__c;
        String endpointUrl = 'https://castironpoc.w2k.nestle.net/userStatusAndInfo';
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setTimeout(60000);
        req.setEndpoint(endpointUrl+'?EmployeeID='+empid+'&sfid='+UserInfo.getUserId());
        
        //send the request
        Http http = new Http();
        System.debug('Callout to Cast Iron : ' + endpointUrl+'?EmployeeID='+empid+'&sfid='+UserInfo.getUserId());
        HttpResponse res = http.send(req);
        
        String httpresult = res.getBody();

        if (res.getStatus() == 'Success') {
            System.debug('******** IBM HTTP LR Test ****** :'+res.getBody());
        } else {
            System.debug('Callout failed: ' + res);
        } 
        
        //remove all old Leave Balances        
        //delete bls;
       **/ 
    }
	
}