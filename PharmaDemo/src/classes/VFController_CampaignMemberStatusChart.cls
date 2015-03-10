public class VFController_CampaignMemberStatusChart { 

    private final Campaign camp; 

    public VFController_CampaignMemberStatusChart(ApexPages.StandardController stdController) { 
        this.camp = (Campaign)stdController.getRecord();      
    }                                

    public String getChartData() { 
        // The list of chart items 

        List<ChartDataItem> items = new List<ChartDataItem>(); 

        // List of valid Campaign Member Statuses for the Campaign 

        List<CampaignMemberStatus> list_cms = [select Id, Label from CampaignMemberStatus where CampaignId = :camp.id]; 

        // Loop through each Campaign Member Status, get a count of Campaign Members and add it to the items list 

        for (CampaignMemberStatus cms:list_cms) { 

            integer Count = [select count() from CampaignMember where CampaignId = :camp.id AND Status = :cms.Label]; 

            if (Count > 0) { 
                items.add(new ChartDataItem(cms.Label, Count.format())); 
            } 
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

    static testMethod void testVFController_Sidebar_Summary() { 

        // Create Campaign 

        Campaign c = new Campaign(); 
        c.Name = 'Test Campaign'; 
        insert c; 


        // Create Lead 
        Lead l = new Lead(); 
        l.LastName = 'Last Name'; 
        l.Company = 'Company'; 
        insert l; 

        // Create Campaign Member 

        CampaignMember cms = new CampaignMember(); 
        cms.CampaignId = c.id; 
        cms.LeadId = l.id; 
        insert cms; 

        test.startTest(); 

 
        ApexPages.StandardController sc = new ApexPages.StandardController(c); 

        VFController_CampaignMemberStatusChart controller = new VFController_CampaignMemberStatusChart(sc); 

        String s1 = controller.getChartData(); 

              test.stopTest(); 
            } 
}