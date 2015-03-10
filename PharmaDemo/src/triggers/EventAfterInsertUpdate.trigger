trigger EventAfterInsertUpdate on Event (after insert) {
    if ( ! Utilities.getAlreadyUpdatingEvents() ) {
        Utilities.setAlreadyUpdatingEvents(true);
        Map<Id, RecordType> recordTypeNames = new Map<Id, RecordType>([Select Id, Name from RecordType Where SObjectType = 'Event']);
        List<Id> contactIds = new List<Id>();
        for (Event e : Trigger.new) {
            contactIds.add(e.WhoId);    
        }
        Map<Id, Contact> contactAccounts = new Map<Id, Contact>([Select Id, AccountId, Account.Brick__c From Contact Where Id in :contactIds]);
        List<Id> eventIds = new List<Id>();
        List<Call_Report__c> groupMeetingsToUpdate = new List<Call_Report__c>();
        for (Event event: Trigger.new) {
            RecordType recordType = recordTypeNames.get(event.RecordTypeId);
            if (recordType != null) {
                if (recordType.Name == 'Appointment') {
                    if (event.Subject == 'Appointment') {
                        eventIds.add(event.Id);
                        Call_report__c groupMeeting = new Call_Report__c();
                        groupMeeting.Name = event.Subject + ': ' + event.Location;
                        groupMeeting.Date__c = event.ActivityDateTime;             
                        groupMeeting.Duration__c = String.valueOf(event.DurationInMinutes);
                        Contact c = contactAccounts.get(event.WhoId);                        
                        if (c != null) {
                            groupMeeting.Location__c = c.AccountId;
                            groupMeeting.Brick__c = c.Account.Brick__c;
                        }
                        groupMeeting.Contact__c = event.WhoId;
                        groupMeeting.SummaryId__c = event.Id;
                        groupMeeting.Type__c = event.Subject;
                        groupMeeting.User__c = event.ownerId;
                        groupMeeting.OwnerId = event.ownerId;
                        groupMeetingsToUpdate.add(groupMeeting);
                    }
                }
            }
        }
        // upsert the group meeting
        Database.UpsertResult[] groupMeetingResults = Database.upsert(groupMeetingsToUpdate, Call_Report__c.SummaryId__c, false);
        List<Id> groupMeetingIds = new List<Id>();
        for (Database.UpsertResult result : groupMeetingResults) {
            if ( result.isSuccess() ) {
                groupMeetingIds.add(result.getId());            
            }   
        }
        List<Call_Report__c> groupMeetings = [Select Id, Name, SummaryId__c From Call_Report__c Where Id In :groupMeetingIds];
        List<Event> eventsToUpdate = new List<Event>();
        Map<Id, Id> eventGroupMeetingMap = new Map<Id, Id>();
        for (Event event : Trigger.new) {
            for (Call_Report__c groupMeeting : groupMeetings) {
                if (event.Id == groupMeeting.SummaryId__c) {
                    Event eventToUpdate = new Event(id=event.Id);
                    eventToUpdate.Related_Id__c = groupMeeting.Id; 
//                    eventToUpdate.Group_Meeting_Name = groupMeeting.Name;
                    eventsToUpdate.add(eventToUpdate);
                    eventGroupMeetingMap.put(event.Id, groupMeeting.Id);
                }                       
            }
        }
        Database.SaveResult[] eventResults = Database.update(eventsToUpdate, false);
        // code below creates group meeting attendees from event attendees - not required at present
        /*
        List<Group_Meeting_Attendee__c> groupMeetingAttendees = new List<Group_Meeting_Attendee__c>();
        List<EventAttendee> qryEventAttendees = [Select Id, AttendeeId, EventId From EventAttendee Where EventId In :Trigger.new];
        List<EventAttendee> eventAttendees = new List<EventAttendee>();
        List<Id> contactIds = new List<Id>();
        for (EventAttendee eventAttendee : qryEventAttendees) {
            String attendeeId = String.valueOf(eventAttendee.AttendeeId);
            if (attendeeId.substring(0,3) == '003') {
                contactIds.add(eventAttendee.AttendeeId);
                eventAttendees.add(eventAttendee);
            }
        }
        Map<Id, Contact> contacts = new Map<Id, Contact>([Select Id, Name from Contact Where Id In :contactIds]);
        for (EventAttendee eventAttendee : EventAttendees) {
            Group_Meeting_Attendee__c groupMeetingAttendee = new Group_Meeting_Attendee__c();
            Contact contact = contacts.get(eventAttendee.AttendeeId);
            groupMeetingAttendee.Name = contact.Name;
            groupMeetingAttendee.Contact__c = eventAttendee.AttendeeId;
            groupMeetingAttendee.Group_Meeting__c = eventGroupMeetingMap.get(eventAttendee.EventId);
            groupMeetingAttendees.add(groupMeetingAttendee);        
        }
        Database.SaveResult[] groupMeetingAttendeesResults = Database.insert(groupMeetingAttendees, false);
        */ 
    }
}