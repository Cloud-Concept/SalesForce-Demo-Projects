public class BrickActivity{ 

    private final Account brick; 

    public BrickActivity(ApexPages.StandardController stdController) { 
        this.brick= (Account)stdController.getRecord();      
    }                                

    public String getChartData() { 
        // The list of chart items 

     //obtain a list of picklist values
     Schema.DescribeFieldResult F = Call_Report__c.Type__c.getDescribe();
     List<Schema.PicklistEntry> P = F.getPicklistValues();
     //where chart data should be stored.
    List<ChartDataItem> items = new List<ChartDataItem>();
 
 
 for(Schema.PicklistEntry pValue : P)
 {
    integer Count = [select count() from Call_report__c where Brick__c = :brick.id and Type__c = :pValue.getValue() limit 10000];
    if (Count > 0)
//      items.add(new ChartDataItem(pValue.getValue()+ '-['+ Count.format() + ']' , Count.format()));
      items.add(new ChartDataItem(pValue.getValue() , Count.format()));
 }

         

        // Initialize Strings 

        String chd = ''; // Data 
        String chl = ''; // Labels 

        for(ChartDataItem citem : items) { 
            chd += citem.ItemValue + ','; 
            chl += citem.Label + ' (' + citem.ItemValue + ')|'; 
        } 

        //remove the last comma or pipe 
        if (items.size() > 0) { 
            chd = chd.substring(0, chd.length() -1); 
            chl = chl.substring(0, chl.length() -1); 
        } 

 

        // We are only returning the values and labels. The rest of the URL string is in the VF page 
        String result = '&chd=t:' + chd + '&chl=' + chl; // &chl returns with labels pointing to pie pieces 
        //String result = '&chd=t:' + chd + '&chdl=' + chl; // &chdl returns with labels in a legend 

        return result; 
    } 


    // Class holding each chart data item 
    public class ChartDataItem { 

        public String ItemValue {get; set;} 

        public String Label {get; set;} 

        public ChartDataItem(String Label, String Value) 
        { 
            this.Label = Label; 
            this.ItemValue = Value; 
        } 
    } 
}