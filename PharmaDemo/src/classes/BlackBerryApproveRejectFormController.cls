/* 
* Developed by Timba Software Corp. www.timbasoftware.com admin@timbasoftware.com
*/ 

/**
* Class that Proccess the form data send by the ApproveReject page.
* @author Bruno Fagundez
*/ 
public with sharing class BlackBerryApproveRejectFormController {
	
	/**
	* Inicialization of enviroment variables
	*/	
	public String WORKITEM_ID { get; set; }
	
	public String Comments;
	
	public String Action;
	
	public Boolean showBackLink {get; set;}
	
	public String ActionStatusMessage { get; set; }
	
	ProcessInstance currentInstance = new ProcessInstance();
	
	ProcessInstanceWorkitem workItem = new ProcessInstanceWorkitem();
	
	/**
	* Constructor
	*/	
	public BlackBerryApproveRejectFormController()
	{	
		
	}
	
	/**
    * This method reads the data sent to the form.
    */  
	public void readFormData()
	{
		
		//Check for CSRF
		//if (ApprovalsUtil.isCSRF(Page.BlackBerryApproveReject)){
		//	ActionStatusMessage = 'Action Rejected';
		//	showBackLink = false;
		//	return;
		//}
		
		// Get parameters sent by get method
		WORKITEM_ID = System.currentPageReference().getParameters().get('id');
		Comments = System.currentPageReference().getParameters().get('comments');
		Action = System.currentPageReference().getParameters().get('action');
		
		if(WORKITEM_ID != null)
		{
			workItem = [ select 
						p.Actor.Name,
						p.ActorId,
						p.ProcessInstance.TargetObjectId, 
						p.ProcessInstance.Id, 
						p.ProcessInstanceId				 
						from ProcessInstanceWorkitem p where p.Id =: WORKITEM_ID];	
				
			currentInstance = [select 
							p.Id,
							p.TargetObject.Name,
							p.TargetObject.Type,
							p.Status,		
							p.TargetObjectId 
							from ProcessInstance p where p.Id =:  workItem.ProcessInstanceId];
		}
		
		if((WORKITEM_ID != null) && (Comments != null) && (Action != null))
		{
			if(action == 'Approve')
			{
				Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
				req2.setWorkitemId(WORKITEM_ID);
				req2.setComments(Comments);
				req2.setAction('Approve');
				
				// Submit the request for approval
				Approval.ProcessResult result2 =  Approval.process(req2);
				
				ActionStatusMessage = 'Item Approved'; 
				showBackLink = false;
			}
			else
			{
				// Reject this!
				Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
				req2.setWorkitemId(WORKITEM_ID);
				req2.setComments(Comments);
				req2.setAction('Reject');
				
				// Submit the request for approval
				Approval.ProcessResult result2 =  Approval.process(req2);
				
				ActionStatusMessage = 'Item Rejected';
				showBackLink = false;		
			}
			
			
		}
		else 
		{
			showBackLink = true;
			ActionStatusMessage = 'Please Review all the fields.';	
		}	
	}
	
	/**
	* Returns the current Object Details
	* @return ObjectDetail
	*/	
	public ObjectDetail getObjDetail()
	{
		ObjectDetail od = new ObjectDetail();
		
		od.Id = currentInstance.TargetObjectId;
		od.Name = currentInstance.TargetObject.Name;
		od.procId = currentInstance.Id;
		od.objType = currentInstance.TargetObject.Type;
		return od;
	}
	
	/**
	* Object Detail Class	
	*/
	public class ObjectDetail 
	{
		public String Id { get; set; }
		public String Name { get; set; }
		public String OwnerName { get; set; }
		public String OwnerId { get; set; }
		public String procId { get; set; }
		public String objType { get; set; }
		
	}
}