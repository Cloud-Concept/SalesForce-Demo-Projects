public class StockOrderExtension {
    
    // ###############################
    // Variables
    // ###############################
    
    private final Stock_Order__c stockOrder;
    private String accountID;

    
    
    public String tableStart {get;set;}
    public String tableMiddle {get;set;}
    public String tableEnd {get;set;}
    PageReference nextpage;
    
    public List<stockProductClass> stProducts {get;set;}
    
    
    // ###############################
    // Properties
    // ###############################
    

    
    
    public Integer getListSize() {
        Integer intListSize = 0;
        
        if (stProducts != null) {
            intListSize = stProducts.size();
        }
        
        return intListSize;
            
    }
    
    public Integer getHalfListSize() {
        Integer intListSize = 0;
        
        if (stProducts != null) {
            intListSize = (integer)(stProducts.size()/2);
        }
        
        return intListSize;
    }
    
    public Decimal getTotalOrderVol() {
    
        Decimal decVol = 0;
    
        if (stProducts != null) {
            for (stockProductClass st : stProducts) {
                for (skuClass sku : st.skus) {
                    if (sku != null) {
                        decVol = decVol + sku.skuOrderLineItemQuantity;
                    }
                }
            }
        }
        
        return decVol;
        
    }
    
    public Decimal getTotalOrderCost() {
    
        Decimal decCost = 0;
    
        if (stProducts != null) {
            for (stockProductClass st : stProducts) {
                for (skuClass sku : st.skus) {
                    if (sku != null) {
                        if (sku.skuNewPrice != null) {
                            if (sku.skuOrderLineItemQuantity != null) {
                                decCost = decCost + (sku.skuNewPrice * sku.skuOrderLineItemQuantity);
                            }
                        }
                    }
                }
            }
        }
        
        return decCost;
        
    }
    
    
    // ###############################
    // Functions
    // ###############################
    
    public StockOrderExtension(ApexPages.StandardController stdController) {
        
        this.stockOrder = (Stock_Order__c)stdController.getRecord();
        Stock_Order__c dbStockOrder;
        
        tableStart = '<tr><td>';
        tableMiddle = '</td><td>';
        tableEnd = '</td></tr>';
        
        if (stockOrder != null) {
            dbStockOrder = [Select ID, Account__c From Stock_Order__c Where ID = :stockOrder.Id];
            accountID = dbStockOrder.Account__c;
        }
        
    }
    
    public void LoadProductStructure() {
        
        Map<Id,Id> stockProductMap = new Map<Id,Id>();
        List<SKU__c> SKUList= new List<SKU__c>();
        List<Stock_Product__c> stockProducts = new List<Stock_Product__c>();
        List<Stock_Order__c> pastStockOrders = new List<Stock_Order__c>();
        List<Order_Line_Detail__c> pastOrderLineDetails = new List<Order_Line_Detail__c>();
        List<Order_Line_Detail__c> currentOrderLineDetails = new List<Order_Line_Detail__c>();
        List<Promotion__c> productPromotions = new List<Promotion__c>();
        List<Price_List_SKUs__c> priceListSKUs = new List<price_list_skus__c>();
        Map<ID, Wholesaler__c> accountWholesalers = new Map<ID, Wholesaler__c>();
        List<ID> accountWholesalerIDs = new List<ID>();
        List<SelectOption> options = new List<SelectOption>();
        List<SelectOption> priceListOptions = new List<SelectOption>();
        String strPriceListName = '';
        
        stockProductClass stockProduct;
        skuClass sku;
        stockPromotions stPromo;
        
        // Initialise the wrapper class
        stProducts = new List<stockProductClass>(); 
        
        // Load stock products
        stockProducts = [Select Id, Name, Product_Type__c From Stock_Product__c Order By Name ASC];
        
        // Load Wholesalers
        accountWholesalers = new Map<Id, Wholesaler__c>([Select Wholesaler__c, Wholesaler__r.Name, Account__c From Wholesaler__c Where Account__c = :accountID]);
        
        // Build Wholesalers options list
        if (accountWholesalers.size() == 0) {
            options.add(new SelectOption('', '--'));
        }
        
        for (Wholesaler__c ws : accountWholesalers.values()) {
            accountWholesalerIDs.add(ws.Wholesaler__c);
            options.add(new SelectOption(ws.Wholesaler__c, ws.Wholesaler__r.Name));
        }
        
        // Load Price Lists
        priceListSKUs = [Select ID, SKU__c, price__c, price_list__r.shipping_date__c, price_list__r.name  
                                    From Price_List_SKUs__c 
                                        Order By SKU__r.Custom_Product__c DESC];
        
        // Build products
        for (Stock_Product__c sp : stockProducts) {
            if (!stockProductMap.containsKey(sp.Id)) {
                stockProduct = new stockProductClass();
                
                stockProduct.spHasPromotion = false;
                stockProduct.spID = sp.Id;
                stockProduct.spName = sp.Name;
                stockProduct.spProductType = sp.Product_Type__c;
                stockProduct.skus = new List<skuClass>();
                
                stockProduct.spOrder1Cost = 0;
                stockProduct.spOrder2Cost = 0;
                stockProduct.spOrder1Vol = 0;
                stockProduct.spOrder2Vol = 0;
                stockProduct.spFreeVol = 0;                
                
                stockProduct.spExpand = false;
                stockProduct.spPromoHeader = '';
                stockProduct.spWholesalers = options;
                
                stProducts.add(stockProduct);
                stockProductMap.put(sp.Id, sp.Id);
            }
        }
        
        // Load SKUs
        SKUList = [select Id, Name, Current_Stock__c, 
                    Description__c, 
                        Custom_Product__c, 
                            Order_Line_Item_Quantity__c, 
                                Pack_Size__c, Price__c 
                                    From SKU__c Order By Name ASC];
        
        // Load Past Order Volume and Cost
        pastStockOrders = [Select Id, Account__c, Wholesaler__c From Stock_Order__c Where Account__c = :accountID Limit 2];
        
        pastOrderLineDetails = [Select SKU_Name__c, Quantity__c, Product_custom__c, Price__c, Wholesaler__c, Stock_Order__r.Wholesaler__c  
                                    From Order_Line_Detail__c 
                                        Where Stock_Order__c IN :pastStockOrders 
                                            Order By Stock_Order__r.Order_Date__c ASC];
        
        // Load Existing Order Line Items
        if (stockOrder != null) {
            currentOrderLineDetails = [Select ID, SKU_Name__c, Quantity__c, Product_custom__c, Price__c, Wholesaler__c, Stock_Order__r.Wholesaler__c  
                                    From Order_Line_Detail__c 
                                        Where Stock_Order__c = :stockOrder.Id  
                                            Order By Stock_Order__r.Order_Date__c ASC];
        }
        
        // Load Promotions
        productPromotions = [Select Wholesaler__c, Value__c, Start_Date__c, SKU__c, 
                                SKU_Product__c, Description__c, Active__c 
                                    From Promotion__c Where SKU__c IN: SKUList 
                                        And Active__c = true 
                                            And Start_Date__c <= :system.today() 
                                                And End_Date__c >= :system.today()
                                                    And Wholesaler__c IN :accountWholesalerIDs];
        
        // Build SKUs
        for (SKU__c su : SKUList) {
            sku = new skuClass();
            
            sku.skuID = su.Id;
            sku.skuCurrentStock = su.Current_Stock__c;
            sku.skuDescription = su.Description__c;
            sku.skuName = su.Name;
            sku.skuOrderLineItemQuantity = su.Order_Line_Item_Quantity__c;
            sku.skuPackSize = su.Pack_Size__c;
            sku.skuPrice = su.Price__c;
            if (sku.skuPrice == null) {
                sku.skuPrice = 0;
            }
            sku.skuNewPrice = su.Price__c;
            sku.skuOrderLineItemQuantity = 0;
            sku.skuOrder1Cost = 0;
            sku.skuOrder2Cost = 0;
            sku.skuOrder1Vol = 0;
            sku.skuOrder2Vol = 0;
            sku.skuOrderFreeVol = 0;             
            sku.skuPromos = new List<stockPromotions>();
            
            priceListOptions = new List<SelectOption>();
            
            for (Price_List_SKUs__c pl : priceListSKUs) {
                if (pl.SKU__c == sku.skuID) {
                    strPriceListName =  pl.price_list__r.name;
                    
                    if (pl.price_list__r.shipping_date__c != null) {
                        strPriceListName = 
                            strPriceListName + ' ' + pl.price_list__r.shipping_date__c.day() +
                                '/' + pl.price_list__r.shipping_date__c.month() +
                                    '/' + pl.price_list__r.shipping_date__c.year();
                    }
                    
                    priceListOptions.add(new SelectOption(pl.Id, strPriceListName));
                }
            }
            
            if (priceListOptions.size() == 0) {
                priceListOptions.add(new SelectOption('', 'Default'));
            }
            
            sku.skuPriceLists = priceListOptions;
            
            // Add Past Quota
            for (Order_Line_Detail__c pold : pastOrderLineDetails) {
                if (pold.SKU_Name__c != null) {
                    if (pold.SKU_Name__c.indexOf(su.Name) >= 0) {
                        if (sku.skuOrder1Cost == 0) {
                            sku.skuOrder1Vol = pold.Quantity__c;
                            sku.skuOrder1Cost = pold.Price__c;
                        } else {
                            sku.skuOrder2Vol = pold.Quantity__c;
                            sku.skuOrder2Cost = pold.Price__c;
                        }   
                        // Add Wholesaler to SKU
                        sku.skuWholesaler = pold.Stock_Order__r.Wholesaler__c;
                    }
                }
            }
            
            // Add Existing Order Line Item Details
            for (Order_Line_Detail__c nold : currentOrderLineDetails) {
                if (nold.SKU_Name__c != null) {
                    if (nold.SKU_Name__c.indexOf(su.Name) >= 0) {
                        sku.skuOLIID = nold.Id;
                        sku.skuOrderLineItemQuantity = nold.Quantity__c;
                        sku.skuWholesaler = nold.Wholesaler__c;
                    }
                }
            }
            
            // Add Promos
            for (Promotion__c pr : productPromotions) {
                stPromo = new stockPromotions(); 
                if (pr.SKU__c == su.Id) {
                    stPromo.sproDescription = pr.Description__c;
                    stPromo.sproProductID = pr.SKU_Product__c;
                    stPromo.sproSKUID = su.Id;
                    stPromo.sproStartDate = pr.Start_Date__c;
                    stPromo.sproValue = pr.Value__c;
                    stPromo.sproWholesalerID = pr.Wholesaler__c;
                    
                    // Calculate new price
                    sku.skuNewPrice = sku.skuPrice * ((100 - pr.Value__c)/100);
                    
                    // Add Wholesaler to SKU
                    sku.skuWholesaler = stPromo.sproWholesalerID;
                    
                    sku.skuPromos.add(stPromo);
                }
            }
            
            for (stockProductClass spc : stProducts) {
                if (spc != null) {
                    if (spc.spId == su.Custom_Product__c) {
                        spc.skus.add(sku);
                        
                        // Expad product
                        if ((sku.skuOrder1Cost > 0) || (sku.skuOrder2Cost > 0)) {
                            spc.spExpand = true;
                        }
                        
                        if (sku.skuOrderLineItemQuantity > 0) {
                            spc.spExpand = true;
                        }
                        
                        // Add promotion header
                        if (stPromo != null) {
                            if (stPromo.sproDescription != null) {
                                spc.spPromoHeader = spc.spPromoHeader + ' ' + stPromo.sproDescription;
                                spc.spExpand = true;
                            }
                        }
                        
                        if (spc.spPromoHeader != null) {
                            if (spc.spPromoHeader != '') {
                                spc.spHasPromotion = true;
                            }
                        }
                        
                        break;
                    }
                }
            }
        }
        
    }
    
     public PageReference CloseOrder() {
     nextpage = new PageReference('/'+stockOrder.Id);
     nextpage.setRedirect(true);
     return nextpage;
   }    
    
    public PageReference SaveOrderLineItems() {
        
        List<ID> existingOrderLineItemIDs = new List<ID>();
        List<Order_Line_Detail__c> dbOrderLineItems = new List<Order_Line_Detail__c>();
        List<Order_Line_Detail__c> newOrderLineItems = new List<Order_Line_Detail__c>();
        Order_Line_Detail__c orderLineItem;
        
        if (stockOrder != null) {
            // Retrive existing ones
            for (stockProductClass st : stProducts) {
                for (skuClass sku : st.skus) {
                    
                    if (sku.skuOLIID != null) {
                        if (sku.skuOLIID != '') {
                            existingOrderLineItemIDs.add(sku.skuOLIID);
                        }
                    }
                }
            }
            
            // Load records from DB
            if (existingOrderLineItemIDs != null) {
                dbOrderLineItems = [Select ID, Wholesaler__c, Quantity__c, Product_custom__c, Price__c, Free__c, description__c 
                                    From Order_Line_Detail__c 
                                        Where ID IN: existingOrderLineItemIDs];
                
                for (stockProductClass st : stProducts) {
                    for (skuClass sku : st.skus) {
                        if (sku.skuOLIID != null) {
                            if (sku.skuOLIID != '') {
                                for (Order_Line_Detail__c dboli : dbOrderLineItems) {
                                    if (dboli != null) {
                                        if (dboli.Id == sku.skuOLIID) {
                                            dboli.SKU_Name__c = sku.skuName;
                                            dboli.Wholesaler__c = sku.skuWholesaler;        
                                            dboli.Quantity__c = sku.skuOrderLineItemQuantity;
                                            dboli.Product_custom__c = st.spID;
                                            dboli.Price__c = sku.skuOrderLineItemQuantity * sku.skuNewPrice;
                                            dboli.Free__c = sku.skuOrderFreeVol;
                                            dboli.Description__c = sku.skuDescription;
                                            break;  
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                update (dbOrderLineItems);
                
            } // End DB check
            
            // Insert new order line items
            for (stockProductClass st : stProducts) {
                for (skuClass sku : st.skus) {
                    if (sku.skuOrderLineItemQuantity > 0) {
                        if ((sku.skuOLIID == null) || (sku.skuOLIID == '')) {
                            orderLineItem = new Order_Line_Detail__c(); 
                            
                            orderLineItem.Wholesaler__c = sku.skuWholesaler;        
                            orderLineItem.Quantity__c = sku.skuOrderLineItemQuantity;
                            orderLineItem.Product_custom__c = st.spID;
                            orderLineItem.Stock_Order__c = stockOrder.Id;
                            orderLineItem.SKU_Name__c = sku.skuName;
                            orderLineItem.Free__c = sku.skuOrderFreeVol;
                            orderLineItem.Description__c = sku.skuDescription;                            
                            
                            if (sku.skuNewPrice != null) {
                                if (sku.skuOrderLineItemQuantity != null) {
                                    orderLineItem.Price__c = sku.skuNewPrice * sku.skuOrderLineItemQuantity;
                                }
                            }
                            
                            newOrderLineItems.add(orderLineItem);
                        }
                    } // Quantity Check
                } // SKU Loop
            } // Product Loop
            
            if (newOrderLineItems.size() > 0) {
                insert (newOrderLineItems);
            }
            
        } // End Stock Order Check
        
        return null;
        
    } // End Save Sub
   
   
} // End Class