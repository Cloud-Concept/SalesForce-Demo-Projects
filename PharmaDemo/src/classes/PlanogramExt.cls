public with sharing class PlanogramExt {
    private final Account acct;
    public Map<String, List<Product2>> familyToProductsMapping {get; set;}
        
    public PlanogramExt(ApexPages.StandardController stdController) {
    	this.acct = (Account)stdController.getRecord();
    	Initialize();
    }
    
    public void Initialize() {
        familyToProductsMapping = new Map<String, List<Product2>>();
        //Get All Products Who have Show In Planogram = TRUE
        List<Product2> planogramProducts = [Select p.Show_in_Planogram__c, p.ProductCode, p.Name, p.Image__c, p.Image_Preview__c, p.Grouped_Image__c, p.Grouped_Image_Preview__c, p.Family From Product2 p where Show_in_Planogram__c = true];
        
        //Sort the Products and put them into Buckets by Category/Family
        for(Product2 p : planogramProducts) {
       		String family = p.Family;
       		if(familyToProductsMapping.containsKey(family)) {
       			List<Product2> products = familyToProductsMapping.get(family);
       			products.add(p);
       			familyToProductsMapping.put(family, products);
       		} else {
       			List<Product2> products = new List<Product2>();
       			products.add(p);
       			familyToProductsMapping.put(family, products);
       		}
       	}       
    }
    
    //Get All Categories
    public Set<String> getProductCategories() {
    	return 	familyToProductsMapping.keySet();
    } 
    
    
    public PageReference customClear() {
        return null;
    }
    
    public PageReference customSave() {
    	update acct;
    	Initialize();
        return Page.PlanogramTY;
    }
}