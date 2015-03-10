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
private class PlanogramTestClasses {

    static testMethod void myUnitTest() {
        //Test The Account Planogram Trigger
        
        Product2 product = new Product2();
        product.Name = 'Test Product';
        product.Show_in_Planogram__c = true;
        insert product;
        
        
        
        Account a = new Account();
        a.Name = 'Test Class Debug Account';
        
        a.AccountPlanogram__c ='';
        
        for(Integer i = 0; i< 15; i++) {
        	a.AccountPlanogram__c += product.Id +',';		        	
        }
        a.AccountPlanogram__c += product.Id;
        insert a;
        
        Account fullAccount = [Select (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, ConnectionReceivedId, ConnectionSentId, Account__c, Space_Slot_Number__c, Product__c, Index__c, Product_Group_Image__c From Planograms__r) From Account a where id =: a.Id];
        
        //there should be 16 planogram objects
        List<Planogram__c> planograms = fullAccount.Planograms__r;
        System.assertEquals(16, planograms.size());
                
        
        //Test The Planogram Ext
         Account acc = new Account();
        acc.Name = 'Test Class Debug Account';
        acc.AccountPlanogram__c ='';
          for(Integer i = 0; i< 15; i++) {
        	acc.AccountPlanogram__c += ',';		        	
        }
        acc.AccountPlanogram__c += '';
        insert acc;
                
        //Test The Planogram Ext
        ApexPages.StandardController std = new ApexPages.Standardcontroller(acc);
        PlanogramExt planogram = new PlanogramExt (std);
        acc.AccountPlanogram__c ='';
        
        for(Integer i = 0; i< 15; i++) {
        	acc.AccountPlanogram__c += product.Id +',';		        	
        }
        acc.AccountPlanogram__c += product.Id;
        
        planogram.customSave();
        
        fullAccount = [Select (Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, ConnectionReceivedId, ConnectionSentId, Account__c, Space_Slot_Number__c, Product__c, Index__c, Product_Group_Image__c From Planograms__r) From Account a where id =: acc.Id];
        
        //there should be 16 planogram objects
        planograms = fullAccount.Planograms__r;
        System.assertEquals(16, planograms.size());
        
        //Test the Planogram Setup Class
        List<Product2> products = [Select p.Show_in_Planogram__c, p.Name, p.Id From Product2 p where Show_in_Planogram__c = true];
        delete products;
        
        PlanogramSetup setup = new PlanogramSetup();
        setup.CreateProducts();
        
        products = [Select p.Show_in_Planogram__c, p.Name, p.Id From Product2 p where Show_in_Planogram__c = true];
        
        System.assertEquals(16, products.size());
        
        
        
    }
}