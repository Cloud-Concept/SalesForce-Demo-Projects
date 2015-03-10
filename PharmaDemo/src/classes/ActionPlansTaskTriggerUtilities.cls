/**
 * This class encapsule the most used methods
 * @author Sebastian Muñoz ( smunoz@timbasoftware.com )
 * @createdDate 04/29/2010
 */
public with sharing class ActionPlansTaskTriggerUtilities {

    public  List<String>            closedTasks     { get; set; }
    private List<APTaskTemplate__c> dependentAptts  { get; set; }
    private Map<String, Task>       newTaskMap      { get; set; }
    private List<APTaskTemplate__c> updateApttsList { get; set; }

    /**
     * Constructor
     */
    public ActionPlansTaskTriggerUtilities(){
        
    }
    
    /**
    * Initialize the functionalities to Create All dependent Tasks
    */
    public void initDependentTaskWork( ){
        if( !this.closedTasks.isEmpty() ){
            
            //Mark all APTask as 'Completed' 
            this.updateActionPlansTemplateTask();
            
            //Get all dependent APTask
            this.dependentActionPlansTemplateTask();
            
            //Create actual Task Map
            this.populateNewTaskMap();
            
            //Finaly, Create all New Tasks and Send DMLOption Emails
            this.populateUpdateApttsList();
            
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail = true;
            Database.insert( this.newTaskMap.values(), dmlo );
            
            Database.update( this.updateApttsList );
        }
    }
    
    /**
     * Update associated aptt of completed task to completed as well
     */
    private void updateActionPlansTemplateTask(){
        
        List<APTaskTemplate__c> closeApttList = new List<APTaskTemplate__c>();
        APTaskTemplate__c[] tempApttList = [ select ap.Status__c from APTaskTemplate__c ap where ap.Id IN : this.closedTasks ];
        
        for ( APTaskTemplate__c aptt : tempApttList ){
            aptt.Status__c = 'Completed';
            closeApttList.add( aptt );
        }
        
        update closeApttList ;
    }
    
    /**
     * Get list of dependent Action Plans Template Task
     */
    private void dependentActionPlansTemplateTask() {
        
        this.dependentAptts = new List<APTaskTemplate__c>();
        
        this.dependentAptts = [select a.Action_Plan__r.SkipWeekends__c, a.Action_Plan__r.Account__c, a.Priority__c, a.Status__c, 
                                 a.Action_Plan__r.Contact__c, a.Action_Plan__r.Lead__c, a.Action_Plan__r.Opportunity__c,
                                 a.Action_Plan__r.StartDate__c, a.Action_Plan__c, a.Type__c, a.Subject__c, a.ActivityDate__c, 
                                 a.Dependent__c, a.Name, a.User__c, a.User__r.Name, a.Id, a.DaysFromStart__c, a.CreatedById,
                                 a.APTaskTemplate__r.Subject__c, a.APTaskTemplate__c, a.SendEmail__c,  a.APTaskTemplate__r.Name, 
                                 a.Reminder__c, a.Comments__c 
                          from APTaskTemplate__c a where a.APTaskTemplate__c IN : this.closedTasks ];
    }
    
    
    /**
     * Cycle through list of dependent Action Plans Template Task and create actual tasks
     */
     private void populateNewTaskMap(){
        
        this.newTaskMap = new Map<String, Task>();
            
        for( APTaskTemplate__c dependentAptts: this.dependentAptts ){
            //Create the new task and template
            Task auxTask                = new Task();
            auxTask.Subject             = dependentAptts.Subject__c;
            auxTask.Priority            = dependentAptts.Priority__c;
            auxTask.OwnerId             = dependentAptts.User__c;
            auxTask.TaskTemplateId__c   = dependentAptts.Id;
            
            if( dependentAptts.Status__c == null ){
                 auxTask.Status = 'Not Started';
            }
            
            // calculate the due date of the tasks for skip weekends feature
            if( dependentAptts.Action_Plan__r.SkipWeekends__c ){
                
                Date dueDate        = dependentAptts.Action_Plan__r.StartDate__c.addDays( dependentAptts.DaysFromStart__c.intValue() );
                Integer addDays     = dependentAptts.DaysFromStart__c.intValue();
                
                // find if the due date fall on a Saturday or Sunday.  Add 1 day for Sunday and 2 for Saturday
                Date refDate        = Date.newInstance( 1900, 1, 7 );  // Jan 7 1900 = Sun
                Integer dayOfWeek   = Math.mod( refDate.daysBetween( dueDate ), 7 ); // 0 = Sun ... 6 = Sat
                
                addDays = ( dayOfWeek == 0 )? addDays + 1 : addDays; 
                addDays = ( dayOfWeek == 6 )? addDays + 2 : addDays;
                
                Date d  = Date.today();
                auxTask.ActivityDate = d.addDays( addDays );
            } 
            else{
                Date d = Date.today();
                auxTask.ActivityDate = d.addDays( dependentAptts.DaysFromStart__c.intValue() );
            }
            
            this.newTaskMap.put( auxTask.TaskTemplateId__c, auxTask );
        } // end for loop
     }
     
     /**
     * Cycle through list of dependent Action Plans Template Task and create tasks
     */
     private void populateUpdateApttsList(){
        
        this.updateApttsList = new List<APTaskTemplate__c>();
        
        for( APTaskTemplate__c dependentAptt: this.dependentAptts ){
            
            //Create the new task and template
            Task t2              = new Task();
            t2.Subject           = dependentAptt.Subject__c;
            t2.Priority          = dependentAptt.Priority__c;
            t2.OwnerId           = dependentAptt.User__c;
            t2.TaskTemplateId__c = dependentAptt.Id;
            
            dependentAptt.ActivityDate__c = dependentAptt.Action_Plan__r.StartDate__c.addDays( dependentAptt.DaysFromStart__c.intValue() );
            
            if( dependentAptt.Comments__c != null ){
                t2.Description = dependentAptt.Comments__c;
            }
            
            //set reminder based on user's default reminder setting
            if( dependentAptt.Reminder__c == true ){
                t2.isReminderSet = dependentAptt.Reminder__c;
                // get user's default reminder time
                UserPreference[] up = [ Select u.Value, u.UserId, u.Preference, u.Id From UserPreference u where u.Preference = '58' and u.UserId = :dependentAptt.User__c ];
                
                if( up.size() > 0 ){
                    t2.ReminderDateTime = datetime.newInstance( dependentAptt.ActivityDate__c.year(), dependentAptt.ActivityDate__c.month(), dependentAptt.ActivityDate__c.day(), 0, 0, 0 );
                    t2.ReminderDateTime = t2.ReminderDateTime.addMinutes( Integer.valueOf( up[0].value ) );
                }
                else{
                    if( dependentAptt.ActivityDate__c != null ){
                        t2.ReminderDateTime = datetime.newInstance( dependentAptt.ActivityDate__c.year(), dependentAptt.ActivityDate__c.month(), dependentAptt.ActivityDate__c.day(), 0, 0, 0 );
                    }
                }
            } 
            
            //Get Action Plan WhatID
            if( dependentAptt.Action_Plan__r.Account__c != null ){
                t2.WhatId = dependentAptt.Action_Plan__r.Account__c;
            }
            
            if( dependentAptt.Action_Plan__r.Contact__c != null ){
                t2.WhoId = dependentAptt.Action_Plan__r.Contact__c;
            }
            
            if( dependentAptt.Action_Plan__r.Lead__c != null ){
                t2.WhoId = dependentAptt.Action_Plan__r.Lead__c;
            }
            
            if( dependentAptt.Action_Plan__r.Opportunity__c != null ){
                t2.WhatId = dependentAptt.Action_Plan__r.Opportunity__c;
            }
                
            t2.Type         = dependentAptt.Type__c;
            t2.Status       = 'Not Started';
            t2.ActivityDate = dependentAptt.ActivityDate__c;
            
            this.newTaskMap.put( t2.TaskTemplateId__c, t2 );
            this.updateApttsList.add( dependentAptt ) ;
        }
     }
}