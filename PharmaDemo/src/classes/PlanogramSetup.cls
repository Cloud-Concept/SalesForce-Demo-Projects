public class PlanogramSetup {
    
    public Boolean productsCreated {get; set;}
    
    public PageReference CreateProducts() {
        insert products;
        productsCreated = true;
        return null;
    }

    public List<Product2> products {get; set;}
    public String resourceID {get; set;}
    
    public PlanogramSetup() {
        products = new List<Product2>();
        
        productsCreated = false;
        
        for(Integer i = 0; i < 16; i++) {
            Product2 product = new Product2();
            
            if( i == 0) {
                product.Name = 'Sassy Light Lemon';
                product.Family = 'Sassy Light';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyLight/SassyLightLemon.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyLight/SassyLightLemon4.png';
                
            } else if( i == 1) {
                product.Name = 'Sassy Light Cola';
                product.Family = 'Sassy Light';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyLight/SassyLightCola.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyLight/SassyLightCola4.png';
                
            } else if( i == 2) {
                product.Name = 'Sassy Light Orange';
                product.Family = 'Sassy Light';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyLight/SassyLightOrange.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyLight/SassyLightOrange4.png';
                
            } else if( i == 3) {
                product.Name = 'Sassy Light Lemon Lime';
                product.Family = 'Sassy Light';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyLight/SassyLightLemonLime.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyLight/SassyLightLemonLime4.png';
            
            } else if( i == 4) {
                product.Name = 'Sassy Juice Orange';
                product.Family = 'Sassy Juice';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyJuice/SassyJuiceOrange.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyJuice/SassyJuiceOrange4.png';
            } else if( i == 5) {
                product.Name = 'Sassy Juice Mango';
                product.Family = 'Sassy Juice';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyJuice/SassyJuiceMango.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyJuice/SassyJuiceMango4.png';
            } else if( i == 6) {
                product.Name = 'Sassy Juice Blackcurrant';
                product.Family = 'Sassy Juice';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyJuice/SassyJuiceBlackcurrant.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyJuice/SassyJuiceBlackcurrant4.png';
            } else if( i == 7) {
                product.Name = 'Sassy Juice Apple';
                product.Family = 'Sassy Juice';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyJuice/SassyJuiceApple.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyJuice/SassyJuiceApple4.png';
            } else if( i == 8) {
                product.Name = 'Sassy Sport Lime';
                product.Family = 'Sassy Sport';
                product.Image__c = '/resource/SFPlanogram/Icons/SassySport/SassySportLime.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassySport/SassySportLime4.png';
            } else if( i == 9) {
                product.Name = 'Sassy Sport Lemon';
                product.Family = 'Sassy Sport';
                product.Image__c = '/resource/SFPlanogram/Icons/SassySport/SassySportLemon.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassySport/SassySportLemon4.png';
            } else if( i == 10) {
                product.Name = 'Sassy Sport Orange';
                product.Family = 'Sassy Sport';   
                product.Image__c = '/resource/SFPlanogram/Icons/SassySport/SassySportOrange.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassySport/SassySportOrange4.png';         
            } else if( i == 11) {
                product.Name = 'Sassy Sport Berry';
                product.Family = 'Sassy Sport';
                product.Image__c = '/resource/SFPlanogram/Icons/SassySport/SassySportBerry.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassySport/SassySportBerry4.png';
            } else if( i == 12) {
                product.Name = 'Sassy Fizz Orange';
                product.Family = 'Sassy Fizz';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyFizz/SassyFizzOrange.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyFizz/SassyFizzOrange4.png';
            } else if( i == 13) {
                product.Name = 'Sassy Fizz Lemon';
                product.Family = 'Sassy Fizz';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyFizz/SassyFizzLemon.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyFizz/SassyFizzLemon4.png';

            } else if( i == 14) {
                product.Name = 'Sassy Fizz Cola';
                product.Family = 'Sassy Fizz';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyFizz/SassyFizzCola.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyFizz/SassyFizzCola4.png';
            } else if( i == 15) {
                product.Name = 'Sassy Fizz Berry';
                product.Family = 'Sassy Fizz';
                product.Image__c = '/resource/SFPlanogram/Icons/SassyFizz/SassyFizzBerry.png';
                product.Grouped_Image__c = '/resource/SFPlanogram/Icons/SassyFizz/SassyFizzBerry4.png';
            }    
            product.Show_in_Planogram__c = true;
            products.add(product);
        }
    }    
}