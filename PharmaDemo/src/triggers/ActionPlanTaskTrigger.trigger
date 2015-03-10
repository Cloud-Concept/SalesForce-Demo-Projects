trigger ActionPlanTaskTrigger on Task ( after update ){
    
    // filter completed tasks that are related to a task template
    ActionPlansTaskTriggerUtilities apttu = new ActionPlansTaskTriggerUtilities();
    apttu.closedTasks = new List<String>();
    for( Task t : Trigger.new ){
        if( t.Status == 'Completed' && t.TaskTemplateId__c != null ){
            apttu .closedTasks.add( t.TaskTemplateId__c );
        }
    }
    //Call to ActionPlansUtilities in order to proceed with creation of dependent Task
    if( !apttu.closedTasks.isEmpty() ){
        
        apttu.initDependentTaskWork(); 
    }

}