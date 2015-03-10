public interface SocialMentionResponse {
	
	List<SocialMentionController.MentionResults> getResponses(String responseString);
	
}