/**
*
* Used to prevent recursive trigger execution
*
* @author Maic Stohr
* @date 2009/07/01
*
*/

public class TriggerRecursionDefense {
    
    // Used to prevent ping pong effect between Event and Call_Report__c triggers on updates of each other
    public static String initiatingObject;
    
    // Used to prevent re-execution of update activity when we change to 1:1
    public static Map<Id,Call_Report__c> map_oldCallReports;

    // Used to prevent re-execution of update activity when we change to 1:1
    public static Map<Id,Time_off_Territory__c> map_oldTimeOffs;
}