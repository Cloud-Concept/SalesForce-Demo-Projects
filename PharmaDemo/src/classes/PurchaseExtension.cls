public class PurchaseExtension
{
  public Purchase_Requisition__c item { get; set; }
  public ApexPages.StandardController stdController { get; set; }
  public String smallPhotoUrl { get; set; }
  
  public PurchaseExtension(ApexPages.StandardController c)
  {
    this.stdController = c;
    this.item          = (Purchase_Requisition__c)c.getRecord();
    if (item.OwnerId != null && String.valueOf(item.OwnerId).startsWith('005'))
      this.smallPhotoUrl = [Select SmallPhotoUrl From User Where Id = :item.OwnerId].SmallPhotoUrl;
    if (item.OwnerId == null) item.OwnerId = UserInfo.getUserId();
  }
  
  public String getFormattedStart()
  {
  	if (this.item.Starting_Date__c == null) return '';
    return this.item.Starting_Date__c.format();
  }
  
  public String getFormattedEnd()
  {
    if (this.item.Ending_Date__c == null) return '';
    return this.item.Ending_Date__c.format();
  }
  
  public PageReference save()
  {
    this.stdController.save();      
    PageReference pageRef = Page.mobile_purchase;
    pageRef.getParameters().put('id', (String)this.stdController.getRecord().get('Id'));
    return pageRef.setRedirect(true);
  }
   
   
  public PageReference sendToSAP() {
  	return null;
  	/**
       PageReference pageRef = Page.mobile_purchase;
       try {
        String endpointUrl = 'https://castironpoc.w2k.nestle.net/createPurchaseRequisition?purchaseRequisitionId='+(String)this.stdController.getRecord().get('Id');
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpointUrl);
        req.setTimeout(60000);            
        //send the request
        Http http = new Http();
        HttpResponse res = http.send(req);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, res.getBody()));
      } catch(Exception ex) {
          ApexPages.addMessages(ex);
      }
      pageRef.getParameters().put('id', (String)this.stdController.getRecord().get('Id'));
      //return pageRef.setRedirect(true);
      return pageRef;
      **/
  }
  
  public PageReference cancel()
  {
    this.stdController.cancel();
    PageReference pageRef;
    if (this.stdController.getRecord().get('Id') != null) {
      pageRef = Page.mobile_purchase;
      pageRef.getParameters().put('id', (String)this.stdController.getRecord().get('Id'));
    } else {
      pageRef = Page.mobile_purchases;
    }
    return pageRef.setRedirect(true);
  }
}