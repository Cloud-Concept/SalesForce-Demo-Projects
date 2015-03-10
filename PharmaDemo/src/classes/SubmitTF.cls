public class SubmitTF{

    public SubmitTF(ApexPages.StandardController controller) {

    }


  ApexPages.StandardSetController con;
  string UserId = userinfo.getUserId();      
  public List<Call_Report__c> TFs {get;set;}
  public List<TF__c> selectedTFs {get; set;}
  
  //Constructor
    public SubmitTF(ApexPages.StandardSetController controller) {
      
      con = controller;
      
      if(this.con.getResultSize() > 0 ){ 
      this.con.setPageSize(5);
    } 

    }
    
    public void SubmitTFs() {

        //get the selected assets
        selectedTFs = (List<TF__c>)con.getSelected();
        List<ID> TFIds = new List<ID> ();
        for (TF__c T : selectedTFs)
            TFIds.add (T.id);
        selectedTFs = [select id, Status__c from TF__c where id in :TFIds];
        
        
        for(TF__c TF: selectedTFs){
              string status = 'Submitted';
              TF.status__c = status;
        }
        

    }
    


}