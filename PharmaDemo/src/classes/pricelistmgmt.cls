public with sharing class pricelistmgmt {

    private Price_List__c pricelist;
    
    public boolean reloadpls{get;set;}
    
    Public boolean editPrice{get{
        if(editPrice == null){
            editPrice = false;
            reloadpls = false;
        }
        return editPrice;
    }set;}
    
  

    public pricelistmgmt(ApexPages.StandardController controller) {
        this.pricelist = (Price_List__c)controller.getRecord();
    }
    
    public set<id> inlist{get;set;}
    
    public list<price_list_rule__c> pricerules{get;set;}
    
    public list<price_list_skus__c> pricingedit{get;set;}
    
     public map<id,price_list_skus__c> pricing {get{
         if(pricing == null || reloadpls==true){
             pricing = new map<id,price_list_skus__c>();
             for(price_list_skus__c t: PLS){
                 pricing.put(t.sku__c, t);
             }
            
         }
     return pricing;
     }set;}    
 
    
    public list<price_list_skus__c> PLS {get{
        if(PLS==null || reloadpls==true){
        
            PLS=[select id, (select id, name, Discount__c, Max_Volume__c, Min_Volume__c from Price_List_Rules__r order by min_volume__c), SKU__c, SKU__r.description__c, SKU__r.Name, SKU__r.Custom_Product__c, SKU__r.price__c, price__c from price_list_skus__c where price_list__c = :pricelist.id order by SKU__r.Custom_Product__c DESC];
            reloadpls = false;
        }
        inlist = new set<id>();
     for(price_list_skus__c pl : PLS){
             if(pl.price__c == null){
                   pl.price__c = pl.SKU__r.price__c;
             }
                 
                inlist.add(pl.sku__c);
            
            }
            
    return PLS;
    }set;}
    
    public string iddebug{get{
        if(iddebug == null){
           // iddebug = 'waiting';
        }
        return iddebug ; 
    }set;}
    
     public list<Stock_Product__c> allskus{get{
        if(allskus==null){
        
            allskus=[select id, name, Visible__c, (select id, custom_product__c, name, description__c, price__c, pack_size__c from SKU_s__r) from Stock_Product__c order by name ASC];
        }
    return allskus;
    }set;}
    
    
    public pageReference addskus(){
       string skuid = ApexPages.currentPage().getParameters().get('skuid');
       id allid = ApexPages.currentPage().getParameters().get('allid');
       boolean multi = false;
       list<string> ids = new list<string>();
       
       if(allid == null){
           ids = skuid.split('-');
           allid = ids[0];
       
       }else{
       
           multi = true;
       }
       
       
       list<price_list_skus__c> pl = new list<price_list_skus__c>();
       
       for(Stock_Product__c sp : allskus){
           if(allid == sp.id){
               for(SKU__c s : sp.SKU_s__r){
               price_list_skus__c p = new price_list_skus__c();
               if(inlist.contains(s.id)==false && ((multi == true) || (multi==false && string.valueof(s.id) == ids[1]))){
               p.price_list__c = pricelist.id;
               p.price__c = p.SKU__r.price__c; 
               p.SKU__c = s.id;
               p.sku__r = s;
                   pl.add(p);
                 }
                   
                 
               }
           PLS.addall(pl);
           }
       
       }
        
        
        return null;
    }
    
    public pageReference editconditions(){
        id edid= ApexPages.currentPage().getParameters().get('edid');
        editPrice = true;
        if(pricerules != null && pricing.containsKey(pricingedit[0].sku__c)){
            for(price_list_rule__c pr : pricerules){
                if(pr.id == null){
                    pricing.get(pricingedit[0].sku__c);
                }
            }
        
            pricing.get(pricingedit[0].sku__c).Price_List_Rules__r.addall(pricerules);
        }
        
        pricingedit = new list<price_list_skus__c>();
        pricerules = new list<price_list_rule__c>();
        if(pricing.containsKey(edid)){
            pricingedit.add(pricing.get(edid));
            pricerules = pricingedit[0].Price_List_Rules__r.clone();
        }else{
            for(price_list_skus__c p : PLS){
                if(p.sku__c == edid){
                    price_list_rule__c plr = new price_list_rule__c();
                    //plr.Price_List_SKU__c = p.id;
                    plr.min_volume__c = 0;
                    plr.Price_List_SKU__r = p;
                    
                    pricingedit.add(p);
                    pricerules.add(plr);
                }
            }
        
        }
        
        
        return null;
    
    }
    
    public pageReference removesku(){
        string remid= ApexPages.currentPage().getParameters().get('remid');
        
        integer i = 0;
        integer rem = 0;
        for(price_list_skus__c p : PLS){
            if(p.sku__c == remid){
                rem = i;
            }
            i++;
        
        }
        inlist.remove(remid);
        PLS.remove(rem);
        return null;
    }
    
    public pageReference addRule(){
       // pricingedit[0].sku__r.description__c += 'x';
       price_list_rule__c pv = new price_list_rule__c();
       if(pricerules.size()>0){
            pv = pricerules.get(pricerules.size()-1);
       }
        price_list_rule__c k = new price_list_rule__c(price_list_sku__c = pricingedit[0].id, min_volume__c = pv.max_volume__c, discount__c = pv.discount__c);
        k.price_list_sku__r = pricingedit[0];
        pricerules.add(k);
        return null;
    }
    public pageReference save(){
        upsert PLS;
        return null;
        
    }
    
    public pageReference saveRules(){
    
        upsert pricerules;
        reloadpls = true;
        PLS=null;
        pricing = null;
        return null;
    
    }
    
    public pageReference showskus(){
         id pid = ApexPages.currentPage().getParameters().get('pid');
        
         
         for(Stock_Product__c sp : allskus){
             if(sp.id == pid){
           
                 if(sp.visible__c == true){
                     sp.visible__c = false;
                 }else{
                      sp.visible__c = true;
                 }
               
             }
         
         }
    
        return null;
    
    }

}