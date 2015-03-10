/**
* @author Matias Menafra
* @createdate 04/29/2010
*/
public with sharing class ActionPlansUtilities{
    
    public ActionPlanTemplate__c    actionPlanTemplate;
    public List<APTTaskTemplate__c> aptTasks;
    public ActionPlan__c            actionPlan;
    public List<APTaskTemplate__c>  apTasks;
    public List<APTaskTemplate__c>  apTasksOrg ;
    public String                   errorMsg;
    public List<APTTaskTemplate__c> pendingTemplateDeletes;
    public List<APTaskTemplate__c>  pendingDeletes;
    public Integer                  taskLimit;
    public List<String>             relatedObjIds;
    public String                   relatedObjName;
    public String[]                 subjects;
    
    /**
    * Constructor
    * @param stdController
    */
    public ActionPlansUtilities( ActionPlan__c action ){
        
        this.actionPlan = action;
        this.subjects   = new String[]{};
        this.taskLimit  = 75;
        this.pendingDeletes = new List<APTaskTemplate__c>();
    }
    
    /**
    * Gets the related Object Name
    * @return String
    */
    public String getRelatedObjName(){
        return  this.relatedObjName;
    }
    
    /**
    * Gets the related Object Ids
    * @return List<String>
    */
    public List<String> relatedObjIds(){
        return  this.relatedObjIds;
    }
    
    /**
    * Gets all available Action Plans
    * @return List<ActionPlan__c>
    */
    public List<ActionPlan__c> getActionPlans(){
        
        return [ select a.Id, a.Name, a.CreatedById, a.StartDate__c, a.Action_Plan_Template__r.Name, a.Action_Plan_Template__r.Id, 
                    a.Action_Plan_Template__c, a.Account__c, a.Contact__c, a.Lead__c, a.Opportunity__c 
                    from ActionPlan__c a ];
    }
    
    
    /**
    * Checks if Action Plan Tasks has cycling dependency.
    * @return Boolean
    */
    public Boolean checkCycleDependent(){
        Boolean exists = false;
        Integer index = 0;
        for( APTaskTemplate__c t : this.apTasks ){
            if( t.Dependent__c != 'None' && t.Dependent__c != null ){
                Integer tempIndex   = Integer.valueOf( t.Dependent__c );
                APTaskTemplate__c link = this.apTasks[tempIndex];
                if ( dependantCycle(t,link,index) ){
                    return true;
                }
            }
            index++;
        }
        return exists;
    }
    
    /**
    *
    */
    private Boolean dependantCycle( APTaskTemplate__c originTask, APTaskTemplate__c destinyTask, Integer index ){
        
        //Integer tempIndexOrigin = originTask.id;
        if( destinyTask.Dependent__c != 'None' && destinyTask.Dependent__c != null ){
            
            Integer tempIndexDestiny    = Integer.valueOf(destinyTask.Dependent__c);
            APTaskTemplate__c link      = this.apTasks[tempIndexDestiny];
            
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
    
    /**
    * Saves Action Plan Instance and task. Also creates all due dates for tasks, then redirects to the AP list
    */
    public void saveAp(){
        
        Set<Id> taskIds = new Set<Id>();
         
        Savepoint sp = Database.setSavepoint();
        
        //check for pendingDeletes
        this.checkPendingDeletes();
        
        ActionPlan__c ap = this.actionPlan;
        
        if( ApexPages.currentPage().getParameters().get( 'refType' ) != null ){
            String oName = ApexPages.currentPage().getParameters().get( 'refType' );
            String oId = ApexPages.currentPage().getParameters().get( 'refId' );
            
            if( 'Account'.equalsIgnoreCase( oName ) ){
                ap.Account__c = oId;
            }
            if( 'Contact'.equalsIgnoreCase( oName ) ){
                ap.Contact__c = oId;
            }
            if( 'Lead'.equalsIgnoreCase( oName ) ){
                ap.Lead__c = oId;
            }
            if( 'Opportunity'.equalsIgnoreCase( oName ) ){
                ap.Opportunity__c = oId;
            }
        }
        upsert ap;
        
        
        // save tasks to the template and attach relation to Action Plan
        for( APTaskTemplate__c t : this.apTasks ){
            if( t.Action_Plan__c == null ){
                t.Action_Plan__c = ap.Id;
            } 
            t.Name = ap.Name + ' - Task Template';
        }
        
        try{
            upsert this.apTasks;
        } 
        catch( exception e ){
            Database.rollback( sp );
        }
        
        // run through the tasks and take care of dependents - not done in the previous because we need the Ids
        for( APTaskTemplate__c t : this.apTasks ){
            if( t.Dependent__c != 'None' && t.Dependent__c != null ){ // setup dependency
                Integer tempIndex   = Integer.valueOf( t.Dependent__c );
                t.APTaskTemplate__c = apTasks[tempIndex].Id;
            }
            else{
                t.APTaskTemplate__c = null;
                // create due date
                // calculate the due date of the tasks for skip weekends feature
                if( t.Status__c == null ){
                    t.Status__c = 'Not Started';
                } 
                
                if( ap.SkipWeekends__c == true ){
                    
                    Date dueDate    = ap.StartDate__c.addDays( t.DaysFromStart__c.intValue() );
                    Integer addDays = t.DaysFromStart__c.intValue();
                    
                    // find if the due date fall on a Saturday or Sunday.  Add 1 day for Sunday and 2 for Saturday
                    Date refDate        = Date.newInstance(1900, 1, 7);  // Jan 7 1900 = Sun
                    Integer dayOfWeek   = Math.mod(refDate.daysBetween(dueDate), 7); // 0 = Sun ... 6 = Sat
                    
                    if( ap.SkipDay__c == 'Friday' ){ 
                        // push to friday
                        if( dayOfWeek == 0 ) addDays = addDays - 2;
                        if( dayOfWeek == 6 ) addDays--;
                    } 
                    else{ 
                        // push to monday
                        if( dayOfWeek == 0 ){
                            addDays++;
                        } 
                        if( dayOfWeek == 6 ){
                            addDays = addDays + 2;
                        } 
                    }
                    
                    t.ActivityDate__c = ap.StartDate__c.addDays( addDays );
                } 
                else{
                    t.ActivityDate__c = ap.StartDate__c.addDays( t.DaysFromStart__c.intValue() );
                }
            }
        }
        
        try{
            upsert this.apTasks;
        } 
        catch( exception e ){
            Database.rollback( sp );
        }
        
        List<Task> myTasksWithEmail         = new List<Task>();
        List<Task> myTasksWithOutEmail      = new List<Task>();
        // run through tasks again and create actual tasks with due dates
        for( APTaskTemplate__c apTask : this.apTasks ){
            if( apTask.APTaskTemplate__c == null ){ 
                // check for no dependency
                if( apTask.Status__c != 'Completed' ){ 
                    // if the task is competed already make no changes to it
                    Boolean taskFound = false;
                    Task t;
                    Task[] checkId;
                    
                    // check if task exists already
                    if( apTask.Id != null ){
                        checkId = [ select t.Id from Task t where t.TaskTemplateId__c = :apTask.Id limit 1 ];
                        if( checkId.size() > 0 ){
                            taskFound = true;
                        } 
                    } 
                    
                    if( taskFound == true ){
                        t = checkId[0];
                    }
                    else{
                        t = new Task();
                    }
                    
                    t.Subject           = apTask.Subject__c;
                    t.Priority          = apTask.Priority__c;
                    t.OwnerId           = apTask.User__c;
                    t.TaskTemplateId__c = apTask.Id; 
                    
                    // fake link to AP Task Template
                    if( apTask.Comments__c != null ){
                        t.Description = apTask.Comments__c;
                    } 
                    
                    //set reminder based on user's default reminder setting
                    if( apTask.Reminder__c == true ){
                        t.isReminderSet = apTask.Reminder__c;
                        
                        // get user's default reminder time
                        UserPreference[] up = [ Select u.Value, u.UserId, u.Preference, u.Id 
                                                From UserPreference u 
                                                where u.Preference = '58' and u.UserId = :apTask.User__c ];
                        if( up.size() > 0 ){
                            t.ReminderDateTime = datetime.newInstance( apTask.ActivityDate__c.year(), apTask.ActivityDate__c.month(), apTask.ActivityDate__c.day(), 0, 0, 0 );
                            t.ReminderDateTime = t.ReminderDateTime.addMinutes( Integer.valueOf(up[0].value) );
                        }
                        else{
                            t.ReminderDateTime = datetime.newInstance( apTask.ActivityDate__c.year(), apTask.ActivityDate__c.month(), apTask.ActivityDate__c.day(), 0, 0, 0 );
                        }                           
                    }               
                    
                    //link to Action Plan's Related To Object
                    if( ap.Account__c != null ){
                        t.WhatId = ap.Account__c;
                    } 
                    
                    if( ap.Contact__c != null ){
                        t.WhoId = ap.Contact__c;
                    } 
                    
                    if( ap.Lead__c != null ){
                        t.WhoId = ap.Lead__c;
                    } 
                    
                    if( ap.Opportunity__c != null ){
                        t.WhatId = ap.Opportunity__c;
                    } 
                    
                    t.Type = apTask.Type__c;
                    t.Status        = 'Not Started';
                    t.ActivityDate  = apTask.ActivityDate__c;

                    // check for send email notification checkbox
                    if( apTask.SendEmail__c == true && t.Id == null ){
                        myTasksWithEmail.add( t );
                    }
                    else{
                        myTasksWithOutEmail.add( t );
                    }
                }
            }   
            
            try{                        
                    if( myTasksWithEmail.size() > 0 ){
                        Database.DMLOptions dmlo = new Database.DMLOptions();
                        dmlo.EmailHeader.triggerUserEmail = true;
                        database.insert( myTasksWithEmail, dmlo );
                    }
                    
                    if( myTasksWithOutEmail.size() > 0 ){
                        upsert( myTasksWithOutEmail );
                    }
                } 
                catch( exception e ){
                    Database.rollback( sp );   
                }
        }
    }
    
    /**
    * Check if have Task pending to delete
    */
    public void checkPendingDeletes(){
         
        if( this.pendingDeletes != null ) {
            List<Task>  taskToDelete    = new List<Task>();
            List<Id>    deleteApttIds   = new List<Id>();
            
            for( APTaskTemplate__c deleteAptt : this.pendingDeletes ){
                deleteApttIds.add(deleteAptt.Id);
            }
            
            taskToDelete = [select t.Id from Task t where t.TaskTemplateId__c IN : deleteApttIds];
            
            delete taskToDelete;
            delete pendingDeletes;
        }

    }
    
    /**
    * Saves Action Plan Instance and tasks and redirects to that detail page
    * @return newPage
    */
    public PageReference save(){
        
        try {
        	saveAp();
        }
        catch ( DmlException e ){
        	
        	Apexpages.addMessages(e);
        	return null;
        }
        
        String oName = ApexPages.currentPage().getParameters().get( 'refType' );
        PageReference newPage; 
        String prefix;
        
        if( 'Account'.equalsIgnoreCase( oName ) ){
            prefix  = Account.sObjectType.getDescribe().getKeyPrefix();
            newPage = new PageReference( '/' + prefix );
        }
        if( 'Contact'.equalsIgnoreCase( oName ) ){
            prefix  = Contact.sObjectType.getDescribe().getKeyPrefix();
            newPage = new PageReference( '/' + prefix );
        }
        if( 'Lead'.equalsIgnoreCase( oName ) ){
            prefix  = Lead.sObjectType.getDescribe().getKeyPrefix();
            newPage = new PageReference( '/' + prefix );
        }
        if( 'Opportunity'.equalsIgnoreCase( oName ) ){
            prefix  = Opportunity.sObjectType.getDescribe().getKeyPrefix();
            newPage = new PageReference( '/' + prefix );
        }
        
        if( oName == '' ){
        	
        	if( this.actionPlan.Account__c != null && this.actionPlan.Account__c != '' ){
        		prefix  = Account.sObjectType.getDescribe().getKeyPrefix();
            	newPage = new PageReference( '/' + prefix );
        	}
        	else if( this.actionPlan.Contact__c != null && this.actionPlan.Contact__c != '' ){
        		prefix  = Contact.sObjectType.getDescribe().getKeyPrefix();
            	newPage = new PageReference( '/' + prefix );
        	}
        	else if( this.actionPlan.Lead__c != null && this.actionPlan.Lead__c != '' ){
        		prefix  = Lead.sObjectType.getDescribe().getKeyPrefix();
            	newPage = new PageReference( '/' + prefix );
        	}
        	else if( this.actionPlan.Opportunity__c != null && this.actionPlan.Opportunity__c != '' ){
        		prefix  = Opportunity.sObjectType.getDescribe().getKeyPrefix();
            	newPage = new PageReference( '/' + prefix );
        	}
        }
        
		if( newPage == null ){
			prefix  = ActionPlan__c.sObjectType.getDescribe().getKeyPrefix();
            newPage = new PageReference( '/' + prefix );
		}
        // Send the user to the detail page for the new action plan.
        newPage.setRedirect( true );
        return newPage;
        
    }

    /**
    * Saves Action Plan Handler.
    * @return Pagereference called Method
    */
    public PageReference saveHandler(){
        
        String oIds = ApexPages.currentPage().getParameters().get( 'refId' );
        
        List<String> oIdsList = new List<String>();

	        if( oIds != null ){
	            oIdsList = oIds.split(',');
	            if( oIdsList.size() > 1 ){
	                return this.saveMultiple();
	            }
	            else{
	                return this.save();
	            }
	        }
	        else{
	            return this.save();
	        }
        
    }  
    
    /**
    * Save Action Plans for Multiple Related Object Instances.
    * @return Pagereference
    */
    public PageReference saveMultiple(){
        
        String oName                    = ApexPages.currentPage().getParameters().get( 'refType' );
        String oIds                     = ApexPages.currentPage().getParameters().get( 'refId' );
        List<ActionPlan__c> apList      = new List<ActionPlan__c>();
        List<APTaskTemplate__c> aptList = new List<APTaskTemplate__c>();
        
        if( ( oName != null || oName != '' ) && ( oIds != null || oIds != '' ) ){
            
            Savepoint sp = Database.setSavepoint();
            List<String> oIdsList = oIds.split(',');

            //Save all AP instance for the current Object and return a List of inserted ap
            apList = this.saveActionPlanObj( oIdsList );
            upsert apList;
            //End of Save all Ap
            
            //Now for each inserted AP we should run through tasks and create them
            this.apTasksOrg = new List<APTaskTemplate__c>();
            this.apTasksOrg.addAll( this.apTasks );
            this.apTasks.clear();
            
            for( ActionPlan__c apl : apList ){ 
                this.apTasks.addAll( this.saveAPTaskObj( apl, sp ) );
            }
            
            Database.upsert( this.apTasks );

            List<String> apTasksIds = new List<String>();
            for( APTaskTemplate__c aptt : this.apTasks ){
                apTasksIds.add( aptt.Id );
            }
            
            ActionPlansBatchTaskBuilder taskBatch = new ActionPlansBatchTaskBuilder( apTasksIds );
            Database.ExecuteBatch( taskBatch );
            //End of Save all Task
        }
        
        PageReference newPage; 
        String prefix;
        
        if( 'Account'.equalsIgnoreCase( oName ) ){
            prefix  = Account.sObjectType.getDescribe().getKeyPrefix();
            newPage = new PageReference( '/' + prefix );
        }
        if( 'Contact'.equalsIgnoreCase( oName ) ){
            prefix  = Contact.sObjectType.getDescribe().getKeyPrefix();
            newPage = new PageReference( '/' + prefix );
        }
        if( 'Lead'.equalsIgnoreCase( oName ) ){
            prefix  = Lead.sObjectType.getDescribe().getKeyPrefix();
            newPage = new PageReference( '/' + prefix );
        }
        if( 'Opportunity'.equalsIgnoreCase( oName ) ){
            prefix  = Opportunity.sObjectType.getDescribe().getKeyPrefix();
            newPage = new PageReference( '/' + prefix );
        }
        newPage.setRedirect( true );
        return newPage;
    }
    
    /**
    * Saves Action Plan Instance.
    * @return List<APTaskTemplate__c>
    */
    public List<APTaskTemplate__c> saveAPTaskObj( ActionPlan__c ap, Savepoint sp ){
        
        List<APTaskTemplate__c> aptList = new List<APTaskTemplate__c>();
        
        //Now for each inserted ap we should run through tasks and create them
            for( APTaskTemplate__c t : this.apTasksOrg ){
                APTaskTemplate__c nt = new APTaskTemplate__c();
                nt = t.clone(); 
                nt.Action_Plan__c       = ap.Id;
                nt.Name                 = ap.Name + ' - Task Template';
                nt.Email__c             = t.Email__c;
                aptList.add( nt );
            }
            insert aptList;
        //End of Save all Task
        
        //Now run through the tasks and take care of dependents - not done in the previous because we need the Ids
        for(APTaskTemplate__c t : aptList ){
            
            if( t.Dependent__c != 'None' && t.Dependent__c != null ){
                    Integer tempIndex   = Integer.valueOf( t.Dependent__c );
                    t.APTaskTemplate__c = aptList[tempIndex].Id;
            }
            else{ 
                // create due date
                // calculate the due date of the tasks for skip weekends feature
                if( t.Status__c == null ){
                    t.Status__c = 'Not Started';
                } 
                
                if( ap.SkipWeekends__c == true ){
                    
                    Date dueDate    = ap.StartDate__c.addDays( t.DaysFromStart__c.intValue() );
                    Integer addDays = t.DaysFromStart__c.intValue();
                    
                    // find if the due date fall on a Saturday or Sunday.  Add 1 day for Sunday and 2 for Saturday
                    Date refDate        = Date.newInstance(1900, 1, 7);  // Jan 7 1900 = Sun
                    Integer dayOfWeek   = Math.mod(refDate.daysBetween(dueDate), 7); // 0 = Sun ... 6 = Sat
                    
                    if( ap.SkipDay__c == 'Friday' ){ 
                        // push to friday
                        addDays = ( dayOfWeek == 0 ) ? addDays - 2 : addDays ;
                        addDays = ( dayOfWeek == 6 ) ? addDays-- : addDays ;
                    } 
                    else{ 
                        // push to monday
                        addDays = ( dayOfWeek == 0 ) ? addDays++   : addDays ;
                        addDays = ( dayOfWeek == 6 ) ? addDays + 2 : addDays ; 
                    }
                    t.ActivityDate__c = ap.StartDate__c.addDays( addDays );
                } 
                else{
                    t.ActivityDate__c = ap.StartDate__c.addDays( t.DaysFromStart__c.intValue() );
                }
            }
        }
        
        //End dependents 
        return aptList;
    }
    
    /**
    * Saves Action Plan Instance.
    * @return List<ActionPlan__c>
    */
    public List<ActionPlan__c> saveActionPlanObj( List<String> oIdsList ){
        
        List<ActionPlan__c> apAux = new List<ActionPlan__c>();
        String oName                    = ApexPages.currentPage().getParameters().get( 'refType' );
        String oIds                     = ApexPages.currentPage().getParameters().get( 'refId' );
        
        for( String relObjId : oIdsLIst ){
            ActionPlan__c ap = new ActionPlan__c();
            ap = this.actionPlan.clone();
                
            if( 'Account'.equalsIgnoreCase( oName ) ){
                ap.Account__c = relObjId;
            }
            
            if( 'Contact'.equalsIgnoreCase( oName ) ){
                ap.Contact__c = relObjId;
            }
            
            if( 'Lead'.equalsIgnoreCase( oName ) ){
                ap.Lead__c = relObjId;
            }
            
            if( 'Opportunity'.equalsIgnoreCase( oName ) ){
                ap.Opportunity__c = relObjId;
            }
            apAux.add(ap);
        }

        return apAux;
    }
     
    /**
    * Saves Action Plan Instance and tasks and returns to the creation page with the previous Action Plan's details.
    * @return newPage
    */
    public PageReference saveAndNew(){
        
        saveAp();
        PageReference newPage = new PageReference( '/apex/ActionPlanCreation?' + 'clone=1' );
        newPage.setRedirect( true );
        
        return newPage;
    }

    /**
    * Gets Tasks related to an Action Plan
    * @return apTasks
    */
    public List<APTaskTemplate__c> getTasks(){
        
        if( this.apTasks == null || this.apTasks.size() == 0 ){
            if( ApexPages.currentPage().getParameters().get( 'templateId' ) != null ){
                String tempApId = ApexPages.currentPage().getParameters().get( 'templateId' );
                
                aptTasks = [ select a.Type__c, a.Subject__c, a.Priority__c, a.Dependent__c, a.Name, a.User__c, a.User__r.Name, a.Id, 
                                a.DaysFromStart__c, a.CreatedById, a.Action_Plan_Template__c, a.APTTaskTemplate__r.Subject__c, 
                                a.Reminder__c, a.SendEmail__c, a.Comments__c 
                                From APTTaskTemplate__c a
                                where a.Action_Plan_Template__c= :TempApId ];
                
                this.apTasks = new List<APTaskTemplate__c>();
                
                for( APTTaskTemplate__c aptTask : aptTasks ){
                	
                	
                	System.debug('\n\n\n\n\n\n\n\n\n\n\n\n'+aptTask.User__c +'\n\n\n\n\n\n\n\n\n\n\n\n');
                	System.debug('\n\n\n\n\n\n\n\n\n\n\n\n'+UserInfo.getUserName()  +'\n\n\n\n\n\n\n\n\n\n\n\n');
                	System.debug('\n\n\n\n\n\n\n\n\n\n\n\n'+UserInfo.getUserId()  +'\n\n\n\n\n\n\n\n\n\n\n\n');
                	String userId = ( aptTask.User__c != null ) ? aptTask.User__c : UserInfo.getUserId() ;
                	
                	
                    APTaskTemplate__c t = new APTaskTemplate__c();
                    t.Type__c           = aptTask.Type__c;
                    t.Subject__c        = aptTask.Subject__c;
                    t.Priority__c       = aptTask.Priority__c;
                    t.Dependent__c      = aptTask.Dependent__c;
                    t.Name              = aptTask.Name ;
                    t.DaysFromStart__c  = aptTask.DaysFromStart__c;

                    t.User__c           = userId;
                    t.Reminder__c       = aptTask.Reminder__c;
                    t.SendEmail__c      = aptTask.SendEmail__c;
                    t.Comments__c       = aptTask.Comments__c;
                    this.apTasks.add(t);
                }
            }else if( ApexPages.currentPage().getParameters().get( 'Id' ) != null ){
                String TempApId = ApexPages.currentPage().getParameters().get( 'Id' );
                this.apTasks = [ select a.Type__c, a.Subject__c, a.ActivityDate__c, a.Priority__c, a.Status__c, a.Dependent__c, 
                                    a.Name, a.User__c, a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById, a.APTaskTemplate__r.Name, 
                                    a.APTaskTemplate__r.Subject__c, a.APTaskTemplate__c, a.Action_Plan__c, a.Email__c, a.Reminder__c, 
                                    a.SendEmail__c, a.Comments__c 
                                    from APTaskTemplate__c a 
                                    where a.Action_Plan__c = : TempApId order by a.createdDate asc ];
            }
            else{
                this.apTasks        = new List<APTaskTemplate__c>();
                APTaskTemplate__c t = new APTaskTemplate__c();
                t.Reminder__c = true;
                this.apTasks.add( t );
            }
            
            // Clone. Clear Ids.
            if( ApexPages.currentPage().getParameters().get( 'clone' ) == '1' ){ 
                List<APTaskTemplate__c> tC = this.apTasks.deepClone(false);
                this.apTasks.clear();
                this.apTasks = tC;
                
                // clear task relations
                for( APTaskTemplate__c t : this.apTasks ){
                    t.Action_Plan__c = null;
                }
            }
        }
        
        return this.apTasks;
    }
    
    /**
    * Creates a blank Task object and adds it to List<Task>
    */
    public void addTask(){
        
        if( ApexPages.currentPage().getParameters().get('add') == '1' ){
            if( this.apTasks.size() >= taskLimit ){
                errorMsg = 'Task limit reached.';
            }
            else{
                APTaskTemplate__c t = new APTaskTemplate__c();
                t.Reminder__c = true;
                
                // validate assigned to, priority, subject before adding another
                Integer taskSize = apTasks.size();
                if( this.apTasks[taskSize - 1].User__c != null && this.apTasks[taskSize - 1].Subject__c != null ){
                    this.apTasks.add(t);
                }
            }
        }       
    }
    
    /**
    * Remove a specific index in the List<Task>
    */
    public void removeTask(){
        
        if( ApexPages.currentPage().getParameters().get( 'remove' ) != null ){
            String removeIndex      = ApexPages.currentPage().getParameters().get( 'remove' );
            String[] newRemoveIndex = removeIndex.split( ':', -2 );
            Integer taskIndex       = Integer.valueOf( newRemoveIndex[5] );
            Id deletedId            = this.apTasks[taskIndex].Id;
            
            //check for dependent children and clear them since the parent is being removed.
            for( APTaskTemplate__c apTask : this.apTasks ){
                if( apTask.APTaskTemplate__c == deletedId ){ 
                    apTask.APTaskTemplate__c    = null;
                    apTask.Dependent__c         = null;
                }
            }
            
            // before remove check if it's exists in the DB, if so, add to pendingDeletes to be deleted on save.
            if( this.apTasks[taskIndex].Id != null ){
                if( pendingDeletes == null ){
                    pendingDeletes = new List<APTaskTemplate__c>();
                } 
                pendingDeletes.add( this.apTasks[taskIndex] );
            }
            
            apTasks.remove( taskIndex );
            
            // clear errorMsg if it's set.
            if( this.apTasks.size() < taskLimit ){
                 errorMsg = null;
            }
        }
    }
    
    /**
    * Retrieves size of APT Template Tasks List.
    * @return apTasks
    */
    public Integer getTaskSize(){
        return this.apTasks.size();  
    }
    
    /**
    * creates a selectList of task subjects to be used with creating task dependencies.
    * @return options
    */
    public List<SelectOption> getSubjectItems(){
        
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( 'None', '--None--' ) );
        integer i = 0;
        
        if( this.apTasks != null ){
            for( APTaskTemplate__c t : this.apTasks ){
                if( t.Subject__c != null ){
                     options.add(new SelectOption( string.valueOf(i), t.Subject__c+' ('+ (i+1) +')') );
                }
                i++;
            }
        }
        
        return options;
    }
    
    /**
    * Retrieves number of completed tasks
    * @return ts
    */
    public Integer getCompleted(){
        
        List<APTaskTemplate__c> ts = new List<APTaskTemplate__c>();
        String tempApId = ApexPages.currentPage().getParameters().get('Id');
        
        ts = [ select t.Id 
                From APTaskTemplate__c t 
                where t.Status__c = 'Completed' and t.ActivityDate__c != null and t.Action_Plan__c = :tempApId ];
        
        return (ts != null) ? ts.size() : 0;
    }
    
    /**
    * Deletes the current Action Plan loaded and redirects tot he AP Template List
    * @return newPage
    */
    public PageReference deletePlan(){
        
        Savepoint sp        = Database.setSavepoint();
        ActionPlan__c ap    = actionPlan;
        List<APTaskTemplate__c> aptts = [ select a.Id from APTaskTemplate__c a where a.Action_Plan__c = :ap.Id ];
        
        //delete tasks by cycling through aptts
        for( APTaskTemplate__c aptt : aptts ){
            Task[] testT = [ select t.Id from Task t where TaskTemplateId__c = :aptt.Id ];
            
            if( testT.size() > 0 ){
                try{
                    delete testT[0];
                }catch( exception e ){
                    Database.rollback( sp );
                }
            }
        }
        
        //delete ap, which will also delete aptts via master-detail relationship
        try{
            delete ap;
        } catch( exception e ){
            Database.rollback( sp );
        }
        
        // Send the user to the detail page for the new account.
        PageReference newPage = new PageReference( '/apex/ActionPlanList' );
        newPage.setRedirect( true );
        
        return newPage;
    }
    
    /**
    * Checks if Action Plan Template has been changed since the creation of the Action Plan.
    * @return Boolean
    */
    public Boolean getVersion(){
        
        if( actionPlan.Action_Plan_Template__c != null ){
            ActionPlanTemplate__c TempApt = [ select LastModifiedDate 
                                                from ActionPlanTemplate__c 
                                                where Id = :actionPlan.Action_Plan_Template__c];
                                                
            if( TempApt.LastModifiedDate > actionPlan.createdDate ){
                return true;
            }  
        }
        
        return false;
    }
}