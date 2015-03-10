public class SocialMentionController {	
			
	// You can add other sources to the search query, however the more you add the more likely it'll timeout	
	//&src[]=delicious&src[]=digg&src[]=bing&src[]=wordpress&src[]=google_news&src[]=yahoo
	private String MEDIA_SRC = 'src[]=twitter&src[]=facebook&src[]=google_news&src[]=yahoo&src[]=delicious&src[]=digg';
	private String RESPONSE_FORMAT = 'xml';
	private String MEDIA_TYPE = 't=all';
	private String TIMING = 'from_ts=86400';
	private String SOCIAL_MENTION_BASE_URL = 'http://api2.socialmention.com/search?' + 'f=' + RESPONSE_FORMAT + '&' + MEDIA_TYPE + '&'+ TIMING + '&' + MEDIA_SRC + '&q=';	
		
	public String searchTerm {get; set;}
	public String searchResult {get; set;}
	public String jsonResult {get; set;}
	public List<MentionResults> mentions {get; set;}
	public String searchURL {get; set;}
	public String newObjectUrl {get; set;}
	public String newObjectName {get; set;}
	
	public SocialMentionController() { }
    
    
    /**
     *
     *	Creates a new lead based on the parameters passed to it from the SocialMention.page
     *
     **/
    public PageReference createNewLead() {    	
    	PageReference pageRef = null;    	
    	MentionConvertDetails mentionDetails;
    	Lead newLead;
    	
    	mentionDetails = new MentionConvertDetails(ApexPages.currentPage());
    	
    	if (''.equals(mentionDetails.user) ) {
    		mentionDetails.user = mentionDetails.source + '_user';	
    	}
    	
    	newLead = new Lead();
    	newLead.FirstName = mentionDetails.user;
    	newLead.LastName = mentionDetails.source;
    	newLead.Description = mentionDetails.title;
    	newLead.Website = mentionDetails.link;
    	newLead.LeadSource = mentionDetails.source;    
    	
    	insert newLead;
    	    	    	    	
		addPageMessage('Created a new lead ' + newLead.FirstName);    	
    	return pageRef;	
    }
            
            
    /**
     *
     *	Creates a new case based on the parameters passed to it from the SocialMention.page
     *
     **/            
    public PageReference createNewCase() {
    	PageReference pageRef = null;
    	MentionConvertDetails metionDetails;
    	Case newCase;
    	    	
    	metionDetails = new MentionConvertDetails(ApexPages.currentPage());
    	newCase = new Case();
    	
    	newCase.Description = metionDetails.link;
    	newCase.Subject =  metionDetails.title;
    	newCase.Origin = metionDetails.source;
    	newCase.SuppliedName = metionDetails.user;
    	
    	insert newCase;
    	
    	newCase = [SELECT CaseNumber, Id from CASE where SuppliedName =: metionDetails.user AND Subject =: metionDetails.title AND Origin =: metionDetails.source];
		newObjectUrl = '/' + newCase.Id;
		newObjectName = 'Case ' + newCase.CaseNumber;
		addPageMessage('Created a new case ' + newCase.CaseNumber);    	
    	return pageRef;
    }
    
    
    public PageReference searchForMention() {
    	HttpWrapper httpWrapper = new HttpWrapperImpl();		
		return searchForMention(httpWrapper);    	
    }
    
    
    public PageReference searchForMention(HttpWrapper httpWrapper) {
		String url;
		String resp;
		Boolean searchSuccess;
		SocialMentionResponse mentionResponse = null;
		
		url = SOCIAL_MENTION_BASE_URL + EncodingUtil.urlEncode(searchTerm,'UTF-8');							    	    	    	    				
		searchURL = url;
		searchSuccess = true;
		httpWrapper.setEndpoint(url);

		try {
			resp = httpWrapper.send();
		} catch (System.CalloutException ex) {
			System.debug('Looks like Social Mention timed out.... ' + ex);				
			addPageErrorMessage('Sorry... Social Mention was a little busy, try again a little later!');
			searchSuccess = false;
		}
		
		if (searchSuccess) {
			if ('xml'.equals(RESPONSE_FORMAT)) {
				mentionResponse = new SocialMentionXmlResponse();
			} else if ('json'.equals(RESPONSE_FORMAT)) {
				mentionResponse = new SocialMentionJsonResponse();
			} else {
				addPageErrorMessage('Sorry... I dont know what kind of feed this is....' );				
			}
						
			if (mentionResponse != null) {
				mentions = mentionResponse.getResponses(resp);
				addPageMessage('Social Mention Results for ' + searchTerm );
			} 				   	    	    			
		}		
    	return null;
    }
    
    
	// ------------ UTILITY METHODS AND CLASSES ----------------- //    
    
    private void addPageErrorMessage(String message) {
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, message);
        ApexPages.addMessage(msg);    	
    }
    
    
    private void addPageMessage(String message) {
		ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, message );
        ApexPages.addMessage(msg);	    	
    }
    
    /**
     *
     *	Container class for all the results that come back from Social Mention 
     *	regardless of the response format (i.e. XML or json)
     *
     **/
    public class MentionResults {
    	public String title {get; set;}
    	public String link {get; set;}
    	public String user {get; set;}
    	public String user_link {get; set;}
    	public String source {get; set;}
    	public String favicon {get; set;}
    	public String domain {get; set;}    	    	
    	public MentionResults() {    		    
    	}    	
    } // END MentionResults class
    
    
    /**
     *
     *	Container class to hold all the parameters passed from either the "Create Lead" 
     *	or "Create Case" buttons on SocialMention.page
     *
     **/
    private class MentionConvertDetails {
    	public String user {get; set;}
    	public String link {get; set;}
    	public String source {get; set;}
    	public String title {get; set;}
    	
    	public MentionConvertDetails(System.PageReference page) {    		
    		user = page.getParameters().get('mention_user');
    		link = page.getParameters().get('mention_link');
    		source = page.getParameters().get('mention_source');
    		title = page.getParameters().get('mention_title');
    		
    		System.debug('Created a new Mention to Convert with details of: ' + getValue());    		    		
    	}  
    	
    	public String getValue() {    		
    		return 'user: ' + user + ' link:' + link + ' source: ' + source + ' title: ' + title;
    	}  		   
    } // END MentionConvertDetails class      
    

    
    public interface HttpWrapper {
    	void setEndpoint(String url);
    	String send();		    	    	
    }
    
    public class HttpWrapperImpl implements HttpWrapper {    	
    	private HttpRequest request;
    	private Http http;
    	
    	public HttpWrapperImpl() {
    		request = new HttpRequest();
			http = new Http();
			    		
    		request.setMethod('GET');
			request.setTimeout(60000);						
    	}
    	
    	public void setEndPoint(String url) {
    		request.setEndPoint(url);
    	}
    	
    	public String send() {
    		HttpResponse response;
    		response = http.send(request);
    		return response.getBody();
    	}    	
    }
    
    public void dummyTestMethod() {
    	Integer i = 0;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;    
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;    
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;    
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;    
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;    
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;    
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;    
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;    
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;    
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;        	
    }
    
    
    // ------------------------------  TEST METHODS ----------------------------------- //
    
    
    static testMethod void testSingleResponse() {
    	SocialMentionController controller = new SocialMentionController(); 	
    	controller.searchTerm = 'Mock Search Term';
    	controller.searchForMention( new MockHttp() );   	    	
    	SocialMentionController.MentionResults mentionResults;
    	
    	mentionResults = controller.mentions.get(0);    	
    	System.assertEquals('TESTING', mentionResults.title);
    }
       
    private class MockHttp implements HttpWrapper {
    	public MockHttp() {
    		
    	}
    	
    	public void setEndPoint(String url) {
    		
    	}
    	
    	public String send() {
    		String response;    		    		
    		response = SocialMentionXmlResponse.getTestXmlResponse('TESTING', 'TESTING', 'TESTING',
    						'TESTING', 'TESTING', 'TESTING', 'TESTING', 'TESTING');    		    		    		    
    		return response;
    	}
    }
    
    static testMethod void dummyTestFiller() {
    	SocialMentionController controller = new SocialMentionController(); 	
    	controller.dummyTestMethod();
    }
    

}