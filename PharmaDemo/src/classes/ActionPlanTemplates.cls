/**
 * This class methods related to action plan templates
 * @author Oliver Cortinas
 * @createdDate 04/29/2010
 */
 public with sharing class ActionPlanTemplates{
 	
    public ActionPlanTemplate__c    actionPlanTemplate;
    public List<APTTaskTemplate__c> pendingTemplateDeletes;
    public List<APTTaskTemplate__c> aptTasks;
    public String                   testApId;
    public Integer                  taskLimit;
    public String                   errorMsg;
    
    /**
    * Constructor
    * @param actionPT
    */
    public ActionPlanTemplates( ActionPlanTemplate__c actionPT ){
    	
    	this.errorMsg			= '';
        this.taskLimit  		= 75;
        this.actionPlanTemplate = actionPT;
    }
    
    /** 
	 * Gets all available Action Plan Templates and return a list of ActionPlan__c
	 * @return List<ActionPlanTemplate__c>
	 */
    public List<ActionPlanTemplate__c> getActionPlanTemplates(){
    	
        return [ select a.Id, a.Name, a.Description__c, a.SkipWeekends__c, a.LastModifiedDate, a.LastModifiedBy.Name, 
        			a.LastModifiedById,	a.CreatedDate, a.CreatedBy.Name, a.CreatedById 
        			from ActionPlanTemplate__c a order by a.Name ASC ];
    }
    
    /** 
     * (1)Gets a specific Action Plan based on query Id and return an ActionPlan__c object
     * (2)In case the Id is not passed by URL then create a new instance of the object.
     * (3)Then if the method is called trying to clone an Action Plane Template, clone the template without Id.
     * @return 
     */
    public ActionPlanTemplate__c getActionPlanTemplate(){
    	
        if( this.actionPlanTemplate == null ){
            if( ApexPages.currentPage().getParameters().get( 'Id' ) != null ){
                /* (1) */
                String tempApId = ApexPages.currentPage().getParameters().get( 'Id' );
                this.actionPlanTemplate = [select a.Id, a.Name, a.Description__c, a.SkipWeekends__c, a.SkipDay__c, a.LastModifiedDate, a.LastModifiedBy.Name, a.LastModifiedById, a.CreatedDate, a.CreatedBy.Name, a.CreatedById, a.Owner.Name from ActionPlanTemplate__c a where a.Id = :tempApId];
            }
            else{
                /* (2) */
                this.actionPlanTemplate = new ActionPlanTemplate__c();
            }
            
            if( ApexPages.currentPage().getParameters().get( 'clone' ) == '1' ){
                /* (3) */
                ActionPlanTemplate__c apC = actionPlanTemplate.clone( false );
                this.actionPlanTemplate.clear();
                this.actionPlanTemplate = apC;
            }
        }
        
        return actionPlanTemplate;
    }
    
    /** 
     * Saves Action Plan Template and all tasks, then redirects to the AP template list.
     * First check for pending templates for delete, in case that exists then delete those objects.
     * Then insert or update the Action Plan Template pending to save and save tasks to the template 
     * and attach relation to Action Plan.
     * @return newPage
     */
    public PageReference saveTemplate(){
    	
        Savepoint sp = Database.setSavepoint();
        
        // check for pendingDeletes, if something is pending send it to delete
        if( pendingTemplateDeletes != null ){
            for( APTTaskTemplate__c deleteId : pendingTemplateDeletes ){
                delete deleteId;
            }
        }
        // update Action Plan Template object, in case of exception then rollback the actions with the database
        ActionPlanTemplate__c apt = actionPlanTemplate;
        try{
            upsert apt;
        } catch( exception e ){
            Database.rollback( sp );
            return null;    
        }
        
        // save tasks to the template and attach relation to Action Plan
        for( APTTaskTemplate__c t : aptTasks ){
            if( t.Action_Plan_Template__c == null ){
            	t.Action_Plan_Template__c = apt.Id;
            } 
            
            t.DaysFromStart__c = math.abs( t.DaysFromStart__c );
        }
        try{
            upsert aptTasks;
        } catch( exception e ){
            Database.rollback( sp );
            return null;    
        }
        
        // run through the tasks and take care of dependents
        for( APTTaskTemplate__c t : aptTasks ){
            if( t.Dependent__c != 'None' && t.Dependent__c != null ){
                Integer tempIndex 		= Integer.valueOf( t.Dependent__c );
                t.APTTaskTemplate__c 	= aptTasks[tempIndex].Id;
            }
            else{
            	t.APTTaskTemplate__c = null;
            }
        }
        try{
            upsert aptTasks;
        } catch( exception e ){
            Database.rollback( sp );
            return null;    
        }   
        
        // Send the user to the detail page for the new account.
        PageReference newPage = new PageReference( '/apex/ActionPlanTemplateDetail?Id=' + apt.Id );
        newPage.setRedirect( true );
        return newPage;
    }
    
    /** 
     * Deletes the current Action Plan Template loaded and redirects to the AP Template List.
     * @return newPage
     */
    public PageReference deleteTemplate(){
    	
        ActionPlanTemplate__c apt = this.actionPlanTemplate;
        try{
            delete apt;
        } catch( exception e ){
            system.debug( e );    
        }
        
        // Send the user to the detail page for the new account.
        PageReference newPage = new PageReference( '/apex/ActionPlanTemplateList' );
        newPage.setRedirect( true );
        
        return newPage;
    }
    
    /** 
     * Cancel the current Action Plan Template loaded and redirects to the AP Template List.
     * @return newPage
     */
    public PageReference cancelTemplate(){
    	
        PageReference newPage;
        
        if( this.actionPlanTemplate.Id == null ){
             // Send the user to the detail page for the new account.
            newPage = new PageReference( '/apex/ActionPlanTemplateList' );
            newPage.setRedirect( true );
        }
        else{
            // Send the user to the detail page for the new account.
            newPage = new PageReference( '/apex/ActionPlanTemplateDetail?Id=' + actionPlanTemplate.Id );
            newPage.setRedirect( true );  
        }
        
        return newPage;
    }
    
    /** 
     * Get all tasks related to the Action Template.
     * @return aptTasks
     */
    public List<APTTaskTemplate__c> getTemplateTasks(){
    	
        if( aptTasks == null || aptTasks.size() == 0 ){
            String TempApId = ApexPages.currentPage().getParameters().get('Id');
            if( TempApId != null ){
                aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                				 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                				 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                				 From APTTaskTemplate__c a 
                				 where a.Action_Plan_Template__c =: TempApId ];
            }
            else{
                aptTasks 				= new List<APTTaskTemplate__c>();
                APTTaskTemplate__c t 	= new APTTaskTemplate__c();
                t.Reminder__c = true;
                aptTasks.add( t );
            }
            
            // clone and clear Ids
            if( ApexPages.currentPage().getParameters().get( 'clone' ) == '1' ){
                List<APTTaskTemplate__c> tC = aptTasks.deepClone( false );
                aptTasks.clear();
                aptTasks = tC;
                
                // clear lookup relationship also
                for( APTTaskTemplate__c t : aptTasks ){
                    if( t.Action_Plan_Template__c != null ){
                    	 t.Action_Plan_Template__c = null;
                    }
                }
            }
        }     
        
        return aptTasks;
    }
    
    /** 
     * Creates a blank Task object and adds it to List<Task>.
     */
    public void addTemplateTask(){
    	
        if( ApexPages.currentPage().getParameters().get( 'add' ) == '1' ){
        	
            //in casethe task limit is reach set a message error to display
            if( this.aptTasks.size() >= this.taskLimit ){
                this.errorMsg = 'Task limit reached.';
            } 
            else{
                APTTaskTemplate__c t = new APTTaskTemplate__c();
                t.Reminder__c = true;
                
                // validate user, priority, subject before adding another
                Integer taskSize = aptTasks.size();
                if( this.aptTasks[taskSize - 1].Priority__c != null && this.aptTasks[taskSize - 1].Subject__c != null ){
                    this.aptTasks.add( t );
                }
            }
        }       
    }
    
    /** 
     * Remove a specific index in the List<APTTaskTemplate__c>.
     */
    public void removeTemplateTask(){
    	
        String removeIndex = ApexPages.currentPage().getParameters().get('remove');
        if( removeIndex != null ){
            String[] newRemoveIndex = removeIndex.split( ':', -2 );
            Integer taskIndex 		= Integer.valueOf(newRemoveIndex[5]);
            Id deletedId 			= aptTasks[taskIndex].Id;
            
            //check for dependent children and clear them since the parent is being removed.
            for( APTTaskTemplate__c aptTask : aptTasks ){
                if( aptTask.APTTaskTemplate__c == deletedId ){ 
                    aptTask.APTTaskTemplate__c 	= null;
                    aptTask.Dependent__c 		= null;
                }
            }
            
            // before remove check if it's exists in the DB, if so, add to pendingTemplateDeletes to be deleted on save.
            if( aptTasks[taskIndex].Id != null ){
                if( pendingTemplateDeletes == null ){
                	 pendingTemplateDeletes = new List<APTTaskTemplate__c>();
                }
                pendingTemplateDeletes.add( aptTasks[taskIndex] );
            }
            
            aptTasks.remove( taskIndex );
            
            // clear errorMsg if it's set.
            if( aptTasks.size() < taskLimit ){
            	 errorMsg = null;
            }
        }
    }
    
    /** 
     * Return size of the APT Template Tasks List.
     */
    public Integer getTemplateTaskSize(){
        return aptTasks.size(); 
    }
    
    /** 
     * Creates a SelectOption list of task subjects to be used with creating task dependencies.
     */
    public List<SelectOption> getTemplateSubjectItems(){
    	
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( 'None', '--None--' ) );
        integer i = 0;
        
        if( aptTasks != null ){
            for( APTTaskTemplate__c t : aptTasks ){
                if( t.Subject__c != null ){
                	 options.add( new SelectOption( string.valueOf( i ), t.Subject__c+' ('+ ( i + 1 ) +')' ) );
                }
                i++;
            }
        }
        
        return options;
    }

    /**
    * Checks if Action Plan Tasks has cycling dependency.
    * @return exists
    */
    public Boolean checkCycleDependent(){
    	
    	Boolean exists 	= false;
    	Integer index 	= 0;
    	
    	for( APTTaskTemplate__c t : this.aptTasks ){
            if( t.Dependent__c != 'None' && t.Dependent__c != null ){
                Integer tempIndex 		= Integer.valueOf( t.Dependent__c );
                APTTaskTemplate__c link = this.aptTasks[tempIndex];
                
                if( this.dependantCycle( t, link, index ) ){
                	return true;
                }
            }
    	}
    	
    	return exists;
    }
	
	/**
    * 
    * @param originTask
    * @param destinyTask
    * @param index
    * @return Boolean
    */
	private Boolean dependantCycle( APTTaskTemplate__c originTask, APTTaskTemplate__c destinyTask, Integer index ){
		
        if( destinyTask.Dependent__c != 'None' && destinyTask.Dependent__c != null ){
        	
        	Integer tempIndexDestiny = Integer.valueOf( destinyTask.Dependent__c );
        	APTTaskTemplate__c link = this.aptTasks[tempIndexDestiny];
        	
        	if( Integer.valueOf( originTask.Dependent__c ) == index ){
        		return true;
        	}
        	else{
        		return dependantCycle( originTask, link, tempIndexDestiny );
        	}
        }
        else{
        	return false;
        }
	} 
	
	public static testMethod void constructorTest(){
	
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		Test.StopTest();
	}
	
	public static testMethod void testRetrievingTemplateTasks(){
		
		//clear all action plan templates
		List<ActionPlanTemplate__c> apTemplateList = [ select id from ActionPlanTemplate__c ];
		delete apTemplateList;
		
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		List<ActionPlanTemplate__c> apTemplates = apTemplate.getActionPlanTemplates();
		
		System.assert( !apTemplates.isEmpty(), 'action plan template list is empty' );
		
		Test.StopTest();
	}
	
	//TODO finish this test for all condicionals
	public static testMethod void testRetrievingActionPlanTemplate(){
	
		//clear all action plan templates
		List<ActionPlanTemplate__c> apTemplateList = [ select id from ActionPlanTemplate__c ];
		delete apTemplateList;
		
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );

		ActionPlanTemplate__c resultActionPlanTemplate = apTemplate.getActionPlanTemplate();
		
		Test.StopTest();
	}
	
	//TODO finish this big method
	public static testMethod void checkSavingActionPlanTemplate(){
	
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		Test.StopTest();
	}
	
	public static testMethod void testActionPlanTemplateDelete(){
	
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		apTemplate.actionPlanTemplate = actionPlanTemplate;
		apTemplate.deleteTemplate();
		
		List<ActionPlanTemplate__c> results = [ select id from ActionPlanTemplate__c where Id =: actionPlanTemplate.Id ];
		
		System.assert( results.isEmpty(), 'Action plan template not deleted' );
		
		Test.StopTest();
	}
	
	public static testMethod void testActionPlanTemplateCancel(){
	
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		ActionPlanTemplates apTemplate 	= new ActionPlanTemplates( actionPlanTemplate );
		apTemplate.actionPlanTemplate 	= actionPlanTemplate;
		apTemplate.cancelTemplate();
		
		ActionPlanTemplate__c apTemplate2 = new ActionPlanTemplate__c();
		apTemplate = new ActionPlanTemplates( apTemplate2 );
		apTemplate.cancelTemplate();
		
		Test.StopTest();
	}
	
	public static testMethod void testRetrievingActionPlanTemplateTasks(){
	
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		System.currentPageReference().getParameters().put( 'id', actionPlanTemplate.Id );
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		apTemplate.actionPlanTemplate 			= actionPlanTemplate;
		List<APTTaskTemplate__c> templateTasks 	= apTemplate.getTemplateTasks();
		
		System.assert( !templateTasks.isEmpty(), 'template task list is empty');
		System.assert( templateTasks.size() == 3, 'template tasks size not correct' );
		
		System.currentPageReference().getParameters().put( 'id', null );
		apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		apTemplate.actionPlanTemplate 				= actionPlanTemplate;
		List<APTTaskTemplate__c> templateTasks2 	= apTemplate.getTemplateTasks();
		
		System.assert( !templateTasks2.isEmpty(), 'template task list is empty');
		System.assert( templateTasks2.size() == 1, 'template tasks size not correct' );
		
		System.currentPageReference().getParameters().put( 'clone', '1') ;
		apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		apTemplate.actionPlanTemplate 				= actionPlanTemplate;
		List<APTTaskTemplate__c> templateTasks3 	= apTemplate.getTemplateTasks();
		
		Test.StopTest();
	}
	
	public static testMethod void testAddNewActionPlanTemplateTask(){
	
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		System.currentPageReference().getParameters().put( 'add', '1') ;
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		apTemplate.aptTasks = new List<APTTaskTemplate__c>();
		apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                				 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                				 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                				 From APTTaskTemplate__c a 
                				 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
		
		apTemplate.addTemplateTask();
		
		System.assert( apTemplate.errorMsg == '', 'A error was returned when adding a template task' );
		
		ActionPlanTemplate__c actionPlanTemplate2 = testUtil.createNewActionPlanTemplate( 75 );
		
		System.currentPageReference().getParameters().put( 'add', '1') ;
		apTemplate 			= new ActionPlanTemplates( actionPlanTemplate );
		apTemplate.aptTasks = new List<APTTaskTemplate__c>();
		apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                				 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                				 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                				 From APTTaskTemplate__c a 
                				 where a.Action_Plan_Template__c =: actionPlanTemplate2.Id ];
		
		apTemplate.addTemplateTask();
		
		System.assert( apTemplate.errorMsg != '', 'A error was not returned when adding a template task' );
		
		Test.StopTest();
	}
	
	public static testMethod void testRemovingActionPlanTemplateTask(){
		
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		System.currentPageReference().getParameters().put( 'remove', 'editPage:templateForm:editBlock:taskSection:taskTable:1:columnOne') ;
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		apTemplate.aptTasks = new List<APTTaskTemplate__c>();
		apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                				 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                				 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                				 From APTTaskTemplate__c a 
                				 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
		
		apTemplate.removeTemplateTask();
		
		System.assert( apTemplate.aptTasks.size() == 2, 'Task was not deleted correctly' );
		
		Test.StopTest();
	}
	
	public static testMethod void checkRetrievingTemplateTasks(){
	
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 4 );
		
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		apTemplate.aptTasks = new List<APTTaskTemplate__c>();
		apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                				 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                				 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                				 From APTTaskTemplate__c a 
                				 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
                				 
		List<APTTaskTemplate__c> apTemplateTasks = apTemplate.getTemplateTasks();
		
		System.assert( apTemplateTasks.size() == 4, 'Incorrect size returned' );
		
		Test.StopTest();
	}
	
	public static testMethod void checkRetrievingTemplateTasksListSize(){
	
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 4 );
		
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		apTemplate.aptTasks = new List<APTTaskTemplate__c>();
		apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                				 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                				 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                				 From APTTaskTemplate__c a 
                				 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
                				 
		List<APTTaskTemplate__c> apTemplateTasks 	= apTemplate.getTemplateTasks();
		Integer numTasks 							= apTemplate.getTemplateTaskSize();
		
		System.assert( apTemplateTasks.size() == numTasks, 'Incorrect size returned' );
		
		Test.StopTest();
	}
	
	public static testMethod void checkRetrievingSubjectItems(){
	
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 5 );
		
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		apTemplate.aptTasks = new List<APTTaskTemplate__c>();
		apTemplate.aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c,
                				 a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, 
                				 a.APTTaskTemplate__r.Subject__c, a.Reminder__c, a.SendEmail__c, a.Comments__c 
                				 From APTTaskTemplate__c a 
                				 where a.Action_Plan_Template__c =: actionPlanTemplate.Id ];
		
		List<Selectoption> options = apTemplate.getTemplateSubjectItems();
		
		System.assert( options.size() == 6 , 'Incorrect Size for select options' );
		
		Test.StopTest();
	}
	
	public static testMethod void testActionPlanTemplateTaskDependencySuccess(){
	
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		APTTaskTemplate__c newAPTTask 	= new APTTaskTemplate__c();
 		APTTaskTemplate__c newAPTTask2 	= new APTTaskTemplate__c();
 		
 		newAPTTask.Subject__c 			= testUtil.createRandomWord();
 		newAPTTask.DaysFromStart__c 	= 2;
 		newAPTTask.Dependent__c			= 'None';
 		newAPTTask.Type__c 				= 'Email';
 		newAPTTask.Priority__c 			= 'High';
 		
 		newAPTTask2.Subject__c 			= testUtil.createRandomWord();
 		newAPTTask2.DaysFromStart__c 	= 2;
 		newAPTTask2.Dependent__c		= '0';
 		newAPTTask2.Type__c 			= 'Email';
 		newAPTTask2.Priority__c 		= 'High';
 		
		apTemplate.aptTasks = new List<APTTaskTemplate__c>();
		apTemplate.aptTasks.add( newAPTTask );
		apTemplate.aptTasks.add( newAPTTask2 );		
                				 
        Boolean result = apTemplate.checkCycleDependent();
		
		System.assert( !result, 'Dependency check failed' );
		
		Test.StopTest();
	}
	
	public static testMethod void testActionPlanTemplateTaskDependencyFail(){
	
		Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlanTemplate__c actionPlanTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		ActionPlanTemplates apTemplate = new ActionPlanTemplates( actionPlanTemplate );
		
		APTTaskTemplate__c newAPTTask 	= new APTTaskTemplate__c();
 		APTTaskTemplate__c newAPTTask2 	= new APTTaskTemplate__c();
 		APTTaskTemplate__c newAPTTask3 	= new APTTaskTemplate__c();
 		
 		newAPTTask.Subject__c 			= testUtil.createRandomWord();
 		newAPTTask.DaysFromStart__c 	= 2;
 		newAPTTask.Dependent__c			= '1';
 		newAPTTask.Type__c 				= 'Email';
 		newAPTTask.Priority__c 			= 'High';
 		
 		newAPTTask2.Subject__c 			= testUtil.createRandomWord();
 		newAPTTask2.DaysFromStart__c 	= 2;
 		newAPTTask2.Dependent__c		= '2';
 		newAPTTask2.Type__c 			= 'Email';
 		newAPTTask2.Priority__c 		= 'High';
 		
 		newAPTTask3.Subject__c 			= testUtil.createRandomWord();
 		newAPTTask3.DaysFromStart__c 	= 2;
 		newAPTTask3.Dependent__c		= '0';
 		newAPTTask3.Type__c 			= 'Email';
 		newAPTTask3.Priority__c 		= 'High';
 		
		apTemplate.aptTasks = new List<APTTaskTemplate__c>();
		apTemplate.aptTasks.add( newAPTTask );
		apTemplate.aptTasks.add( newAPTTask2 );		
		apTemplate.aptTasks.add( newAPTTask3 );		
                				 
        Boolean result = apTemplate.checkCycleDependent();
		
		System.assert( result, 'Dependency did not fail' );
		
		Test.StopTest();
	}
}