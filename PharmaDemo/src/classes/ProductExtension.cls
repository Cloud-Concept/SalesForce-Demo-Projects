public class ProductExtension {
    
    public Stock_Order__c contextStockOrder;    //The current Stock Order referenced from the VF page
   
   
    public String selectedCategory { get; set; }                               //the currently selected product category
    public String selectedProduct { get; set; }                                //Id of the currently selected product  
    public Boolean isProductCategoryNotNone { get; set; }                      //Tells us if the selected Category is --None--                                           
    public Boolean showSKUPageBlockSection { get; set; }
    public Boolean showSaveMessage { get; set; }
    public String saveMessageTitle { get; set; }
    public String saveMessageDetail { get; set; }                       
    
                                              
    public List<Order_Line_Detail__c> orderDetailsList;
    public List<Stock_Product__c> stockProducts = new List<Stock_Product__c>();                                              
    public List<SelectOption> allProductCategories = new List<SelectOption>(); //Houses all the product categories
    public List<SelectOption> allProducts = new List<SelectOption>();          //Houses all the products
    public List<SKU__c> skuRecordsList = new List<SKU__c>();             //Houses SKU Records for the product in context
    
    
    //mandatory controller extension constructor...
    public ProductExtension (ApexPages.StandardController stdController) {
        this.contextStockOrder = (Stock_Order__c) stdController.getRecord();
        queryForProductCategories();
        showSaveMessage = false;
    }
    
    //This method queries for all the current Stock product Categories...
    public void queryForProductCategories() {

        //Get the Field Token
        Schema.SObjectField sf = Stock_Product__c.Product_Type__c;
        //Call describe on the Field Token
        Schema.DescribeFieldResult sdfr = sf.getDescribe();
       
        //add the defaul sf selectlist value to
        //the SelectOption list...
        allProductCategories.add(new SelectOption('null','--None--'));

        for( Schema.PicklistEntry plentry : sdfr.getPicklistValues())
            allProductCategories.add(new SelectOption(plentry.getValue(),plentry.getLabel()));
    }
    
    //This method querys for all the products associated
    //with the selected category
    public void queryForProducts() {
        //reset the Products for each click of the
        //Product category list...
        if(allProducts.size() > 0)
            allProducts = new List<SelectOption>();
    
        //if the selected category is not '--None--'
        if (selectedCategory != 'null') {
            isProductCategoryNotNone = true;
            
            //add a default selectOption to the allProductsList
            allProducts.add(new SelectOption('null','--None--'));
            
            //Loop through all the products for this category and add to the allProductsList
            for(Stock_Product__c dbstockProduct : [Select Id, Name From Stock_Product__c Where Product_Type__c =:selectedCategory])
                allProducts.add(new SelectOption(dbstockProduct.id,dbstockProduct.Name)); 
                
        }else {
            //Selected category is '--None--'
            isProductCategoryNotNone = false;
        }
        
        showSKUPageBlockSection = false;
    }
    
    //This method will query for all the SKU's associated with
    //the product that is selected from the visualforce page (products list)
    public void queryForSKUs() {
        //each time this method is invoked, we want to 
        //reset the available SKU's for the table
        skuRecordsList = new List<SKU__c>();
        
        if(selectedProduct != 'null') {        
            try {
                /*
                 *  CHANGE SOQL Query to retrieve your SKU fields
                 */
            skuRecordsList = [Select Name, Description__c, Pack_Size__c, Price__c, Order_Line_Item_Quantity__c From SKU__c Where Custom_Product__c =:selectedProduct]; 
                    
            if(skuRecordsList.size() > 0)
                showSKUPageBlockSection = true;
            
            }catch(QueryException qe) {
                System.debug('********* THERE WAS A QUERY ERROR: ' + qe.getMessage());
            }
        }else {
            showSKUPageBlockSection = false;
        }
    }
    
    //This method rolls all the SKU's that have
    //a quantity >= 1 up to the Master Stock Order Detail Line Item
    public PageReference addToOrder() {
        orderDetailsList = new List<Order_Line_Detail__c>();
        
        //Loop through all the SKU records that are in the Table...
        for(SKU__c currentSKURecord : skuRecordsList) {
            //If any of the records have a quantity > 1...
            if(currentSKURecord.Order_Line_Item_Quantity__c >= 1) {
                //Create a new Order_Line_Detail__c record...
                Order_Line_Detail__c newOrderDetailRec = new Order_Line_Detail__c(Stock_Order__c = contextStockOrder.id, 
                                                                                  SKU_Name__c = currentSKURecord.Name,
                                                                                  Product_custom__c = selectedProduct,
                                                                                  Pack_Size__c = currentSKURecord.Pack_Size__c,
                                                                                  Description__c = currentSKURecord.Description__c,
                                                                                  Quantity__c = currentSKURecord.Order_Line_Item_Quantity__c,
                                                                                  Price__c = (currentSKURecord.Order_Line_Item_Quantity__c * currentSKURecord.Price__c));
                //and add to the list to be commited to the database.
                orderDetailsList.add(newOrderDetailRec);
            }
        }
        
        //If there are records to be inserted to the DataBase...
        if(orderDetailsList.size() > 0) {
            try {
                //Perform an upsert.
                upsert(orderDetailsList);
                
                saveMessageTitle = 'SKU\'s successfully saved';
                saveMessageDetail = 'A total of ' + orderDetailsList.size() + ' were added to your order';
            }catch(DMLException dmle) {
                
                saveMessageTitle = 'SKU save error';
                saveMessageDetail = 'There was an error adding the SKU\'s to the order';
                System.debug('****** THERE WAS AN UPSERT ERROR: ' + dmle.getMessage());
            }finally {
                showSaveMessage = true;
            }
        }  

        //Do not want to display pageBlockSection
        //after an order line item is added...
        isProductCategoryNotNone = false;
        
        //clear the SKU list
        skuRecordsList.clear();
        
        //remove the SKU page block section
        showSKUPageBlockSection = false;

        //Do not want to navigate away from the 
        //current visual force page.
        return null;
    }
    
    public PageReference reviewOrder() {
        PageReference orderDetailPage = new PageReference('/' + contextStockOrder.Id);
        orderDetailPage.setRedirect(true);
        return orderDetailPage;
    }
    
    //This method clears the save message on
    //the visual force page.
    public PageReference clearSaveMessage() {
        showSaveMessage = false;
        return null;
    }
    
    /*
     * Define getters & setters
     */
    public List<SelectOption> getAllProductCategories() {
        return allProductCategories;
    }
    
    public List<SelectOption> getAllProducts() {
        return allProducts;
    }

    public List<SKU__c> getSkuRecordsList() {
        return skuRecordsList;
    }
    
    public Boolean getisProductCategoryNotNone() {
        return isProductCategoryNotNone;
    }
    
    public void setAllProductCategories(List<SelectOption> categories) {
        this.allProductCategories = categories;
    }
    
    public void setAllProducts(List<SelectOption> products) {
        this.allProducts = products;
    }
    
    public void setSKURecordsList(List<SKU__c> skusList) {
        this.skuRecordsList = skusList;
    }
}