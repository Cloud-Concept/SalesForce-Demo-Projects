/*
* Developed by Timba Software Corp. www.timbasoftware.com admin@timbasoftware.com
*/

/**
* Test Class to cover code from AccountEditController 
* @author Guillermo Lacordelle
*/ 
@isTest private class ApprovalsUtilTest
{
	public static testMethod void run()
	{
		ApprovalsUtil.isTest = true;
		Map<String, String> params = ApexPages.currentPage().getHeaders();
		
		params.put('User-Agent', 'iPhone');
		ApprovalsUtil.getBrowserName();
		
		params.put('User-Agent', 'Salesforce');
		ApprovalsUtil.getBrowserName();
		
		params.put('User-Agent', 'BlackBerry');
		ApprovalsUtil.getBrowserName();
		
		params.put('User-Agent', 'other');
		ApprovalsUtil.getBrowserName();
		
		ApprovalsUtil.getDomain();
		
		ApprovalsUtil.strValue('hello');
		ApprovalsUtil.strValue(null);
		
		System.currentPageReference().getHeaders().put('Referer','http://www.google.com');
		boolean b = ApprovalsUtil.isCSRF(ApexPages.currentPage());
		
		try
		{
			ApprovalsUtil.doGetRequest('https://login.salesforce.com', null);
		}
		catch (Exception e)
		{
			System.debug(e.getMessage());
		}
		
		try
		{
			ApprovalsUtil.doGetRequest('https://login.salesforce.com', 'some_cookie_value=true;');
		}
		catch (Exception e)
		{
			System.debug(e.getMessage());
		}
		
		
		ApprovalsUtil.encode('String to encode');
		
		System.assert(ApprovalsUtil.getMatch('Hello world', 'w(.*)d', 1) == 'orl');
		
		System.assert(ApprovalsUtil.boundLower('This is a string', 'is') == ' is a string');
		
		System.assert(ApprovalsUtil.boundUpper('This is a string', 'a') == 'This is ');
		
		System.assert(ApprovalsUtil.bound('This is a string', 'a', 'ing') == ' str');
	}
}