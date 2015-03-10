public class CallPlanAdd{
  
   public String selectedDay { get; set; } 
   public String selectedWeek { get; set; } 
   public List<SelectOption> allDays = new List<SelectOption>(); //Houses all the days
   public List<SelectOption> allDurations = new List<SelectOption>(); //Houses all the durations
   
    public CallPlanAdd(ApexPages.StandardSetController c) {

        
       cl = new List<contactList>();
      string CallPlanId = ApexPages.currentPage().getParameters().get('vid');
       system.assert( CallPlanId != null, 'missing Call Plan id : vid=');
      callplan = [ select id, name, duration__c from Call_Plan__c where id = :CallPlanId limit 1];
        setcontroller = c; 
        setcontroller.setPageSize(15);
        loadRecords();
        queryForDaysOfWeek();
        queryForDurations();
        
 
    }
  
    public void queryForDaysOfWeek() {

        //Get the Field Token
        Schema.SObjectField sf = Call_Plan_Members__c.Day__c;
        //Call describe on the Field Token
        Schema.DescribeFieldResult sdfr = sf.getDescribe();
       

        for( Schema.PicklistEntry plentry : sdfr.getPicklistValues())
            allDays.add(new SelectOption(plentry.getValue(),plentry.getLabel()));
    }
    
    public void queryForDurations() {

        //Get the Field Token
        integer maxDuration = integer.valueof(callplan.duration__c);

        for(integer x = 0; x < maxDuration; x++){
            integer x1 = x + 1;
            string duration = string.valueof(x1);
            allDurations.add(new SelectOption(duration, duration));
    }    
}
    private void trackSelected() {  // update cl_map from current page checkboxs 
      for ( ContactLIst cc : cl ) {
          if ( cc.sel ) {
            cl_map.put(cc.con.id,true);
          } else { 
            if ( cl_map.containsKey(cc.con.id)) 
              cl_map.remove(cc.con.id);
          }
        }
    }
    private void loadRecords() {
    trackSelected();
        
      cl.clear();
      for ( Contact cc : (List<Contact>)setcontroller.getRecords() ) {
          ContactList tmp =  new contactList(cc );
          
          // if they are in the map, set the selected value here
          if ( cl_map.containsKey(tmp.con.id)) {
            tmp.sel = true;
          }
          cl.add( tmp );
        }
    }
    public PageReference massInvite() { 
      List<Call_Plan_Members__c> il = new List<Call_Plan_Members__c>();
      trackSelected();
      for ( id cid : cl_map.keySet() ) {
        il.add( new Call_Plan_Members__c( contact__c = cid, UniqueId__c = cid, Call_Plan__c = callplan.id, Week_Number__c = integer.valueof(selectedWeek) , Day__c = selectedDay) );
        insert il;

      }
            
      system.debug( il);
      return new PageReference( '/'+ callplan.id );
    }
    
    public PageReference previousPage() { 
      setcontroller.previous();
      loadRecords();  
      return null;
    } 
    public PageReference nextPage() {

  // somehow save the ones that were seleted and the others that were not
  // so that we can restore them when we land on this page again?      
    setcontroller.next();
      loadRecords();
      return null;
    }
    public PageReference changedFilter() { 
        system.debug( ' changedFilter ' + setcontroller.getfilterId());
        PageReference p = new PageReference( 
           '/apex/callplan' + 
           '?fcf=' + setcontroller.getfilterId() + '&vid='+callplan.id);
        p.setRedirect(true);
        return p;
    }
    
    /* select all or none */
    private Boolean selall2 = false;
    public Boolean getSelAll2() { return selall2;  }
    public void SetSelAll2 ( boolean r ) { selall2 = r; }
    public String buttonLabel { get { return (selall2 == false ? 'Select All' : 'Select None' ); } }
    public PageReference doSelAll() {      // put everything on the list  
      selAll2 =  ! selAll2;
      system.debug( 'sel all is ' + selAll2);
      setSelectAll(selAll2);  
      loadRecords();
      return null;
    }
    
    
    public class contactList { 
      public Contact con { get; set; }
      public boolean sel { get; set; }
      public Call_Plan_Members__c cpm { get; set; }
      public contactList( Contact c ) { con = c; sel = false; }
    }
    public ApexPages.StandardSetController setcontroller { get; private set;} 
    
    public List<ContactList> cl { get; set;} 
    
    // selected items map
    public Map<id,Boolean> cl_map = new Map<Id,Boolean>();
    
    
    private void setSelectAll( boolean sel ) {
      // put all on the selected map, or remove all...
      integer pagenum = setcontroller.getPageNumber();
      if ( sel == false ) { 
        cl_map.clear(); 
        for ( ContactLIst cc : cl ) { cc.sel = false; }
      }
      else {
        for ( ContactLIst cc : cl ) { cc.sel = true; }
        setcontroller.first();
        do {
            for ( Contact cc : (List<Contact>)setcontroller.getRecords() ) {
              cl_map.put( cc.id, true);
          }
          if ( setcontroller.getHasNext() ) setcontroller.next();
        }  while ( setcontroller.getHasNext() == true );
      } 
    
      setcontroller.setPageNumber(pagenum);
    }
    
    public Integer pageSize { get { return ((setcontroller.getresultSize() / setcontroller.getPageSize() ) + 1); }}
    public Call_Plan__c callplan{ get; set; }
    
        public List<SelectOption> getallDays() {
        return allDays;
     }
     
       public List<SelectOption> getallDurations() {
        return allDurations;
     }     
    

      
     
}