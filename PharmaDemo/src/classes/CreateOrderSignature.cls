global class CreateOrderSignature implements Messaging.InboundEmailHandler
{
    global Messaging.InboundEmailResult handleInboundEmail (Messaging.inboundEmail email, Messaging.inboundEnvelope env)
    {
        // Create an inboundEmailResult object for returning the result of the Apex Email Service
        Messaging.inboundEmailResult result = new Messaging.inboundEmailResult ();
        
        // Order to associate
        Stock_Order__c Order;
        
        // New Case object to be created
        Case newCase;
        
        // Try to lookup any contacts based on the email from address
        // If there is more than 1 contact with the same email address,
        // it uses the first one.
        try
        {
            Order = [select Id, Name, Your_Reference__c from Stock_order__c where Your_Reference__c = :email.subject limit 1];
        }
        catch (QueryException e)  // No Contact with that email address, so create one
        {      
            System.debug ('New Contact: ');
        }
                            
        System.debug ('New Case Object: ' + newCase);
        
        // Create any attachments (text or binary)
        List <Attachment> attachments = new List <Attachment> ();
        
        if (email.binaryAttachments != null)
        {
            for (Messaging.InboundEmail.BinaryAttachment emailAttachment : email.binaryAttachments)
            {
                Attachment attach = new Attachment();
                attach.parentId   = order.id;
                attach.body       = emailAttachment.body;
                attach.name       = emailAttachment.fileName; 
                attach.description = 'Order Signature';                
                attachments.add (attach);
            }
        }
        
        if (email.textAttachments != null)
        {
            for (Messaging.InboundEmail.TextAttachment emailAttachment : email.textAttachments)
            {
                Attachment attach = new Attachment();
                attach.parentId   = Order.id;
                attach.body       = blob.valueOf (emailAttachment.body);
                attach.name       = emailAttachment.fileName; 
                attach.description = 'Order Signature';
                attachments.add (attach);
            }
        }
        
        // insert the attachments
        if (attachments.size () > 0)
        {
            try
            {
                insert attachments;
            }
            catch (DMLException e)
            {
                System.debug ('DML error with attachments' + e);
                result.success = false;
                return result;
            }    
        }

        //
        // The case has been created now, so it is time to
        // send a "This is your case number" email.
        //
        Organization Org = [select Name from Organization]; 
        
        Messaging.SingleEmailMessage responseMail = new Messaging.SingleEmailMessage ();

        // Assign the "To" address
        responseMail.setToAddresses (new String [] {email.fromAddress});  // convert a single string into a string array

        // Specify the address used when the recipients reply to the email.
        // responseMail.setReplyTo ('support@acme.com');

        // Specify the name used as the display name.
        responseMail.setSenderDisplayName (Org.Name + ' - Document Attachment Service');

        // Specify the subject line for your email address.
        responseMail.setSubject ('New Signature Attachment Created');

        // Set to True if you want to BCC yourself on the email.
        responseMail.setBccSender (false);

        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        responseMail.setUseSignature (false);

// Specify the text content of the email.
        responseMail.setPlainTextBody ('New Signature stored against ' + Order.Name);



        // Send the email you have created by creating a single entry list for the sendEmail method
        Messaging.sendEmail (new Messaging.SingleEmailMessage [] {responseMail});
        
        // 
        // Set the result to true for the original inbound email and ...
        result.success = true;
        
        // ... return the result for the Apex Email Service
        return result;
    }
}