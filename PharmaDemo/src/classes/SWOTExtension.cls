global with sharing class SWOTExtension
{
    private final Account acc;
    
    public List<SWOT__c> s = new List<SWOT__c>();
    public List<SWOT__c> w = new List<SWOT__c>();
    public List<SWOT__c> o = new List<SWOT__c>();
    public List<SWOT__c> t = new List<SWOT__c>();
    
    public SWOTExtension(ApexPages.StandardController stdController)
    {
        acc = (Account)stdController.getRecord();
        for (SWOT__c swot : [Select Name, Type__c From SWOT__c Where Account__c = :acc.Id]) {
            if (swot.Type__c == 'Strength')
                getS().add(swot);
            if (swot.Type__c == 'Weakness')
                getW().add(swot);
            if (swot.Type__c == 'Opportunity')
                getO().add(swot);
            if (swot.Type__c == 'Threat')
                getT().add(swot);
        }
        
        if (s.isEmpty())
            s.add(new SWOT__c(name = Label.NoStrengths));
        if (w.isEmpty())
            w.add(new SWOT__c(name = Label.NoWeaknesses));
        if (o.isEmpty())
            o.add(new SWOT__c(name = Label.NoOpportunities));
        if (t.isEmpty())
            t.add(new SWOT__c(name = Label.NoThreats));
    }
    
    public List<SWOT__c> getS()
    {
        return s;
    }
    
    public List<SWOT__c> getW()
    {
        return w;
    }
    
    public List<SWOT__c> getO()
    {
        return o;
    }
    
    public List<SWOT__c> getT()
    {
        return t;
    }
    
    @RemoteAction
    global static String saveitem(String description, String type, String acc)
    {
        SWOT__c swot = new SWOT__c(Name = description, Account__c = acc, Type__c = type);
        insert swot;
        return swot.Id;
    }
    
}