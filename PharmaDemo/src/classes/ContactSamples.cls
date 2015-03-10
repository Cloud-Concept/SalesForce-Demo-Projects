public class ContactSamples { 

    private final Contact contact; 

    public ContactSamples (ApexPages.StandardController stdController) { 
        this.contact = (Contact)stdController.getRecord();      
    }                                

    public String getChartData() { 
        // The list of chart items 

        List<ChartDataItem> items = new List<ChartDataItem>(); 

        // List of valid Campaign Member Statuses for the Campaign 

        List<Sample__c> list_sample = [select Id, name from Sample__c]; 

        // Loop through each Sample, get a count of Samples left and add to list

        for (Sample__c smpl: list_sample) { 

            integer Count = [select count() from Sample_Item__c where Contact__c = :this.contact.Id AND Sample__c = : smpl.Id]; 

            if (Count > 0) { 
                items.add(new ChartDataItem(smpl.Name, Count.format())); 
            } 
        } 


        // Initialize Strings 

        String chd = ''; // Data 
        String chl = ''; // Labels 
        String chdl = ''; // Key 

        for(ChartDataItem citem : items) { 
            chd += citem.ItemValue + ','; 
            chdl += citem.Label + ' (' + citem.ItemValue + ')|'; 
            chl += citem.ItemValue + '|'; 
        } 

        //remove the last comma or pipe 
        if (items.size() > 0) { 
            chd = chd.substring(0, chd.length() -1); 
            chdl = chdl.substring(0, chdl.length() -1); 
            chl = chl.substring(0, chl.length() -1);             
        } 

 

        // We are only returning the values and labels. The rest of the URL string is in the VF page 
        String result = '&chd=t:' + chd + '&chdl=' + chdl + '&chl=' + chl; // &chl returns with labels pointing to pie pieces 
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