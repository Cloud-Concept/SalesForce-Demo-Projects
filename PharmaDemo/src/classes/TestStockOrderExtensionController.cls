@isTest
private class TestStockOrderExtensionController {


    /*
     *  StockOrderExtensionController
     *  1. Instantiating an instance queries for all product categories
     *  2. When a category is changed, call queryForProducts()
     *  3. When a product is selected, queryForSKUs()
     *  4. Call addToOrder() to simulate the Add To Order button being clicked
     *  5. Call reviewOrder() to simulate the Save Order button being clicked
     *  6. Call clearSaveMessage() to simulate the clear message link being clicked
     */
    
    private static final PageReference visualForcePage = Page.StockOrderPage;
    private static Stock_Order__c stockOrder;
    private static StockOrderPageExtension extensionController;
    
    //static initialization block
    static {
        try {    
            stockOrder = new Stock_Order__c();
            insert stockOrder;
        }catch(QueryException qe) {
            System.debug('****** THERE WAS A QUERY EXCEPTION: ' + qe.getMessage());
        }  
        
        //Refernce the Stock_Order__c standard controller 
        ApexPages.StandardController standardController = new ApexPages.StandardController(stockOrder);
        //Create an instance of our controller extension
        extensionController = new StockOrderPageExtension(standardController);
    }
    
    //First we need to setup a page with a Stock Order Id
    private static testMethod void setupTestVariables() {
        
        //Setup the visual force page to be have an id parameter of a Stock_Order__c SObject instance
        Test.setCurrentPage(visualForcePage);
        ApexPages.currentPage().getParameters().put('id','stockOrder.Id');
        
        //Create some Product Categories
        Stock_Product__c stockProduct = new Stock_Product__c(name='mac', Product_Type__c='Notebook');
        
        //insert these products
        try {
            insert stockProduct;
        }catch(DMLException dmle) {
            System.debug('***** THERE WAS AN ERROR CREATING TEST PRODUCTS: ' + dmle.getMessage());
        }
        
        SKU__c testSKU = new SKU__c(name='SKU-1000',Description__c='3776IA',Pack_Size__c='20.0',Price__c=735.0,Custom_Product__c=stockProduct.Id,Order_Line_Item_Quantity__c = 10);
        
        //insert this SKU
        try {
            insert testSKU;
        }catch(DMLException dmle) {
            System.debug('***** THERE WAS AN ERROR CREATING THE TEST SKU RECORDS: ' + dmle.getMessage());
        }
       
         
        List<SelectOption> categoriesList = new List<SelectOption>();
        categoriesList.add(new SelectOption('null','--None--'));
        categoriesList.add(new SelectOption('Notebook', 'Notebook'));
        extensionController.setAllProductCategories(categoriesList);
     
        System.debug('******* ALL CATEGORIES ARE: ' + extensionController.getAllProductCategories());
        
        extensionController.queryForProducts();
        
        List<SelectOption> productsList = new List<SelectOption>();
        productsList.add(new SelectOption('null','--None--'));
        productsList.add(new SelectOption(stockProduct.id, stockProduct.name));
        extensionController.setAllProducts(productsList);
        
        System.debug('****** ALL PRODUCTS ARE: ' + extensionController.getAllProducts());
        
        extensionController.queryForSKUs();
        
        List<SKU__c> skuList = new List<SKU__c>();
        skuList.add(testSKU);
        extensionController.setSKURecordsList(skuList);
        extensionController.addToOrder();
        System.debug('***** ORDER DETAILS LIST SIZE: ' + extensionController.orderDetailsList.size());
        
        extensionController.clearSaveMessage();
        
        /*
        System.assert(extensionController.getAllProductCategories().size() > 0);
        System.assertEquals(extensionController.getAllProductCategories().get(0).getValue(),'null');
        System.assertEquals(extensionController.getAllProductCategories().get(0).getLabel(),'--None--');
    
        extensionController.selectedCategory = 'Notebook';
        extensionController.queryForProducts();
        System.debug('***** PRODUCTS ARE: ' + extensionController.allProducts);
        
        System.assert(extensionController.getAllProducts().size() > 0);
        System.assertEquals(extensionController.getAllProducts().get(0).getValue(),'null');
        System.assertEquals(extensionController.getAllProducts().get(0).getLabel(),'--None--');
    
        extensionController.selectedProduct = 'mac';
        extensionController.queryForSKUs();
        System.assert(extensionController.showSKUPageBlockSection);
  
        for(SKU__c sku : extensionController.getSKURecordsList())
            sku.Order_Line_Item_Quantity__c = 10;
        extensionController.addToOrder();
        System.assert(extensionController.SaveMessageTitle.contains('successfully saved'));
        */
    }
}