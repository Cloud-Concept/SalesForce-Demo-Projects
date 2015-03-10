@isTest
public with sharing class TestPurchases {


	//test purchaseextension
	private static testmethod void testpurchaseextension() {
		
		Purchase_Requisition__c pr = new Purchase_Requisition__c();
		pr.Approval_Status__c = 'Pending';
		pr.Comments__c = 'comments';
		pr.Cost_Center__c = 'z01';
		pr.Cost_Center_Code__c = 'z01';
		pr.Ending_Date__c = Date.today().addDays(10);
		pr.Starting_Date__c = Date.today();
		
		insert pr;
		
		ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(pr);
		PurchaseExtension pe = new PurchaseExtension(con);
		pe.getFormattedEnd();
		pe.getFormattedStart();
		pe.cancel();
		pe.save();
		
		Purchase_Requisition__c pr2 = new Purchase_Requisition__c();
		pr2.Approval_Status__c = 'Pending';
		pr2.Comments__c = 'comments';
		pr2.Cost_Center__c = 'z01';
		pr2.Cost_Center_Code__c = 'z01';
		pr2.Ending_Date__c = Date.today().addDays(10);
		pr2.Starting_Date__c = Date.today();

		
		ApexPages.Standardcontroller con2 = new ApexPages.Standardcontroller(pr2);
		PurchaseExtension pe2 = new PurchaseExtension(con2);		
		pe2.cancel();
		pe2.save();
		pe2.sendToSAP();
		
	}
	
	
	//test purchasesetcontroller
	private static testmethod void testpurchasesetcontroller() {
		Purchase_Requisition__c pr = new Purchase_Requisition__c();
		pr.Approval_Status__c = 'Pending';
		pr.Comments__c = 'comments';
		pr.Cost_Center__c = 'z01';
		pr.Cost_Center_Code__c = 'z01';
		pr.Ending_Date__c = Date.today().addDays(10);
		pr.Starting_Date__c = Date.today();
		
		insert pr;
		
		ApexPages.Standardsetcontroller con = new ApexPages.Standardsetcontroller([select Id from Purchase_Requisition__c limit 20]);
		PurchaseSetController psc = new PurchaseSetController(con);
		psc.getPurchases();
		
	}

}