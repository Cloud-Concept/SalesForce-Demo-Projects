public class LeaveRequestExtension
{
  public Leave_Request__c req { get; set; }
  public ApexPages.StandardController stdController { get; set; }

  public LeaveRequestExtension(ApexPages.StandardController c)
  {
    this.stdController = c;
    this.req           = (Leave_Request__c)c.getRecord();
    if (this.req.From__c == null) this.req.From__c = Date.today().addDays(1);
    if (this.req.To__c == null) this.req.To__c = Date.today().addDays(2);
  }
  
  public String getFormattedFrom()
  {
    return this.req.From__c.format();
  }
  
  public String getFormattedTo()
  {
    return this.req.To__c.format();
  }
  
  public PageReference save()
  {
    Boolean newrecord = false;
    if(stdController.getId() == null) newrecord = true;
    this.stdController.save();
    //DVP : Auto Submit for Approval
      try {
          if(newrecord) {
            // create the new approval request to submit
            Approval.ProcessSubmitRequest areq = new Approval.ProcessSubmitRequest();
            areq.setComments('Submitted for approval. Please approve.');
            areq.setObjectId((String)this.stdController.getRecord().get('Id'));
            // submit the approval request for processing
            Approval.ProcessResult result = Approval.process(areq);
          }
      } catch(Exception ex) {
          //do nothing
      }
    PageReference pageRef = Page.mobile_leaverequest;
    pageRef.getParameters().put('id', (String)this.stdController.getRecord().get('Id'));
    return pageRef.setRedirect(true);
  }
  
  public PageReference cancel()
  {
    this.stdController.cancel();
    PageReference pageRef;
    if (this.stdController.getRecord().get('Id') != null) {
      pageRef = Page.mobile_leaverequest;
      pageRef.getParameters().put('id', (String)this.stdController.getRecord().get('Id'));
    } else {
    	pageRef = Page.mobile_leaverequests;
    }
    return pageRef.setRedirect(true);
  }

}