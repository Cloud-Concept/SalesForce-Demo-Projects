public class OrderCloneCon {
    
    private final String retURL;
    private final String cancelURL;
    
    private final Stock_Order__c order;
    //constructor
    public OrderCloneCon (ApexPages.Standardcontroller controller) {
        Id orderId;
        try {
            orderId = ApexPages.currentPage().getParameters().get('id');
            String soqlStr = '';
            //Creates a map with all the fields copied from the old opp 
            final Map<String, Schema.SObjectField> fMap = Schema.SObjectType.Opportunity.fields.getMap();
            for (String fName : fMap.keySet()){
                // don't clone owner
                if(fName=='OwnerId') continue;
                soqlStr += fName + ','; 
            }
            if (soqlStr.length() >0)
                soqlStr = soqlStr.substring(0, soqlStr.length()-1);
                
            soqlStr = ' select Account__c, Contact__c, Price_List__c, Your_Reference__c,Wholesaler__c from Stock_order__c where Id=\'' + orderId + '\'';
           System.debug(soqlStr);
            this.order = Database.query(soqlStr); 
            
        } catch (Exception e) {
            addErrorMessage('Failed to load Order by id=' + orderId, e);
            return;
        }
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        //cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
    } 
    
    public PageReference run () {
        Id targetOrderId = doClone();
        if (targetOrderId == null)
            return null;//errors, stay on the page
        
        String OrderEditPageURL = '/' + 
                        targetOrderId + 
                        '/e?retURL=%2F' + 
                        targetOrderId +
                        '&cancelURL=' + 
                        EncodingUtil.urlEncode('/apex/deleteOnCancel?id=' +
                        targetOrderId +
                        '&retURL=/' + 
                        this.order.id,'UTF-8');

        PageReference ref = new PageReference(OrderEditPageURL);
        /** 
        PageReference ref;
        if (retURL != null && retURL.length() >0) {
            ref = new PageReference(retURL);
        } else {
            ref = new PageReference('/' + targetOppId);
        }
        */
        ref.setRedirect(true);
        return ref;
        
    }
    
    
    private Id doClone() {
        if (order == null)
            return null;
        //Clone the opp   
        final Stock_Order__c OrderClone = order.clone(false, true);
        //The clone should be at draft status and not submitted for approval 
        orderClone.Status__c = 'Open';
        orderClone.Reason__c = '';
        orderClone.Your_Reference__c = '***';
        orderClone.Clone_Order__c = false;
        
        try {
            Database.SaveResult sr = Database.insert(orderClone);
            if (!checkErrors(sr, 'Failed to insert cloned Order.'))
                return null;
            
        } catch (Exception e) {
            addErrorMessage('Failed to insert cloned Order.', e);
            return null;
        }
        final String oldOrderId = order.Id;
        final String newOrderId = orderClone.Id;
 
        return orderClone.Id; 
    }

    
    private static String replaceKeyId(final String key, final String oldId,  final String newId) {
        if (key.indexOf(oldId) >=0)
            return key.replace(oldId, newId);
        return key.replace(oldId.substring(0, 15), newId);  
    }
    private static Boolean checkErrors(final Database.SaveResult sr, final String message) {
        return checkErrors(new Database.SaveResult[] {sr}, message);
    }
    private static Boolean checkErrors(final Database.SaveResult[] sres, final String message) {
        for (Database.SaveResult sr : sres) {
            if(!sr.isSuccess()) {
                Database.Error err = sr.getErrors()[0];
                addErrorMessage(message + err.getMessage());
                return false;
            }
        } 
        return true;
    }
    
    private static void addErrorMessage(String msg) {
        System.debug('### ERR=' + msg);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
    }
    private static void addErrorMessage(String msg, Exception e) {
        System.debug('### ERR=' + msg + '::: ' + e.getMessage());
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg, e.getMessage()));
    }
    
  

        
}