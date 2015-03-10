public class UpdateCampaignMemberClass{

    public final CampaignMember cm;

    private ApexPages.StandardController cmController;

    public UpdateCampaignMemberClass(ApexPages.StandardController controller) {
        cmController = controller;
        this.cm= (CampaignMember)controller.getRecord();
    }

    Public PageReference checkEncryptionKey(){
        string key = ApexPages.currentPage().getParameters().get('key');
        string cmid = ApexPages.currentPage().getParameters().get('id');
        string errorpageref='http://www.budapesthotels.com/sitepic/error_button.png';//page that it's redirrected to if everything isn't as planned
  
        if (key==null || cmid==null){
            return new PageReference(errorpageref);//action that does the redirrecting
        } else { 
              try{
                CampaignMember[] cm= [select id from campaignmember where EncryptedKey__c = :key LIMIT 1];
                if (cm.size()>0){
                    if (cmid==cm[0].id){
                        return null;//if both values match, leave the page as is. 
                    } else {
                        return new PageReference(errorpageref);//action that does the redirrecting
                    } //if 3
                } else {
                    return new PageReference(errorpageref);//action that does the redirrecting
                } //if2
            } catch (Exception e) {
                ApexPages.addMessages(e );
               return new PageReference(errorpageref);//action that does the redirrecting
            }//try
        }//else
        
    }


    public PageReference UpdateCM() {
            try{
                update cm;
            }
            catch(DmlException ex){
                ApexPages.addMessages(ex);
            }
        return new PageReference('http://www.salesforce.com');
    }

   public string getStatus(string Status){
            return 'Status';
   } 
 }