/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ActionPlansTaskTriggerUtilitiesTest {

    /**
    * test trigger without skipweekends 
    */
    public static testMethod void testTrigger1() {
    	
    	ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
    	ActionPlan__c ap 			= ge.createNewActionPlan( 'accounts', 0 );
    	
    	
    	List<Id> apTTaskIds 		= new List<Id>();
    	List<Task> apTask 			= new List<Task>();
    	List<APTaskTemplate__c> aptt = new List<APTaskTemplate__c>();
	
	   	for( Integer i = 0; i < 4; i++ ){
	   		APTaskTemplate__c at = new APTaskTemplate__c();
	   		at.Action_Plan__c 	 = ap.Id;
	   		at.DaysFromStart__c  = 2.0;
	   		at.User__c			 = ge.createTestUser().Id;
	   		at.SendEmail__c		 = false;
	   		at.Subject__c		 = 'Test '+ i;
	   		at.Type__c			 = 'Email';
	   		at.Priority__c		 = 'Low';
	   		at.APTaskTemplate__c = ( i > 0 ) ? aptt[ i-1 ].Id : null;
	   		insert at;
	   		aptt.add(at);
	   		apTTaskIds.add( at.Id );
	   		
	   		if( i == 0 ){
	   			Task x 				= new Task();
	   			x.Priority 			= at.Priority__c;
	   			x.Status			= 'Open';
	   			x.TaskTemplateId__c	= at.Id;
	   			x.Subject			= at.Subject__c;
	   			insert x;
	   		}
	   	}
 	
	   	apTask = [Select Status, Id from Task where TaskTemplateId__c IN : apTTaskIds]; 
	   	for( Task t : apTask ){ 
	   		t.Status = 'Completed';
	   	} 
	   	update apTask;
		
		apTask = [Select Id from Task where TaskTemplateId__c =: apTTaskIds[1] ];
		System.assert( !apTask.isEmpty() );
		
    }
    
	/**
    * test trigger with skipweekends 
    */
    public static testMethod void testTrigger2() {
    	
    	ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
    	ActionPlan__c ap 			= ge.createNewActionPlan( 'accounts', 0 );
    	ap.SkipWeekends__c			= true;
    	update ap;
    	
    	List<Id> apTTaskIds 		= new List<Id>();
    	List<Task> apTask 			= new List<Task>();
    	List<APTaskTemplate__c> aptt = new List<APTaskTemplate__c>();
	
	   	for( Integer i = 0; i < 4; i++ ){
	   		APTaskTemplate__c at = new APTaskTemplate__c();
	   		at.Action_Plan__c 	 = ap.Id;
	   		at.DaysFromStart__c  = 2.0;
	   		at.User__c			 = ge.createTestUser().Id;
	   		at.SendEmail__c		 = false;
	   		at.Subject__c		 = 'Test '+ i;
	   		at.Type__c			 = 'Email';
	   		at.Priority__c		 = 'Low';
	   		at.Comments__c		 = 'My Coment';
	   		at.Reminder__c		 = true;
	   		at.APTaskTemplate__c = ( i > 0 ) ? aptt[ i-1 ].Id : null;
	   		insert at;
	   		aptt.add(at);
	   		apTTaskIds.add( at.Id );
	   		
	   		if( i == 0 ){
	   			Task x 				= new Task();
	   			x.Priority 			= at.Priority__c;
	   			x.Status			= 'Open';
	   			x.TaskTemplateId__c	= at.Id;
	   			x.Subject			= at.Subject__c;
	   			insert x;
	   		}
	   	}
	   	
	   	
	   	apTask = [Select Status, Id from Task where TaskTemplateId__c IN : apTTaskIds]; 
	   	for( Task t : apTask ){
	   		t.Status = 'Completed';
	   	} 
	   	update apTask;
	   	
	   	apTask = [Select Id from Task where TaskTemplateId__c =: apTTaskIds[1] ];
		System.assert( !apTask.isEmpty() );
	   	
	   	delete ap;
	   	
	   	apTask = [Select Id from Task where TaskTemplateId__c =: apTTaskIds[1] ];
		System.assert( apTask.isEmpty() );
		 
    }

}