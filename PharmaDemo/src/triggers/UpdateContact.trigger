trigger UpdateContact on Call_Attendees__c (after insert, after update) 
{
List<Contact> ContactsToUpdate = new List<Contact>();
for (Call_Attendees__c ca: Trigger.new)
{
Contact c = new Contact(Id=ca.Contact__c);

c.Next_Call_Objective__c = ca.Next_Call_Objective__c;
c.Call_Notes__c = ca.Call_Notes__c;

ContactsToUpdate.add(c);
}
update ContactsToUpdate ;
}