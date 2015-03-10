public with sharing class skuClass {
    public String skuOLIID {get;set;}
    public String skuID {get;set;}
    public String skuName {get;set;}
    public String skuCurrentStock {get;set;}
    public String skuDescription {get;set;}
    public Decimal skuOrderLineItemQuantity {get;set;}
    public String skuPackSize {get;set;}
    public Decimal skuPrice {get;set;}
    public Decimal skuNewPrice {get;set;}
    public Decimal skuOrder1Cost {get;set;}
    public Decimal skuOrder2Cost {get;set;}
    public Decimal skuOrder1Vol {get;set;}
    public Decimal skuOrder2Vol {get;set;}
    public Decimal skuOrderFreeVol {get;set;}    
    public String skuWholesaler {get;set;}
    public String skuSelectedPriceList {get;set;}
    public List<stockPromotions> skuPromos {get;set;}
    public List<SelectOption> skuPriceLists {get;set;}
}