/*
* Developed by Timba Software Corp. www.timbasoftware.com admin@timbasoftware.com
*/
 
/**
* @author Guillermo Lacordelle
*/ 
public with sharing class BlackBerryReassignController {
	
	public Id workItemId { get; set; }
	
	public String relatedTo { get; set; }
	
	public String createdBy { get; set; }
	
	public String assignedApprover { get; set; }
	
	public String approverId { get; set; }
	
	public String comments { get; set; }
	
	public String objectType { get; set; }
	
	public Boolean error { get; set; }
	
	public Boolean browserRedirect { get; set; }
	
	private ProcessInstanceWorkitem workItem;
	
	private final String[] invalidUserTypes = new String[]{'LicenseManager', 'Guest'};
	
	
	/**
	* Constructor
	*/
	public BlackBerryReassignController()
	{
		Map<String, String> parameters = ApexPages.currentPage().getParameters();
		
		error = false;
		String browserRedirString = parameters.get('browserRedirect');
		
		if(browserRedirString == 'true')
		{
			browserRedirect = true;
		} else {
			browserRedirect = false;
		}
		
		workItemId = parameters.get('id');
		approverId = parameters.get('approverId');
		comments = parameters.get('comments'); 
		
		workItem = [
			select
				processInstance.id,
				processInstance.targetObjectId,
				createdBy.name,
				actor.name
			from ProcessInstanceWorkitem
			where id = :workItemId
		];
		
		ProcessInstance instance = [
			select
				targetObject.name,
				targetObject.type
			from ProcessInstance
			where id = :workItem.processInstance.id
		];
		
		relatedTo = instance.targetObject.name;
		createdBy = workItem.createdBy.name;
		assignedApprover = workItem.actor.name;
		objectType = instance.targetObject.type;
	}
	
	
	/**
    * @return the list of users and groups
    */     
    public List<SelectOption> getApproverLookupList()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-1','Select...'));
        options.add(new SelectOption('-1','--Users--'));
        
        List<User> users = [Select id, name from User where userType not in :invalidUserTypes];
        for(User user: users)
        {
          	options.add(new SelectOption(user.id,user.name));
        }
        
        options.add(new SelectOption('-1','--Groups--'));
        
        List<GroupMember> groups = [Select g.userOrGroupId, g.group.name, g.group.Id From GroupMember g ];
        for(GroupMember gp : groups)
        {
           	options.add(new SelectOption(gp.group.id, gp.group.name));
        }
        return options;
    }
    
    
    /**
    * Reassigns the selected approval request to the new user.
    * @return the next page
    */  
    public PageReference reassign()
    {
    	if (workItem != null && approverId != null && approverId != '-1') 
    	{				
			workItem.actorId = approverId;
			update workItem;
			if(browserRedirect != null && browserRedirect == true )
			{
				return Page.BBBApprovalList;
			}else {
				return Page.BlackBerryApprovalList;
			}
    	} 
    	else 
    	{
    		error = true;
    		return null;
    	}
    }
    
    
    /**
    * @return the next page
    */ 
    public PageReference cancel()
    {
    	return Page.BlackBerryApprovalList;
    }
    
    
    /**
    * Selects the action to perform, basen on the event parameter.
    * @return the next page
    */ 
    public PageReference perform()
    {    	
    	String event = ApexPages.currentPage().getParameters().get('event');
    	if (event == 'Reassign Approval Request')
    		return reassign();
		else if (event == 'Cancel')
			return cancel();
		else
			return null;    		
    }
}