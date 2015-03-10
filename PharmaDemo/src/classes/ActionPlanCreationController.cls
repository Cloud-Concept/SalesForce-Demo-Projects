/**
* @author Matias Menafra
* @createdate 04/29/2010
*/
public with sharing class ActionPlanCreationController{
        
    public ActionPlan__c        actionPlan          { get; set; }
    public ActionPlansUtilities actionPlans         { get; set; }
    public String               errorMsg            { get; set; }
    public String               actionPlanId        { get; set; }
    public List<String>         relatedObjIds       { get; set; }
    public String               relatedObjName      { get; set; }
    public List<String>         relatedObjNameList  { get; set; }
    public Boolean              hasRelated          { get; set; }
    

    /**
    * Constructor
    */
    public ActionPlanCreationController( ApexPages.StandardController stdController ){
        
        this.hasRelated = false;
        this.errorMsg	= '';
        this.actionPlan = ( ActionPlan__c ) stdController.getRecord();
 
        if( System.currentPageReference().getParameters().get( 'id' ) != null ){
            this.actionPlanId = System.currentPageReference().getParameters().get( 'id' );
            
            //TODO move method to action plans
            this.actionPlan = [ select a.Id, a.Name, a.CreatedById, a.StartDate__c, a.Action_Plan_Template__r.Name, 
                                    a.Action_Plan_Template__r.Id, a.Action_Plan_Template__c, a.Account__c, a.Contact__c, 
                                    a.Lead__c, a.Opportunity__c, a.SkipWeekends__c, a.SkipDay__c
                                    from ActionPlan__c a  
                                    Where a.Id =: this.actionPLanId limit 1 ];
                                    
            this.actionPlan.StartDate__c = Date.today();
			this.ActionPlans = new ActionPlansUtilities( this.actionPlan );
        }
        else if( System.currentPageReference().getParameters().get( 'clone' ) == '1' ){
        	
        	this.actionPlan.StartDate__c = Date.today();
            this.ActionPlans = new ActionPlansUtilities( this.actionPlan );
            List<APTaskTemplate__c> tcAux   = this.ActionPlans.getTasks();
            List<APTaskTemplate__c> tC      = this.ActionPlans.apTasks.deepClone( false );
            this.ActionPlans.apTasks.clear();
            this.ActionPlans.apTasks = tC;
            
            // clear task relations
            for( APTaskTemplate__c t : this.ActionPlans.apTasks ){
                t.Action_Plan__c = null;
            }
        }
        else{
        	if( ApexPages.currentPage().getParameters().get('templateId') != null ){
                String tempApId = ApexPages.currentPage().getParameters().get( 'templateId' );
                
                ActionPlanTemplate__c  actionPlanTemplate = [ select a.Id, a.Name, a.Description__c, a.LastModifiedDate,  
                												a.SkipWeekends__c, a.SkipDay__c from ActionPlanTemplate__c a 
                                                				where a.Id = :tempApId ];
                                                			
                this.actionPlan.Name                     = ActionPlanTemplate.Name + ' - ';
                this.actionPlan.Description__c           = ActionPlanTemplate.Description__c;
                this.actionPlan.SkipWeekends__c          = ActionPlanTemplate.SkipWeekends__c;
                this.actionPlan.SkipDay__c               = ActionPlanTemplate.SkipDay__c; 
                this.actionPlan.Action_Plan_Template__c  = ActionPlanTemplate.Id;
	        }
	         
	        if( ApexPages.currentPage().getParameters().get( 'refId' ) != null ){	
	            this.hasRelated = true;
	            this.referedObjectInit();
	        } 
	        
			this.actionPlan.StartDate__c = Date.today();
			this.ActionPlans 			 = new ActionPlansUtilities( this.actionPlan );   
        }
    }    

    /**
    * Getter and Setter for refId
    */
    public String refId{ 
        get{
            if( refId == null ){
                refId = ApexPages.currentPage().getParameters().get( 'refId' );
            }
            return refId;
        }
        set;
    }
    
    /**
    * Getter and Setter for RefType
    */
    public String refType{ 
        get{
            if( refType == null ){
                refType = ApexPages.currentPage().getParameters().get( 'refType' );
            }
            return refType;
        }
        set;
    }
    
    /*
    * 
    * @return refName
    
    public String getRefName(){
        
        String refName = null;
        if( ApexPages.currentPage().getParameters().get( 'refId' ) != null ){
            Id typeSafeId = refId;
            
            if( refId.startsWith('001') ){
                Account[] a = [ select Name from Account where Id =: typeSafeId ];
                if( a.size() > 0 ){
                    refName = a[0].Name;
                } 
            }
            
            if( refId.startsWith( '00Q' ) ){
                Lead[] l = [ select Name from Lead where Id =: typeSafeId ];
                if( l.size() > 0 ){
                    refName = l[0].Name;
                } 
            }
            
            if( refId.startsWith( '003' ) ){
                Contact[] c = [ select Name from Contact where Id =: typeSafeId ];
                if( c.size() > 0 ){
                     refName = c[0].Name;
                }
            }   
            
            if( refId.startsWith( '006' ) ){
                Opportunity[] o = [ select Name from Opportunity where Id =: typeSafeId ];
                if( o.size() > 0 ){
                    refName = o[0].Name;
                } 
            }   
        }
        
        return refName; 
    }  */
    
    /**
    * Action which saves a new Action Plan
    * @return PageReference
    */
    public PageReference save(){
        
        return this.actionPlans.saveHandler();
    }
    
    /**
    * Action which saves a new Action Plan
    * @return PageReference
    */
    public PageReference saveAndNew(){
    
        return this.actionPlans.saveAndNew( );
    }
    
    /**
    * Retrieves number of completed tasks
    * @return Integer
    */
    public Integer getCompleted(){
    	
        Integer i = null;
        
        if( this.actionPlans != null ){
        	i = this.actionPlans.getCompleted();
        }
        
        return ( i != null ) ? i : 0;
    }
    
    /**
    * Creates a blank Task object and adds it to List<Task>
    */
    public void addTask(){
        
        this.actionPlans.addTask();
    }
    
    /**
    * Action for removing a existing task
    */
    public void removeTask(){
        
        this.actionPlans.removeTask();
    }
    
    /**
    * Method which retrieves all tasks for a Action Plan
    * @return List<APTaskTemplate__c>
    */
    public List<APTaskTemplate__c> getTasks(){
        return ( this.actionPlans != null ) ? this.actionPlans.getTasks() : new List<APTaskTemplate__c>();
    }
    
    /**
    * Retrieves size of APT Template Tasks List.
    * @return apTasks
    */
    public Integer getTaskSize(){
        return ( this.actionPlans != null ) ? this.actionPlans.getTaskSize() : 0; 
    }
    
    /**
    * Returns list of Dependet tasks to fill drop down 
    * @return List<SelectOption>
    */
    public List<SelectOption> getSubjectItems(){
        
        return this.actionPlans.getSubjectItems();
    }
    
    /**
    * Checks if Action Plan Tasks has cycling dependency.
    * @return Boolean
    */
    public PageReference checkCycleDependent(){
    	
    	if( this.actionPlans.checkCycleDependent() ){
    		this.errorMsg = 'Remove cyclic dependency on tasks and try again.';
    		return null;
    	}
    	else{
    		return this.save();
    	}
    }
    
    /**
    * Set the Refered object to Create New Action Plan 
    */
    public void referedObjectInit(){
    	
        String nameParam        = ApexPages.currentPage().getParameters().get( 'refType' );
        String idsParam         = ApexPages.currentPage().getParameters().get( 'refId' );
        this.relatedObjNameList = new List<String>();
        this.relatedObjIds      = ( idsParam != null && idsParam != '' ) ? idsParam.split(',') : new  List<String>();
        
        if( 'Account'.equalsIgnoreCase( nameParam ) ){
            this.relatedObjName = 'Accounts';
            for( Account acc : [ Select Name from Account where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( acc.Name );
            }
        } 
        else if( 'Lead'.equalsIgnoreCase( nameParam ) ){
            this.relatedObjName = 'Leads';
            for( Lead lead : [ Select FirstName, LastName from Lead where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( lead.FirstName + ' ' + lead.LastName );
            }
        } 
        else if( 'Contact'.equalsIgnoreCase( nameParam ) ){
            this.relatedObjName = 'Contacts';
            for( Contact cont : [ Select LastName, FirstName from Contact where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( cont.FirstName + ' ' + cont.LastName );
            }
        } 
        else if( 'Opportunity'.equalsIgnoreCase( nameParam ) ){
            this.relatedObjName = 'Opportunities';
            for( Opportunity opp : [ Select Name from Opportunity where Id IN : relatedObjIds ] ){
                this.relatedObjNameList.add( opp.Name );
            }
        }
    }
    
    public static testMethod void constructorTests(){
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'contacts', 2 );
		
		System.currentPageReference().getParameters().put( 'id', null );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		
		System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
		apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		
		System.currentPageReference().getParameters().put( 'id', null );
		System.currentPageReference().getParameters().put( 'clone', '1' );
		apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		
		ActionPlanTemplate__c apTemplate = testUtil.createNewActionPlanTemplate( 3 );
		
		System.currentPageReference().getParameters().put( 'id', null );
		System.currentPageReference().getParameters().put( 'clone', null );
		System.currentPageReference().getParameters().put( 'templateId', apTemplate.Id );
		apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		
		Contact contact = testUtil.createNewContact();
		
		System.currentPageReference().getParameters().put( 'id', null );
		System.currentPageReference().getParameters().put( 'refId', contact.Id );
		System.currentPageReference().getParameters().put( 'refType', 'Contact' );
		apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		String refid 	= apCreateController.refId;
		String reftype 	= apCreateController.refType;
		
		Test.StopTest();
    }
    /*
    public static testMethod void checkRefName(){
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		String result = '';
		
		Account 	acc 	= testUtil.createNewAccount();
		Contact 	cont 	= testUtil.createNewContact();
		Lead 		lead 	= testUtil.createNewLead();
		Opportunity opp 	= testUtil.createNewOpportunity();
		
		System.currentPageReference().getParameters().put( 'refId', null );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		result = apCreateController.getRefName();
		
		//checks that if param null refname returned is null 
		System.assert( result == null, 'refname is not null' );
		
		System.currentPageReference().getParameters().put( 'refId', acc.Id );
		apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		result = apCreateController.getRefName();
		
		//checks refname against a account
		System.assert( result == 'accounts', 'refname is not correct' );
		
		System.currentPageReference().getParameters().put( 'refId', cont.Id );
		apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		result = apCreateController.getRefName();
		
		//checks refname against a contact
		System.assert( result == 'contact', 'refname is not correct' );
		
		System.currentPageReference().getParameters().put( 'refId', lead.Id );
		apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		result = apCreateController.getRefName();
		
		//checks refname against a lead
		System.assert( result == 'lead', 'refname is not correct' );
		
		System.currentPageReference().getParameters().put( 'refId', opp.Id );
		apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		result = apCreateController.getRefName();
		
		//checks refname against a opportunity
		System.assert( result == 'opportunity', 'refname is not correct' );
		Test.StopTest();
    }
    */
    
    public static testMethod void testActionPlanSave(){
    	
    	//Erase all Action Plans before begining test
    	List<ActionPlan__c> apList = [ select Id from ActionPlan__c ];
    	delete apList;
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil 	= new ActionPlansTestUtilities();
		ActionPlan__c actionPlan 			= new ActionPlan__c();
		
		Contact contact = testUtil.createNewContact();
		
		actionPlan.Name 		= testUtil.createRandomWord();
		actionPlan.Contact__c	= contact.Id;
		actionPlan.StartDate__c	= Date.today();
		
		APTaskTemplate__c apTask = new APTaskTemplate__c();
		
		apTask.Subject__c 			= testUtil.createRandomWord();
		apTask.User__c				= testUtil.createTestUser().Id;
 		apTask.DaysFromStart__c 	= 2;
 		apTask.Type__c 				= 'Email';
 		apTask.Priority__c 			= 'Hight';
				
		System.currentPageReference().getParameters().put( 'id', null );
		System.currentPageReference().getParameters().put( 'refId', contact.Id );
		System.currentPageReference().getParameters().put( 'refType', 'Contact' );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
		
		apCreateController.actionPlans.apTasks = new List<APTaskTemplate__c>();
		apCreateController.actionPlans.apTasks.add( apTask );
		apCreateController.save();
		
		List<ActionPlan__c> results = [ select Id from ActionPlan__c ];
		
		System.assert( !results.isEmpty(), 'Action Plan not created' );
		System.assert( results.size() == 1, 'Action Plan not created' );
		
		Test.StopTest();
    }
    
    public static testMethod void testActionPlanSaveAndNew(){
    	
    	//Erase all Action Plans before begining test
    	List<ActionPlan__c> apList = [ select Id from ActionPlan__c ];
    	delete apList;
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil 	= new ActionPlansTestUtilities();
		ActionPlan__c actionPlan 			= new ActionPlan__c();
		
		Contact contact = testUtil.createNewContact();
		
		actionPlan.Name 		= testUtil.createRandomWord();
		actionPlan.Contact__c	= contact.Id;
		actionPlan.StartDate__c	= Date.today();
		
		APTaskTemplate__c apTask = new APTaskTemplate__c();
		
		apTask.Subject__c 			= testUtil.createRandomWord();
		apTask.User__c				= testUtil.createTestUser().Id;
 		apTask.DaysFromStart__c 	= 2;
 		apTask.Type__c 				= 'Email';
 		apTask.Priority__c 			= 'Hight';
				
		System.currentPageReference().getParameters().put( 'id', null );
		System.currentPageReference().getParameters().put( 'refId', contact.Id );
		System.currentPageReference().getParameters().put( 'refType', 'Contact' );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
		
		apCreateController.actionPlans.apTasks = new List<APTaskTemplate__c>();
		apCreateController.actionPlans.apTasks.add( apTask );
		apCreateController.saveAndNew();
		
		List<ActionPlan__c> results = [ select Id from ActionPlan__c ];
		
		System.assert( !results.isEmpty(), 'Action Plan not created' );
		System.assert( results.size() == 1, 'Action Plan not created' );
		
		Test.StopTest();
    }
    
    public static testMethod void checkCompletedTasks(){
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil 	= new ActionPlansTestUtilities();
		ActionPlan__c actionPlan 			= testUtil.createNewActionPlan( 'accounts', 2 );
		
		System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
		
		Integer numTasksComplete = apCreateController.getCompleted();
		
		System.assert( numTasksComplete == 0 , 'Action plan task completed is incorrect' );
		
		Test.StopTest();
    }
    
    public static testMethod void testAddNewTask(){
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil 	= new ActionPlansTestUtilities();
		ActionPlan__c actionPlan 			= testUtil.createNewActionPlan( 'accounts', 2 );
		
		APTaskTemplate__c apTask = new APTaskTemplate__c();
		
		apTask.Action_Plan__c		= actionPlan.Id;
		apTask.Subject__c 			= testUtil.createRandomWord();
		apTask.User__c				= testUtil.createTestUser().Id;
 		apTask.DaysFromStart__c 	= 2;
 		apTask.Type__c 				= 'Email';
 		apTask.Priority__c 			= 'Hight';
				
		System.currentPageReference().getParameters().put( 'id', null );
		System.currentPageReference().getParameters().put( 'add', '1' );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
		apCreateController.actionPlans.apTasks = new List<APTaskTemplate__c>();
		apCreateController.actionPlans.apTasks.add( apTask );
		apCreateController.addTask();
		
		Test.StopTest();
    }
    
    public static testMethod void testRemoveActionPlanTask(){
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil 	= new ActionPlansTestUtilities();
		ActionPlan__c actionPlan 			= testUtil.createNewActionPlan( 'accounts', 3 );
				
		System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
		System.currentPageReference().getParameters().put( 'remove', 'editPage:apForm:editBlock:taskSection:taskTable:1:columnOne' );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
		apCreateController.actionPlans.apTasks = [ select a.Type__c, a.Subject__c, a.ActivityDate__c, a.Priority__c, a.Status__c, a.Dependent__c, 
                                    					a.Name, a.User__c, a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.APTaskTemplate__r.Name, 
                                    					a.APTaskTemplate__r.Subject__c, a.APTaskTemplate__c, a.Action_Plan__c, a.Email__c, a.Reminder__c, 
                                    					a.SendEmail__c, a.Comments__c 
                                    					from APTaskTemplate__c a 
                                    					where a.Action_Plan__c =: actionPlan.Id order by a.createdDate asc ];
                                    
		apCreateController.removeTask();
		
		Test.StopTest();
    }
    
    public static testMethod void checkActionPlanTaskList(){
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil 	= new ActionPlansTestUtilities();
		ActionPlan__c actionPlan 			= testUtil.createNewActionPlan( 'accounts', 2 );
		
		System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
		
		List<APTaskTemplate__c> apTaskList = apCreateController.getTasks();
		
		System.assert( !apTaskList.isEmpty(), 'Action plan task list is empty' );
				
		Test.StopTest();
    }
    
    public static testMethod void checkActionPlanTaskListSize(){
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil 	= new ActionPlansTestUtilities();
		ActionPlan__c actionPlan 			= testUtil.createNewActionPlan( 'accounts', 2 );
		
		System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
		
		List<APTaskTemplate__c> apTaskList 	= apCreateController.getTasks();
		Integer numTasks 					= apCreateController.getTaskSize();
		
		System.assert( !apTaskList.isEmpty(), 'Action plan task list is empty' );
				
		System.assert( numTasks == apTaskList.size(), 'Action Plan task size incorrect');
						
		Test.StopTest();
    }
    
    public static testMethod void checkSubjectItems(){
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil 	= new ActionPlansTestUtilities();
		ActionPlan__c actionPlan 			= testUtil.createNewActionPlan( 'accounts', 2 );
		
		System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
		apCreateController.actionPlans.apTasks = [ select a.Type__c, a.Subject__c, a.ActivityDate__c, a.Priority__c, a.Status__c, a.Dependent__c, 
                                    					a.Name, a.User__c, a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.APTaskTemplate__r.Name, 
                                    					a.APTaskTemplate__r.Subject__c, a.APTaskTemplate__c, a.Action_Plan__c, a.Email__c, a.Reminder__c, 
                                    					a.SendEmail__c, a.Comments__c 
                                    					from APTaskTemplate__c a 
                                    					where a.Action_Plan__c =: actionPlan.Id order by a.createdDate asc ];
                                    					
		List<Selectoption> options = apCreateController.getSubjectItems();
		
		System.assert( !options.isEmpty(), 'select options is empty' );
		System.assert( options.size() == 3, 'incorrect number of select options' );
						
		Test.StopTest();
    }
    
   	public static testMethod void testCyclicDependencyTaskSuccess(){
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		
		ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'accounts', 0 );
		
		APTaskTemplate__c newAPTask1 = new APTaskTemplate__c();
		APTaskTemplate__c newAPTask2 = new APTaskTemplate__c();
		APTaskTemplate__c newAPTask3 = new APTaskTemplate__c();
		
		newAPTask1.Subject__c 			= testUtil.createRandomWord();
 		newAPTask1.DaysFromStart__c 	= 2;
 		newAPTask1.Dependent__c			= '2';
 		newAPTask1.Type__c 				= 'Email';
 		newAPTask1.Priority__c 			= 'Hight';
 		
 		newAPTask2.Subject__c 			= testUtil.createRandomWord();
 		newAPTask2.DaysFromStart__c 	= 2;
 		newAPTask2.Dependent__c			= 'None';
 		newAPTask2.Type__c 				= 'Email';
 		newAPTask2.Priority__c 			= 'Hight';
 		
 		newAPTask3.Subject__c 			= testUtil.createRandomWord();
 		newAPTask3.DaysFromStart__c 	= 2;
 		newAPTask3.Dependent__c			= '1';
 		newAPTask3.Type__c 				= 'Email';
 		newAPTask3.Priority__c 			= 'Hight';
 		
		System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
		
		apCreateController.actionPlans.apTasks = new List<APTaskTemplate__c>();
		apCreateController.actionPlans.apTasks.add( newAPTask1 );
		apCreateController.actionPlans.apTasks.add( newAPTask2 );
		apCreateController.actionPlans.apTasks.add( newAPTask3 );
		
		apCreateController.checkCycleDependent();
		
		System.assert( apCreateController.errorMsg == '' );
		
		Test.StopTest();
    }
    
    public static testMethod void testCyclicDependencyTasksFail(){
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		
		ActionPlan__c actionPlan = testUtil.createNewActionPlan( 'accounts', 0 );
		
		APTaskTemplate__c newAPTask1 = new APTaskTemplate__c();
		APTaskTemplate__c newAPTask2 = new APTaskTemplate__c();
		APTaskTemplate__c newAPTask3 = new APTaskTemplate__c();
		
		newAPTask1.Subject__c 			= testUtil.createRandomWord();
 		newAPTask1.DaysFromStart__c 	= 2;
 		newAPTask1.Dependent__c			= '2';
 		newAPTask1.Type__c 				= 'Email';
 		newAPTask1.Priority__c 			= 'Hight';
 		
 		newAPTask2.Subject__c 			= testUtil.createRandomWord();
 		newAPTask2.DaysFromStart__c 	= 2;
 		newAPTask2.Dependent__c			= '0';
 		newAPTask2.Type__c 				= 'Email';
 		newAPTask2.Priority__c 			= 'Hight';
 		
 		newAPTask3.Subject__c 			= testUtil.createRandomWord();
 		newAPTask3.DaysFromStart__c 	= 2;
 		newAPTask3.Dependent__c			= '1';
 		newAPTask3.Type__c 				= 'Email';
 		newAPTask3.Priority__c 			= 'Hight';
 		
		System.currentPageReference().getParameters().put( 'id', actionPlan.Id );
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( actionPlan ) );
		
		apCreateController.actionPlans.apTasks = new List<APTaskTemplate__c>();
		apCreateController.actionPlans.apTasks.add( newAPTask1 );
		apCreateController.actionPlans.apTasks.add( newAPTask2 );
		apCreateController.actionPlans.apTasks.add( newAPTask3 );
		
		apCreateController.checkCycleDependent();
		
		System.assert( apCreateController.errorMsg != '' );
		
		Test.StopTest();
    }
    
    public static testMethod void checkReferedObject(){
    	
    	Test.StartTest();
		
		ActionPlansTestUtilities testUtil = new ActionPlansTestUtilities();
		
		Contact contact 		= testUtil.createNewContact();
		Account account			= testUtil.createNewAccount();
		Lead lead				= testUtil.createNewLead();
		Opportunity	opportunity = testUtil.createNewOpportunity();	
		
		System.currentPageReference().getParameters().put( 'id', null );
		System.currentPageReference().getParameters().put( 'refId', contact.id );
		System.currentPageReference().getParameters().put( 'refType', 'Contact' );
		
		ActionPlanCreationController apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		apCreateController.referedObjectInit();
		
		System.assert( apCreateController.relatedObjNameList.size() == 1 );
		
		System.currentPageReference().getParameters().put( 'id', null );
		System.currentPageReference().getParameters().put( 'refId', account.Id );
		System.currentPageReference().getParameters().put( 'refType', 'Account' );
		
		apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		apCreateController.referedObjectInit();
		
		System.assert( apCreateController.relatedObjNameList.size() == 1 );
		
		System.currentPageReference().getParameters().put( 'id', null );
		System.currentPageReference().getParameters().put( 'refId', lead.Id );
		System.currentPageReference().getParameters().put( 'refType', 'Lead' );
		
		apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		apCreateController.referedObjectInit();
		
		System.assert( apCreateController.relatedObjNameList.size() == 1 );
		
		System.currentPageReference().getParameters().put( 'id', null );
		System.currentPageReference().getParameters().put( 'refId', opportunity.Id );
		System.currentPageReference().getParameters().put( 'refType', 'Opportunity' );
		
		apCreateController = new ActionPlanCreationController( new Apexpages.StandardController( new ActionPlan__c() ) );
		apCreateController.referedObjectInit();
		
		System.assert( apCreateController.relatedObjNameList.size() == 1 );
		
		Test.StopTest();
    }
}