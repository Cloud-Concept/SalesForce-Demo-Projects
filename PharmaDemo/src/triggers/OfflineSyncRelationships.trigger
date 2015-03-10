trigger OfflineSyncRelationships on OpportunityLineItem (before insert) {

/**
This trigger helps out the offline client when saving Opportunities and Opportunity lineitems.
The offline client doesn't generate Id's for the saved records which gives problems when syncing
We solve this by keeping separate 'offline id's'. Those are used by this trigger to create the correct parent/child relationship
**/


	Set<String> oppsofflineIds = new Set<String>();
	Map<String, Opportunity> opportunities = new Map<String, Opportunity>();
	List<OpportunityLineItem> lineitems = new List<OpportunityLineItem>();

	for(OpportunityLineItem ol:Trigger.new) {
		//only treat the lineitems that come in without an opportunityId (from the offline client)
		if(ol.OpportunityId != null) continue;
		//we can't do anything with those that have no OpportunityOfflineId, ignore those as well
		if(ol.OpportunityOfflineId__c == null) continue;

		oppsofflineIds.add(ol.OpportunityOfflineId__c);		
	}
	
	System.debug('OFFLINEIDS : ' + oppsofflineIds);
	
	//now that we know which lineitems need to be linked, find the corresponding opportunities via the OfflineId
	List<Opportunity> opps = [select Id, OfflineId__c from Opportunity where OfflineId__c in:oppsofflineIds ];
	
	System.debug('OPPORTUNITIES : ' + opps);
	
	//drop those in the Map for lookup
	for(Opportunity o:opps) {
		opportunities.put(o.OfflineId__c, o);
	}
	
	
	System.debug('OPPORTUNITIES :' + opportunities);
	
	for(OpportunityLineItem ol:Trigger.new) {
		//only treat the lineitems that come in without an opportunityId (from the offline client)
		if(ol.OpportunityId != null) continue;
		//we can't do anything with those that have no OpportunityOfflineId, ignore those as well
		if(ol.OpportunityOfflineId__c == null) continue;
		//get the corresponding opportunity
		Opportunity o = opportunities.get(ol.OpportunityOfflineId__c);
		ol.OpportunityId = o.Id;		
	}

}