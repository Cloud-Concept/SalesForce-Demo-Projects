trigger ActionPlanTrigger on ActionPlan__c ( before delete ){
  
  // if action plan is deleted, delete all tasks associated with it
  set<ID> apIds    = new set<ID>();
  set<ID> apttIds  = new set<ID>();
  List<Task> tasks = new List<Task>();
  
  for( ActionPlan__c ap : trigger.old ){
    apIds.add( ap.Id );
  }
    
  for( APTaskTemplate__c aptt : [ select Id from APTaskTemplate__c where Action_Plan__c in :apIds ] ){
    apttIds.add( aptt.Id );
  }

  delete [ select Id from Task where Status != 'Completed' and TaskTemplateId__c in :apttIds ];
}