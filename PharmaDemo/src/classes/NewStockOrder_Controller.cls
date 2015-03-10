public class NewStockOrder_Controller {

Stock_Order__c stock_order;
PageReference nextpage;


   public Stock_order__c getStock_Order() {
   string accountid = System.currentPageReference().getParameters().get('accountid');
   string UserId = userinfo.getUserId();
    account account = [select id, price_list__c from account where id=:accountid];
   
      if (stock_order == null) stock_order = new Stock_Order__c();
        stock_order.OwnerId = UserId;
        stock_order.Account__c = accountid;
        stock_order.price_list__c = account.price_list__c;
 
  
  return stock_order;
   }
   
public List<selectOption> getWholesalers() {
           string accountid = System.currentPageReference().getParameters().get('accountid');
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption('', '- None -')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        for (Wholesaler__c wholesalers: [Select Wholesaler__c, Wholesaler__r.Name, Account__c, primary__c From Wholesaler__c Where Account__c = :accountID order by primary__c desc, Wholesaler__r.Name asc])
        {
            options.add(new selectOption(wholesalers.Wholesaler__c, wholesalers.Wholesaler__r.Name));
        }
        return options; //return the picklist options
        
    }  

public List<selectOption> getContacts() {
           string accountid = System.currentPageReference().getParameters().get('accountid');
        List<selectOption> contactoptions = new List<selectOption>(); //new list for holding all of the picklist options
        contactoptions.add(new selectOption('', '- None -')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        for (Location__c contacts: [Select contact__c, Contact_Name__c From Location__c Where Account__c = :accountID order by contact__r.LastName asc])
        {
            contactoptions.add(new selectOption(contacts.contact__c, contacts.Contact_Name__c));
        }
        return contactoptions ; //return the picklist options
        
    }       
   
   
   public PageReference cancel() {
     nextpage = new PageReference('/'+stock_order.account__c);
     nextpage.setRedirect(true);
     return nextpage;
   }
   
   public PageReference save() {
     insert stock_order;
     nextpage = new PageReference('/'+stock_order.id);
     nextpage.setRedirect(true);
     return nextpage;
   }
    

}