public with sharing class escalationTeamCont {
	
	public sObject target{get;set;}
	public string recId{get;set;}

	public escalationTeamCont(){
		recid = ApexPages.CurrentPage().getParameters().get('id');
		
		if(recid == null)
		{
			target = null;
		}
		else{
		target = database.query('select id from Opportunity where id = \'' + recid + '\'');
		}
	}
	
	public escalationTeamCont(string id){
		recId = id;
		if(recid == null)
		{
			target = null;
		}
		else{
		target = database.query('select id from Opportunity where id = \'' + recid + '\'');
		}
	}

	public static void notifyTeam(List<User> team, string TargetID)
	{
		//NEWS TEAM ASSEMBLE! (Sorry, had to.)
		//Utility method to quickly add any target onto a list of users' chatter feeds. Allows easy expansion
		//of project. User records in list MUST HAVE ID QUERIED OR THIS WILL FAIL. Would need refactoring for
		//larger teams (50+ users).
		
		List<EntitySubscription> followers = new List<EntitySubscription>();
		EntitySubscription NewFollower;
		List<EntitySubscription> existChecker;
		
		For(User u : team)
		{
			existChecker = [select parentID, subscriberID from EntitySubscription where parentID = :targetID and subscriberId = :u.Id];
			if(existChecker.size() == 0)//Check if user's already following.
			{
			newFollower = new EntitySubscription();
			newFollower.SubscriberId = u.id;
			newFollower.parentID = targetId;
			followers.add(newFollower); 
			}
		}
		if(followers.size() > 0)
			insert followers;
	}

	
	public pageReference salesTeamAssemble(){
		Opportunity opty = [select id from Opportunity where id = :(string)target.get('id')];
		
		List<UserTeamMember> defaultTeam = [select UserID, TeamMemberRole from UserTeamMember where ownerID = :UserInfo.getUserID()];
		string teamIDs = '';
		List<OpportunityTeamMember> oppyTeam = new List<OpportunityTeamMember>();
		OpportunityTeamMember newOTM;
		For(UserTeamMember utm : defaultTeam)		
		{
			teamIDs += utm.userId + '\',\'';
			
			
			newOTM = new OpportunityTeamMember();
			newOTM.OpportunityID = opty.id;
			newOTM.UserID = utm.userId;
			newOTM.TeamMemberRole = utm.TeamMemberRole;
			oppyTeam.add(newOTM); 
		}
		insert oppyTeam;
		teamIds = teamIDs.substring(0, teamIDs.length()-3);
		
		List<User> salesTeam = database.Query('select id from User where id in (\'' + teamIds + '\')');
		
		notifyTeam(salesTeam, opty.id);
		
		return new pageReference('/' + recID);
	}
	
}