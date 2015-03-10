trigger AccountPlanogram on Account (after insert, after update) {
    
    List<Planogram__c> toDelete = new List<Planogram__c>();
    List<Planogram__c> toInsert = new List<Planogram__c>();
    
    for(Account a: Trigger.new) {
        
        if(a.AccountPlanogram__c != NULL) {
            String planogramText = a.AccountPlanogram__c;
            
            toDelete.addAll([Select p.Id, p.Account__c From Planogram__c p where Account__c =: a.Id]);
            List<String> products = new List<String>();
            products = planogramText.split(',');
        
            
            for(Integer i = 0; i <= 15; i++) {
                Integer index = i+1;
                Planogram__c currentPlanogram = new Planogram__c();
                currentPlanogram.Account__c = a.id;
                currentPlanogram.Index__c = index;
                if(products.size() > i) {
                    if(products[i] != '') {
                        currentPlanogram.Product__c = products[i];
                    }
                }
                
                String shelf = 'A';
                
                Integer remainder = math.mod(index, 4);
                
                if(index > 4) {
                    shelf = 'B';                
                }
                if(index > 8) {
                    shelf = 'C';                
                }
                if(index > 12) {
                    shelf = 'D';                
                }
                
                String slot = '1';
                
                if(remainder == 1) {
                    slot = '1';
                }
                if(remainder == 2) {
                    slot = '2';
                }
                if(remainder == 3) {
                    slot = '3';
                }
                if(remainder == 0) {
                    slot = '4';
                }
                
                currentPlanogram.Space_Slot_Number__c = shelf + slot;
                toInsert.add(currentPlanogram); 
            
            }           
        }
    }
    
    delete toDelete;
    insert toInsert;
}