/*
* Developed by Timba Software Corp. www.timbasoftware.com admin@timbasoftware.com
*/ 

/**
* Class that do Approve and Reject operations 
* Shows the Approval History and the item details
* @author Bruno Fagundez
*/ 
public with sharing class BlackBerryApproveRejectController {
	
		
	/**
	* Inicialization of enviroment variables
	*/	
	public String WORKITEM_ID = System.currentPageReference().getParameters().get('id');
	
	public List<List<String>> lisfDetailFields { get; set; }
	
	public String formattedObjectDetail {get; set;}
	public Leave_Request__c leaverequest {get;set;}
    public string Photolink{get;set;}
	
	public String getWORKITEM_ID ()
	{
		return WORKITEM_ID;
	} 
	
	ProcessInstanceWorkitem workItem = new ProcessInstanceWorkitem();
	ProcessInstance currentInstance = new ProcessInstance();
	List<ProcessInstanceStep> proccessHistory = new List<ProcessInstanceStep>();
	ProcessInstanceStep currentProccessStep = new ProcessInstanceStep();
	
	/**
	* Constructor
	*/	
	public BlackBerryApproveRejectController()
	{
		genApproveReject();
	}
		
	/**
	* Perform SOQL Queries to show the required data.
	*/	
	private void genApproveReject()
	{
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
								from ProcessInstance p where id =: workItem.ProcessInstanceId ];
								
			//DVP
			try {
                leaverequest = [select Id, OwnerId, Name, From__c, To__c, Leave_Type__c, Short_Title__c, Notes__c, Owner.Name from Leave_Request__c where Id =:currentInstance.TargetObjectId];								
                User u = [Select u.SmallPhotoUrl, u.FullPhotoUrl From User u where u.id=:leaverequest.OwnerId];
                Photolink = u.SmallPhotoUrl;
			}
			catch(Exception ex) {
				System.debug(ex);
			}
			
			proccessHistory = [ Select 
								p.CreatedDate,
								p.StepStatus, 
								p.ProcessInstance.TargetObjectId, 
								p.ProcessInstanceId, 
								p.Actor.Name,
								p.OriginalActorId, 
								p.Id, 
								p.Comments,
								p.SystemModstamp, 
								p.ActorId 
								from ProcessInstanceStep p 
								where p.ProcessInstance.TargetObjectId =: currentInstance.TargetObjectId order by p.SystemModstamp desc];
			
			// CurrentStep
			currentProccessStep = proccessHistory[0];
			
			// Get Detail Fields to show
			lisfDetailFields = getDetailFields(WORKITEM_ID);
			
			formattedObjectDetail = '';
			
	    	for (List<String> field : lisfDetailFields)
	    	{
	    		formattedObjectDetail += '<tr><td style="width:40%" class="label">' + field[0] + '</td><td class="outputCont">' + field[1] + '</td></tr>';	    		
	    	}
		}
	}
	
		
	/**
	* Returns the current step
	* @return ProcessInstanceStep
	*/	
	public ProcessInstanceStep getCurrentStep () 
	{
		return currentProccessStep;
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
	* Returns the Step History 
	* @return List<Step> 
	*/
	public List<Step> getProcHistory ()
	{
		List<Step> ls = new List<Step>();
		
		Integer counter = 0;
						
		for(ProcessInstanceStep p:proccessHistory)
		{	
			Step s = new Step(); 
			
			s.setStepDate(p.SystemModstamp);
			
			s.ShowSubmittedTitle = false;
			
			if(p.StepStatus != 'Started')
			{
				s.Status = p.StepStatus;				
			}  
			else if (counter == 0)
			{
				s.Status = 'Pending';
			} 
			else 
			{
				s.Status = 'Submitted';
				s.ShowSubmittedTitle = true;
			} 
			
			s.AssignedTo = p.Actor.Name;
			s.AssignedToId = p.ActorId;
			
			if(p.Comments != null)
			{
				if(p.Comments.length() > 0)
				{
					s.ShowComments = true;
					s.Comments = p.Comments;
				}
				else
				{
					s.ShowComments = false;
				}
			}	
			
			ls.add(s);
			counter++;		
		}
		
		return ls;
	}
	
	/**
	* This method gets the detail fields parsing the standard approval interface.
	* @author Guillermo Lacordelle
	* @param Id 
	* @return List<List<String>>
	*/
	public List<List<String>> getDetailFields(Id workItemId)
    {
    	PageReference page = new PageReference('/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workItemId);
    	
    	String patternString = '<label>(.*?)</label>.*?<td.*?>(<a.*?>(.*?)</a>|(.*?))</td>';
    	Pattern detailItemsPattern = Pattern.compile(patternString);
		Matcher detailItemsMatcher = detailItemsPattern.matcher(page.getContent().toString());
		
		List<List<String>> fields = new List<List<String>>();
		
		while (detailItemsMatcher.find()) 
		{
			String value = detailItemsMatcher.group(3);
			if (value == null)
				value = detailItemsMatcher.group(4);
			fields.add(new List<String> {detailItemsMatcher.group(1), value});
		}
			
	 	return fields;
    }

	/**
	*	Inner Classes
	*/
	
	/**
	* Step Class	
	*/
	public class Step 
	{
		public DateTime StepDateTime {get; set;}		
		
		public Boolean ShowSubmittedTitle {get; set;}
		
		public String StatusIcon { get; set; }
		
		public String StepDate;
		
		public String getStepDate(){
			return StepDate;
		} 
		
		public void setStepDate (DateTime s)
		{
				this.StepDate = s.format('dd MMM yyyy hh:mm a');
		}			
		
		public String Status { get; set; }
		public String AssignedTo { get; set; }
		public String AssignedToId { get; set; }
		public String ActualApprover { get; set; }
		public String Comments { get; set; }
		public Boolean ShowComments { get; set; }
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
    
    
    //DVP
    public PageReference redirectDesktops(){
    	//return null;
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        
        //& some devices use custom headers for the user-agent.
        if (userAgent==null || userAgent.length()==0){
            userAgent = ApexPages.currentPage().getHeaders().get('HTTP_X_OPERAMINI_PHONE_UA');
        }		
        if (userAgent==null || userAgent.length()==0){
            userAgent = ApexPages.currentPage().getHeaders().get('HTTP_X_SKYFIRE_PHONE');
        }
                
            //& replace with custom setting - using (?i) case insensitive mode.		
        String deviceReg = '(?i)(iphone|ipod|ipad|blackberry|android|palm|windows\\s+ce)';
        String desktopReg = '(?i)(windows|linux|os\\s+[x9]|solaris|bsd)';
        String botReg = '(?i)(spider|crawl|slurp|bot)';
        
        Boolean isDevice=false, isDesktop=false, isBot=false;
        
        Matcher m = Pattern.compile(deviceReg).matcher(userAgent);
        if (m.find()){
            isDevice = true;
        } else {
            //& don't compile the patterns unless required.
            m = Pattern.compile(desktopReg).matcher(userAgent);
            if (m.find()) isDesktop = true;
            
            m = Pattern.compile(botReg).matcher(userAgent);
            if (m.find()) isBot = true;
        }
        //& Default is mobile - unless a desktop or bot user-agent identified.					
        if (!isDevice && (isDesktop || isBot)) return new PageReference('/p/process/ProcessInstanceWorkitemWizardStageManager?id='+WORKITEM_ID); //send desktops to the normal approval page						
        return null; //mobile devices can see this man
    }

	

}