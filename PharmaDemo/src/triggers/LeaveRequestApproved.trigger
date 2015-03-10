trigger LeaveRequestApproved on Leave_Request__c (after update) {
    //do not react to bulk uploads
    if(trigger.New.size() > 1) return;
    
    try {
        Leave_Request__c lr = Trigger.New[0];
        //only when freshly moved to an 'Approved' status
        if((Trigger.Old[0].Approval_Status__c != 'Approved') && (Trigger.New[0].Approval_Status__c == 'Approved')) {
            //Post to the user's feed
            User u = [select Id, FirstName, LastName from User where id=:lr.OwnerId];            
            FeedItem post = new FeedItem();
            post.ParentId = lr.OwnerId;
            String body = u.FirstName + ' ' + u.LastName + ' will be on ' + lr.Leave_Type__c + ' from ' + lr.From__c.format() + ' to ' + lr.To__c.format();
            post.Body = body;
            insert post;
            
            //Put the Leave in the user's agenda
            /** **/
            List<Event> events = new List<Event>();
            
            Date currentday = lr.From__c;
            
            for(integer i =0; i <= lr.From__c.daysBetween(lr.To__c); i++) {
                Event ev = new Event();
                ev.OwnerId = lr.OwnerId;
                ev.Subject = lr.Leave_Type__c;
                Date tempdate = currentday.addDays(i);
                ev.ActivityDateTime = tempdate;
                ev.StartDateTime = tempdate;
                ev.isAllDayEvent = true;
                events.add(ev);
            }
            insert events;
            
        }
    }
    catch(Exception ex) {
        //do nothing
        System.debug('Error in ApproveLeaveRequest Trigger : ' + ex.getMessage());
    }
}