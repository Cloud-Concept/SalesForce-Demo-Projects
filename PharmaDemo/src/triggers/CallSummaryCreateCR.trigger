trigger CallSummaryCreateCR on Call_Summary_sigcap_WM__c (after insert, after update) {
   
    Call_Summary_sigcap_WM__c cs = trigger.new[0];
    
    Call_Report__c cr = new Call_Report__c();
    
    Call_Attendees__c CA2 = new Call_Attendees__c ();
    Call_Attendees__c CA3 = new Call_Attendees__c ();
    
    Product_Detail__c PD1 = new Product_Detail__c();
    Product_Detail__c PD2 = new Product_Detail__c();
    Product_Detail__c PD3 = new Product_Detail__c();        

    Sample_Item__c SI1 = new Sample_Item__c(); 
    Sample_Item__c SI2 = new Sample_Item__c();
    Sample_Item__c SI3 = new Sample_Item__c();        
    

    Promotional_Item__c PI1 = new Promotional_Item__c(); 
    Promotional_Item__c PI2 = new Promotional_Item__c();
    Promotional_Item__c PI3 = new Promotional_Item__c();    

    if (cs.closed__c) { 
        cr.User__c = cs.OwnerId;
        cr.Date__c = cs.Date_Time__c;
        cr.Type__c = cs.Type__c;
        cr.Duration__c = cs.Duration__c;
        cr.Location__c = cs.Location__c;
        cr.Brick__c = cs.Brick__c;
        cr.Contact__c = cs.Contact_1__c;
        cr.Accompanied_Call__c = cs.Accompanied_Call__c;
        cr.Next_call_Objective__c = cs.Next_Call_Objective__c;
        cr.Call_Notes__c = cs.Call_Notes__c;
        cr.SummaryId__c = cs.Id;
        
        insert cr;
        
    //Second Attendee
    //Due to bug in Mobile - might get all 3 contacts the same
        if(CS.Contact_2__c != null){  
            CA2.Contact__c = CS.Contact_2__c;
            CA2.Call_Report__c = cr.Id;
            CA2.Call_Notes__c = cr.Call_Notes__c;
            CA2.Next_Call_Objective__c = cr.Next_call_Objective__c;
            CA2.Call_Date__c = cr.CallDate__c;
            insert CA2;
            }        
        
    //Third Attendee
    //Due to bug in Mobile - might get all 3 contacts the same
        if(CS.Contact_3__c != null){  
            CA2.Contact__c = CS.Contact_3__c;
            CA2.Call_Report__c = cr.Id;
            CA2.Call_Notes__c = cr.Call_Notes__c;
            CA2.Next_Call_Objective__c = cr.Next_call_Objective__c;
            CA2.Call_Date__c = cr.CallDate__c;
            insert CA3;
            }

   //First Product
    if(CS.Product_1__c != null){  
    PD1.Sequence__c = 1;    
    PD1.Product__c = CS.Product_1__c;
    PD1.Adoption__c = CS.Adoption_1__c;
    PD1.Call_Report__c = cr.Id;
    insert PD1;
    }
   //Second Product
    if(CS.Product_2__c != null){  
    PD2.Sequence__c = 2;
    PD2.Product__c = CS.Product_2__c;
    PD2.Adoption__c = CS.Adoption_2__c;
    PD2.Call_Report__c = cr.Id;
    insert PD2;
    }     
   //Third Product
    if(CS.Product_3__c != null){  
    PD3.Sequence__c = 3;    
    PD3.Product__c = CS.Product_3__c;
    PD3.Adoption__c = CS.Adoption_3__c;
    PD3.Call_Report__c = cr.Id;
    insert PD3;
    }    
    
   //First Sample
    if(CS.Sample_1__c != null){  
//    Decimal SampleCost1 = [select Cost__c from Sample__c where id = :CS.Sample_1__c];
    SI1.Sample__c = CS.Sample_1__c;
    SI1.Lot_Number__c = CS.Lot_Number_1__c;
    SI1.Contact__c = CS.Contact_1__c;
    SI1.Status__c = CS.Status_1__c;
    SI1.Quantity__c = CS.Sample_Quantity_1__c;
    SI1.Cost__c = CS.Sample_1__r.cost__c;
    SI1.Call_Report__c = cr.Id;
    insert SI1;
    }   
   //Second Sample
    if(CS.Sample_2__c != null){  
    SI2.Sample__c = CS.Sample_1__c;
    SI2.Lot_Number__c = CS.Lot_Number_2__c;
    SI2.Contact__c = CS.Contact_1__c;    
    SI2.Status__c = CS.Status_2__c;    
    SI2.Quantity__c = CS.Sample_Quantity_2__c;    
    SI2.Call_Report__c = cr.Id;
    insert SI2;
    } 
   //Third Sample
    if(CS.Sample_1__c != null){  
    SI3.Sample__c = CS.Sample_1__c;
    SI3.Lot_Number__c = CS.Lot_Number_3__c;
    SI3.Contact__c = CS.Contact_1__c;    
    SI3.Status__c = CS.Status_3__c;   
    SI3.Quantity__c = CS.Sample_Quantity_3__c;     
    SI3.Call_Report__c = cr.Id;
    insert SI3;
    }   

   //First Promo
    if(CS.Promotional_Product_1__c != null){  
    PI1.Promotional_Product__c = CS.Promotional_Product_1__c;
    PI1.Qty__c = CS.Promo_Quantity_1__c;
    PI1.Contact__c = CS.Contact_1__c;    
    PI1.Call_Report__c = cr.Id;
    insert PI1;
    } 
   //Second Promo
    if(CS.Promotional_Product_2__c != null){  
    PI2.Promotional_Product__c = CS.Promotional_Product_2__c;
    PI2.Qty__c = CS.Promo_Quantity_2__c;
    PI2.Contact__c = CS.Contact_1__c;     
    PI2.Call_Report__c = cr.Id;
    insert PI2;
    } 
   //Third Promo
    if(CS.Promotional_Product_3__c != null){  
    PI3.Promotional_Product__c = CS.Promotional_Product_3__c;
    PI3.Qty__c = CS.Promo_Quantity_3__c;
    PI3.Contact__c = CS.Contact_1__c;     
    PI3.Call_Report__c = cr.Id;
    insert PI3;
    }           
           
    //Send Call Summary for approval - this ensures record is locked
    Approval.ProcessSubmitRequest appr = new Approval.ProcessSubmitRequest();
    
    appr.setComments('Lock Call Summary');
    
    appr.setObjectId(cs.id);
    
    //req1.setNextApproverIds([]);
    Approval.ProcessResult result = Approval.process(appr);
}
  }