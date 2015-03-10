@isTest
private class TestAppLauncher {
	
	public static testmethod void testAppL() {
		
		AppLauncher__c al1 = new AppLauncher__c();
		al1.Category__c = 'HR';
		al1.Name = 'app1';
		
		insert al1;
		
		ApexPages.Standardsetcontroller con = new ApexPages.Standardsetcontroller([select Id, Name from AppLauncher__c limit 20]);
		AppLauncherSetExtension ase = new AppLauncherSetExtension(con);
		
		System.assertNotEquals(ase.getApps(), null);
		
	}
	
}