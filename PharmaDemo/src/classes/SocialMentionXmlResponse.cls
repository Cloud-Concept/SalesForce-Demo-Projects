/**
	Parses the XML feed from the Social Mention (social media aggregator) RESTful web service.
	The XML feed structure is as follows:				
	
<root> 
  <title>Social Mention</title> 
  <count>148</count> 
  <items> 		
    <item> <-- this is where we should be at right now.....
      <title>Lee Poh Wah (lien F), Nadhira (PPIS) and Laurance Wee (PCS) shared great ideas on how the salesforce.com can be customized for their needs</title> 
      <description></description> 
      <link>http://twitter.com/salesforceapac/statuses/14601530303</link> 
      <timestamp>1274674723</timestamp> 
      <image></image> 
      <embed></embed> 
      <language>en</language> 
      <user>salesforceapac</user> 
      <user_image>http://a3.twimg.com/profile_images/909528347/cloudtopia_logo_white_v5_normal.png</user_image> 
      <user_link>http://twitter.com/salesforceapac</user_link> 
      <user_id>22261177</user_id> 
      <source>twitter</source> 
      <favicon>http://twitter.com/favicon.ico</favicon> 
      <type>microblogs</type> 
      <domain>twitter.com</domain> 
      <id>9276110332013330622</id> 
    </item>
    ... etc etc etc...
     		
**/


public class SocialMentionXmlResponse implements SocialMentionResponse {
	
	private static String NO_TITLE_FOUND = 'no title found';

	public List<SocialMentionController.MentionResults> getResponses(String responseString) {
		List<SocialMentionController.MentionResults> results = new List<SocialMentionController.MentionResults>{};		
		XmlStreamReader reader = new XmlStreamReader(responseString);				
							
		while(reader.hasNext()) {
         	if ( (reader.getEventType() == XmlTag.START_ELEMENT) && ('item'.equalsIgnoreCase(reader.getLocalName()))) {
         		
         		SocialMentionController.MentionResults curResponse = parseResponse(reader);         		
         		if (!NO_TITLE_FOUND.equals(curResponse.title)) {
         			results.add(curResponse);	
         		} 				
         	}			
         	reader.next();
		}
		return results;
	}		
	
	
	private SocialMentionController.MentionResults parseResponse(XmlStreamReader reader) {
		SocialMentionController.MentionResults curResult = new SocialMentionController.MentionResults();
		curResult.title = NO_TITLE_FOUND;	
		Boolean emptyTitle = false;	
														
		reader.next();
		while( (!('item'.equalsIgnoreCase(reader.getLocalName()))) ) {						
			if ( reader.getEventType() == XmlTag.START_ELEMENT ) {				
				if ('title'.equalsIgnoreCase(reader.getLocalName())) {					
					reader.next();
					if ( reader.getEventType() == XmlTag.CHARACTERS ) {
						curResult.title = reader.getText();
						emptyTitle = false;						
					} else {
						curResult.title = NO_TITLE_FOUND;
						emptyTitle = true;
					}								
				} else if ('description'.equalsIgnoreCase(reader.getLocalName()) && emptyTitle) {
					reader.next();
					if ( reader.getEventType() == XmlTag.CHARACTERS ) {
						curResult.title = reader.getText();	
					}										
					emptyTitle = false;
				} else if ('favicon'.equalsIgnoreCase(reader.getLocalName()) ) {
					reader.next();
					System.debug('Found a fav icon with a value of: ' + reader.getText());
					curResult.favicon = reader.getText();										
				} else if ('link'.equalsIgnoreCase(reader.getLocalName()) ) {
					reader.next();
					curResult.link = reader.getText();
				} else if ('user'.equalsIgnoreCase(reader.getLocalName()) ) {
					reader.next();
					if ( reader.getEventType() == XmlTag.CHARACTERS ) {						
						curResult.user = reader.getText();						
					}
				} else if ('source'.equalsIgnoreCase(reader.getLocalName()) ) {
					reader.next();
					curResult.source = reader.getText();				
				} else if ('user_image'.equalsIgnoreCase(reader.getLocalName()) ) {
					reader.next();
					if ( reader.getEventType() == XmlTag.CHARACTERS) {
						curResult.user_link = reader.getText();	
					}										
				} else if ('domain'.equalsIgnoreCase(reader.getLocalName()) ) {
					reader.next();
					curResult.domain = reader.getText();
				}						
			}
			reader.next(); 	
		}	// END OF WHILE LOOP
		
		if ( (curResult.user == null || ''.equals(curResult.user)) || (curResult.user_link == null || ''.equals(curResult.user_link))) {
			curResult.user_link = curResult.favicon;
		}
		
		if ( curResult.user == null || ''.equals(curResult.user) ) {
			curResult.user = curResult.source;			
		}
		return curResult;
	}
	
	
	// ------------------  TEST METHODS --------------------- //
	
    static testMethod void testSingleResponse() {
    	String title = 'Test Title';
    	String description = 'Test Description';
    	String favicon = 'Test Icon';
    	String link = 'Test Link';
    	String user  = 'Test User'; 
    	String source  = 'Test Source';
    	String user_image  = 'Test User Image';
    	String domain   = 'Test Domain';
    	SocialMentionResponse xmlResponse;
    	SocialMentionController.MentionResults result;
    	
    	xmlResponse = new SocialMentionXmlResponse();
    	
    	List<SocialMentionController.MentionResults> results = xmlResponse.getResponses(
    			getTestXmlResponse(title, description, favicon, link, user, source, user_image, domain)
    		);


		System.assert(results.size() == 1, 'The results should have returned a single record but returned ' + results.size());
		result = results.get(0);
		System.assertEquals(result.title, title);
		System.assertEquals(result.favicon, favicon);
		System.assertEquals(result.link, link);
		System.assertEquals(result.user, user);
		System.assertEquals(result.source, source);
		System.assertEquals(result.user_link, user_image);
		System.assertEquals(result.domain, domain);		    	
       
    }
    
    
    public static String getTestXmlResponse( String title, String description,	String favicon,
    						String link, String user, String source, String user_image, String domain) {
    	String xmlResponse = '';    	
  		xmlResponse = 	'<root><title>Social Mention</title><count>1</count><items>' + 		
						getItemContent(title, description, favicon, link, user, source, user_image, domain) +
					    '</items></root>';    		    	
    	return xmlResponse;
    } 	
    
    public static String getItemContent(String title, String description,	String favicon,
    						String link, String user, String source, String user_image, String domain) {
    	String itemXml;	
    
    	itemXml = '<item>' + 
				      '<title>'+ title + '</title>' + 
				      '<description>' + description + '</description> ' +
				      '<link>'+ link + '</link>' + 
				      '<timestamp>1274674723</timestamp> ' +
				      '<image></image> ' +
				      '<embed></embed> ' +
				      '<language>en</language>' + 
				      '<user>'+ user + '</user>' + 
				      '<user_image>'+ user_image + '</user_image>' + 
				      '<user_link>'+ link + '</user_link>' + 
				      '<user_id>22261177</user_id>' + 
				      '<source>'+ source + '</source>' + 
				      '<favicon>'+ favicon + '</favicon>' + 
				      '<type>microblogs</type>' + 
				      '<domain>'+ domain + '</domain>' + 
				      '<id>9276110332013330622</id>' + 
				   '</item>';
    
    	return itemXml;
    }
	
	
}