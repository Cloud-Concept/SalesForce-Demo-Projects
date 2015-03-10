/**
	Parses the JSON feed from the Social Mention (social media aggregator) RESTful web service.
	The JSON feed structure is as follows:
	
{"title":"Social Mention","count":141,"items": 
	[{"title":"Salesforce.com 1Q profit down, outlook disappoints (AP)http:\/\/bit.ly\/beS4GH","description":"",
	  "link":"http:\/\/twitter.com\/feed_USNews\/statuses\/14404644549",
	  "timestamp":1274413432,
	  "image":null,
	  "embed":null,
	  "language":"en",
	  "user":"feed_USNews",
	  "user_image":"http:\/\/s.twimg.com\/a\/1273536095\/images\/default_profile_6_normal.png",
	  "user_link":"http:\/\/twitter.com\/feed_USNews","
	  user_id":11166019,
	  "source":"twitter",
	  "favicon":"http:\/\/twitter.com\/favicon.ico",
	  "type":"microblogs",
	  "domain":"twitter.com",
	  "id":"3562734405601768428"}
	  ,
	  {"title":"Microsoft sues Salesforce.com, alleging patent infringement http:\/\/tinyurl.com\/2fsyd85",
	  "description":"",
	  "link":"http:\/\/twitter.com\/LoTempio\/statuses\/14404279535",
	  "timestamp":1274412997,
	  "image":null,"embed":null,"language":"en",
	  "user":"LoTempio",
	  "user_image":"http:\/\/a1.twimg.com\/profile_images\/589763432\/091222_49_normal.jpg",
	  "user_link":"http:\/\/twitter.com\/LoTempio",
	  "user_id":70283070,
	  "source":"twitter",
	  "favicon":"http:\/\/twitter.com\/favicon.ico",
	  "type":"microblogs",
	  "domain":"twitter.com",
	  "id":"13068326133924236802"}	  	  
	 ]}	
**/

public class SocialMentionJsonResponse implements SocialMentionResponse {

	public List<SocialMentionController.MentionResults> getResponses(String responseString) {
		List<SocialMentionController.MentionResults> results = null;
		responseString = responseString.replace('\\', '');
		
		
		//TODO: This has not been implemented since the JSON parsing utility (Ron Hess') blows up due to gov'ner limits. Use the XML parser
		
		return results;
	}
	
	
	
	static testMethod void testSingleResponse() {
		SocialMentionResponse processor = new SocialMentionJsonResponse();
		List<SocialMentionController.MentionResults> results;
		
		results = processor.getResponses('');
		
		System.assert(results == null); 
		
		
	}		
}