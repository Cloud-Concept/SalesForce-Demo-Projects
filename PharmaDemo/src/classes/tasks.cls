global class tasks implements Messaging.InboundEmailHandler {

global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){

// Create an inboundEmailResult object for returning the result of the Apex Email Service
Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

String myPlainText = '';

// Add the email plain text into the local variable

try
{
        myPlainText = email.plainTextBody.substring(0, email.plainTextBody.indexOf('<stop>'));
}
catch (System.StringException e)
{
        myPlainText = email.plainTextBody;
        System.debug('No <stop> in email: ' + e);
}

// new Task object to be created

Task[] newTask = new Task[0];

// Try to lookup any contacts based on the email from address
// If there is more than 1 contact with the same email address
// an exception will be thrown and the catch statement will be called

// Add a new Task to the contact record we just found above
newTask.add(new Task(Description = myPlainText,
                       Priority = 'Normal',
                       Status = 'Inbound Email',
                       Subject = email.subject,
                       IsReminderSet = true,
                       ReminderDateTime = System.now()+1,
                       WhoId = '0032000000bPgn7'));

// Insert the new Task and it will be created and appended to the contact record
insert newTask;


// Set the result to true, no need to send an email back to the user
// with an error message

result.success = true;

// Return the result for the Apex Email Service
return result;
        }
}