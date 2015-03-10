/*
* Developed by Timba Software Corp. www.timbasoftware.com admin@timbasoftware.com
*/ 

/**
* @author Guillermo Lacordelle
*/ 
public with sharing class BlackBerryApprovalListController
{
	
	private List<ApprovalItemCollection> approvalItemsCollection;
		
	private Id userId = UserInfo.getUserId();
	
	public Boolean noRecordsToShow = false;
	

	
	/**
	* @return whether there isn't an approval request for the user.
	*/
	public Boolean getNoRecordsToShow()
	{
		return noRecordsToShow;
	}
	
	
	/**
	* @return a list of approval items classified by type
	*/
	public List<ApprovalItemCollection> getApprovalItemsCollection()
	{
		if (approvalItemsCollection == null)
		{
			List<ProcessInstanceWorkitem> workItems;
			List<ProcessInstance> processInstances;
			
			workItems = [
				select processInstance.id, createdDate, actor.name, actor.id				
				from ProcessInstanceWorkitem
				where actor.id = :userId
			];
			
			List<Id> processInstancesIds = new List<Id>();
			for (ProcessInstanceWorkitem item : workItems)
			{
				processInstancesIds.add(item.processInstance.id);
			}
			
			processInstances = [
				select
					id,
					targetObject.id,
					targetObject.type,
					targetObject.name,
					(select id, createdDate, actorId from workItems where actorId = :userId)
				from ProcessInstance
				where id in :processInstancesIds and (targetObject.type = 'Leave_Request__c' or targetObject.type = 'Purchase_Requisition__c')
				order by targetObject.type
				//DVP : Modified where clause
			];
			
			//DVP : Create a list of all Leave Requests needing approval
			List<Id> LeaveRequestIds = new List<Id>();
			List<Id> PurchaseIds = new List<Id>();
			for(ProcessInstance pi : processInstances) {
				if (pi.TargetObject.type == 'Leave_Request__c')
				  LeaveRequestIds.add(pi.targetObjectId);
				else
				  PurchaseIds.add(pi.targetObjectId);
			}
			//DVP : Get the leave requests
			Map<Id, Leave_Request__c> leaverequests = new Map<Id,Leave_Request__c>([select Id, Name, From__c, To__c, Leave_Type__c, Short_Title__c, Owner.Name from Leave_Request__c where Id in :LeaveRequestIds]);
			Map<Id, Purchase_Requisition__c> purchases = new Map<Id, Purchase_Requisition__c>([Select Id, Name, Resource_Project_Name__c, Starting_Date__c, Ending_Date__c, Owner.Name From Purchase_Requisition__c Where Id in :PurchaseIds]);
			
			
			approvalItemsCollection = new List<ApprovalItemCollection>();
			String lastType;
			ApprovalItemCollection currentCollection;
			Map<String, Schema.SObjectType> sObjectTypeMap = Schema.getGlobalDescribe();
			for (ProcessInstance instance : processInstances)
			{
				String instanceType = instance.targetObject.type;
				if (instanceType != lastType)
				{
					currentCollection = new ApprovalItemCollection();
					currentCollection.itemsList = new List<ApprovalItem>();
					Schema.SObjectType objType = sObjectTypeMap.get(instanceType);
					currentCollection.itemsPluralLabel = (objType == null ? instanceType : objType.getDescribe().getLabelPlural());
					currentCollection.itemsType = instanceType;
					approvalItemsCollection.add(currentCollection);
					lastType = instanceType;
				}
				ApprovalItem apprItem = new ApprovalItem();
				apprItem.instance = instance;
				apprItem.workItem = instance.workItems[0];
				if (leaverequests.containsKey(instance.targetObject.Id))
				  apprItem.leaverequest = leaverequests.get(instance.targetObject.Id); //DVP
				if (purchases.containsKey(instance.targetObject.Id)) {
				  apprItem.purchase = purchases.get(instance.targetObject.Id);
				  apprItem.isPurchase = true;
				}
				currentCollection.itemsList.add(apprItem);
			}
		}
		
		if(approvalItemsCollection.size() <= 0)
		{
			noRecordsToShow = true;
		} 
		
		
		return approvalItemsCollection;
	}
	
	
	/**
	* Class ApprovalItem
	*/
	class ApprovalItem
	{
		public ProcessInstanceWorkitem workItem { get; set; }
		public ProcessInstance instance { get; set; }
		public SObject target { get; set; }
		public Leave_Request__c leaverequest {get;set;} //DVP
		public Purchase_Requisition__c purchase { get; set; }
		public Boolean isPurchase { get; set; }
		public String relatedTo
		{
			get
			{
				return instance.targetObject.name;	
			}
			set;
		}
		public String dateSubmitted
		{
			get
			{
				return workItem.createdDate.format('MM/dd/yyyy');	
			}
			set;
		}
		public ApprovalItem() {
			isPurchase = false;
		}
	}
	
	
	/**
	* Class ApprovalItemCollection
	*/
	class ApprovalItemCollection
	{
		public List<ApprovalItem> itemsList { get; set; }
		public String itemsType { get; set; }
		public String itemsPluralLabel { get; set; }
	}
		
}