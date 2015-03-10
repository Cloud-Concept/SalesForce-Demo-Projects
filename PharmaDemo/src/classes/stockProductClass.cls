public class stockProductClass {
    public ID spID {get;set;}
    public String spName {get;set;}
    public String spProductType {get;set;}
    public Boolean spHasPromotion {get;set;}
    public Decimal spOrder1Cost {get;set;}
    public Decimal spOrder2Cost {get;set;}
    public Decimal spOrder1Vol {get;set;}
    public Decimal spOrder2Vol {get;set;}
    public Decimal spFreeVol {get;set;}    
    public Boolean spExpand {get;set;}
    public String spPromoHeader {get;set;}
    public List<skuClass> skus {get;set;} 
    public List<SelectOption> spWholesalers {get;set;} 
}