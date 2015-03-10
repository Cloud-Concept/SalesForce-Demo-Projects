public class LeaveBalanceSetExtension
{

  public List<Leave_Balance__c> balances {get;set;}  
   
  public LeaveBalanceSetExtension()
  {
      balances = [
            SELECT BalanceEntitlementQuantity__c,DeductionEndDate__c,DeductionStartDate__c,Id,TimeAccountTypeName__c,TimeAccountType__c
            FROM Leave_Balance__c            
            Where User__c = :UserInfo.getUserId()
          ];
  }  

    
  //DVP : Method that calls Cast Iron / SAP to get the latest Leave Requests and Balances for the current user
  
    public void calloutIbmci() {
		/**
        String empid = [select Id, SAP_EmployeeID__c from User where Id =:UserInfo.getUserId()].SAP_EmployeeID__c;
        String endpointUrl = 'https://castironpoc.w2k.nestle.net/userStatusAndInfo';
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpointUrl+'?EmployeeID='+empid+'&sfid='+UserInfo.getUserId());
        
        //send the request
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        String httpresult = res.getBody();

        if (res.getStatus() == 'Success') {
            System.debug('******** IBM HTTP LR Test ****** :'+res.getBody());
        } else {
            System.debug('Callout failed: ' + res);
        } 
        **/
    }

}