@isTest
public class SWOTExtensionTest
{
    static testMethod void testSWOTwithData()
    {
        Account testAccount = [Select Id From Account Where Id = '0013000000om1yA'];
        
        ApexPages.StandardController sc = new ApexPages.standardController(testAccount);
        SWOTExtension page = new SWOTExtension(sc);        
    }
    
    static testMethod void testSWOTwithoutData()
    {
        Account testAccount = [Select Id From Account Limit 1];
        
        ApexPages.StandardController sc = new ApexPages.standardController(testAccount);
        SWOTExtension page = new SWOTExtension(sc);        
    }
}