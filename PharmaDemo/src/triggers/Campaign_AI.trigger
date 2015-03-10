trigger Campaign_AI on Campaign (after insert) {
    
    // Get Event Record Type    
    Id eventRecordTypeId = [Select Id from RecordType where SobjectType = 'Event' and DeveloperName = 'Campaign'][0].Id;
    
    //List for events that shall be inserted
    List<Event> list_events = new List<Event>();
    //Map for storing submitted times
    List<campaign> list_submitted = new List<campaign>();

    for (Campaign c: trigger.new){
    
            Event nEvent = new Event();
            nEvent.Subject=c.Name;
            nEvent.Type = 'Campaign';
            nEvent.OwnerId = c.OwnerId;
            nEvent.IsAllDayEvent = true;
            nEvent.ShowAs='OutOfOffice';
            nEvent.Related_Id__c = c.Id;
            nEvent.RecordTypeId = eventRecordTypeId;
            nEvent.Description = c.Status;
            nEvent.StartDateTime = DateTime.newInstanceGmt(c.StartDate.year(),c.StartDate.month(),c.StartDate.day());
            nEvent.EndDateTime = DateTime.newInstanceGmt(c.EndDate.year(),c.EndDate.month(),c.EndDate.day());
            
            //t.addError('Start Date: ' + nEvent.StartDateTime);
            
            //All informations for event stored om list
            list_events.add(nEvent);
        }
    if (list_events != null)
        insert list_events;
  
}