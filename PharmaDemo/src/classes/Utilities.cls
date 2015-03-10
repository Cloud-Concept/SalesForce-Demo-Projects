public class Utilities {

    private static Date knownSaturday = Date.newInstance(2009, 1, 10);
    private static Date knownSunday = Date.newInstance(2009, 1, 11);
    
    public static Boolean isSaturday(Date d) {
        // daysBetween() is always positive
        Integer diff = knownSaturday.daysBetween(d);
        return (Math.mod(diff, 7) == 0);
    }
    
    public static Boolean isSunday(Date d) {
        Integer diff = knownSunday.daysBetween(d);
        return (Math.mod(diff, 7) == 0);
    }
    
    public static Id getRecordTypeId (String SobjectType, String DeveloperName) {
    return [select Id, Name, DeveloperName from RecordType 
                    where SobjectType = :SobjectType
                    and DeveloperName = :DeveloperName][0].Id;
    }
    
    private static Boolean alreadyUpdatingEvents = false;
        
    public static Boolean getAlreadyUpdatingEvents()
    {
        return alreadyUpdatingEvents;
    }

    public static void setAlreadyUpdatingEvents(Boolean boolValue)
    {
        alreadyUpdatingEvents = boolValue;
    }    
    
    
    static testMethod void testUtilities(){
        isSaturday(date.today());
        isSunday(date.today());
        getRecordTypeId('Call_Report__c','EU_Call_Report');
    }
}