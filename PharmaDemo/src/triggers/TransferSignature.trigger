trigger TransferSignature on Attachment (before insert) {   


    Attachment CallSumSign = Trigger.new[0];


    if (CallSumSign.name.contains('Salesforce_sig')) {


        list<Call_Report__c> CallReportList = [
        Select c.SummaryId__c, c.Id 
        From Call_Report__c c 
        where  c.SummaryId__c = : CallSumSign.ParentId];
        
        // There is already a Call_Report__c for the underlying Call_Summary_sigcap_WM__c
        if(CallReportList.size () > 0) {
            /*                      
            Call_Report__c cr = CallReportList.get(0);
            Attachment CallReportSign = new Attachment ();      
            CallReportSign.ParentId = cr.Id;
            CallReportSign.Name = CallSumSign.name;
            CallReportSign.ContentType = CallSumSign.ContentType;
            CallReportSign.Body = CallSumSign.Body;
            
            */
            
            
            Call_Report__c cr = CallReportList.get(0);
            Attachment CallReportSign = CallSumSign.clone();
            CallReportSign.ParentId = cr.Id; 
            
            
                       
            insert  CallReportSign; 
            
       }
    }
}