trigger PopulateCallReport on Call_Report__c (after insert) {
    
    //pull info from accounts
    List<Contact> cntct = [Select Name, Id, Spec__c, OwnerId From Contact];
    
    //pull any promotions applicable to the account
  List<Campaign_Products__c> cppd = [Select Product_Message__c, Name, Id, Sequence__c, Product__c, Promotion__r.Speciality__c, Promotion__r.IsActive, Promotion__r.EndDate, Promotion__r.StartDate, Promotion__r.Status, Promotion__r.Name, Promotion__r.Id, Promotion__c From Campaign_Products__c]; 
              
    // pull old call reports
    List<Call_Report__c> oldCalls = [Select Type__c, RecordTypeId, Name, LastModifiedDate, Id, Next_Call_Objective__c, CreatedDate, Contact__c From Call_Report__c where Closed__c =: TRUE order by CreatedDate desc];
    
    //pull marketing objectives
    // List<Marketing_Objective__c> mktObjs = [Select Valid_To__c, Valid_From__c, Region__c, Name, Id, Description__c, Customer_Segment__c, Country__c From Marketing_Objective__c];
         
    for(integer x = 0; x < trigger.new.size(); x++){
        
        if(trigger.new.get(x).Contact__c != null){
            //select specific Contact
            Contact con = new Contact();
            for(Contact c: cntct){
              if(c.Id ==  trigger.new.get(x).contact__c){
                con = c;
              } 
            }
            
            if(con.Id != null){
              
              //select appropapate Promotion Products
              //where Campaign__r.Country__c =: acc.BillingCountry and Campaign__r.Target_Segment__c =: acc.Customer_Segment__c
              List<Campaign_Products__c> cpp = new List<Campaign_Products__c>();
              for(Campaign_Products__c c : cppd){
                if((c.Promotion__r.Speciality__c == con.Spec__c)){
                  cpp.add(c);
                }
              }
              
              
              
              //generate call report products
              List<Product_Detail__c> callprod = new List<Product_Detail__c>();
              for(Campaign_Products__c p: cpp){
                  callprod.add(new Product_Detail__c(Call_Report__c = trigger.new.get(x).Id, Product__c = p.product__c, Sequence__c = p.Sequence__c, Promotion__c = p.Promotion__r.Id, Product_Message__c = p.Product_Message__c));
              }
              insert callprod;
              
      
              //select last applicable call report
              //Account__c =: trigger.new.get(x).Account__c and
              List<Call_Report__c> lastCall = new List<Call_Report__c>();
              for(Call_Report__c c: oldCalls){
                if(c.contact__c == trigger.new.get(x).contact__c){
                  lastCall.add(c);
                }
              }
              
              
              //select applicable marketing objectives
              // where Country__c =: acc.BillingCountry and Customer_Segment__c =: acc.Customer_Segment__c and Valid_From__c <=:activityDate and Valid_To__c >=: activityDate
//              List<Marketing_Objective__c> mktObj = new List<Marketing_Objective__c>();
//              for(Marketing_Objective__c m: mktObjs){
//                if((m.Country__c == acc.BillingCountry)&&(m.Customer_Segment__c == acc.Customer_Segment__c)&&(m.Valid_From__c <= activityDate)&&(m.Valid_To__c >= activityDate)){
//                  mktObj.add(m);
//                }
//              }
              
//              system.debug('***************** mktObj: '+mktObj);
              
              //make new objectives
//              List<Objective__c> objs = new List<Objective__c>();
//              if(lastCall.size()>0){
//                  if(lastCall.get(0).Discuss_X__c){
//                      objs.add(new Objective__c(Call_Report__c = trigger.new.get(x).Id, Objective__c = 'Rework display', Details__c = 'Need to check/approve/discuss reworked display'));
//                  }
//                  if(lastCall.get(0).Discuss_Y__c){
//                      objs.add(new Objective__c(Call_Report__c = trigger.new.get(x).Id, Objective__c = 'Put up new signage', Details__c = 'Need to check/approve/discuss new signage'));
//                  }
//                  if(lastCall.get(0).Discuss_Z__c){
//                     objs.add(new Objective__c(Call_Report__c = trigger.new.get(x).Id, Objective__c = 'Discuss upcoming promotions', Details__c = 'Need to discuss upcoming promotions'));
//                  }
//              }

//              if(mktObj.size()>0){
//                  for(Marketing_Objective__c m: mktObj){
//                      objs.add(new Objective__c(Call_Report__c = trigger.new.get(x).Id, Objective__c = m.Name, Details__c = m.Description__c));
//                  }
//              }
//              insert objs;
              
              //determine the time for the activity
              Integer activitytime = 0;
              if(callprod.size()>0){
                  for(Product_Detail__c c:callprod){
                      activitytime = activitytime+5;
                  }
              }
//              if(objs.size()>0){
//                  for(Objective__c o:objs){
//                      activitytime = activitytime+10;
//                  }
//              }
              if(activitytime<15){
                  activitytime = 15;
              }   
//**                         
//**
            }
        }
    }
  
    
}