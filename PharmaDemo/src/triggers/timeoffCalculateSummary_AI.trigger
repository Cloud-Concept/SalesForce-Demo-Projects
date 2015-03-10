/**
*
* After a submit entry is added to time off territory calculations are done  
*
* @author: Michael Ohme
* @version: 0.1
*
*/

/* Variable list
*
* List<String> list_types - contains all Types for Daily Summary
* Date mindate - Lowest Date to process
* Date maxdate - Highest date to process
* Map<Date,Integer> map_month_sum_counter - total quartes off per month
* Map<date,Map<String,Integer>> map_type_count_month - counted values per Date and type
* Integer counter - counts types per quarter
* Map<String,Integer> map_type_count map_type_count - counted values per type
* Integer sumcounter - store number of quarter
* Map<Integer,Integer> map_workingday - working days per month
* Integer wd_month - month for workingday calculation
* Integer count - counter for working days
* Integer year_loop - starting year
* Date beginn_date - for select of calls
* Date end_date - for select of calls
* Map<String,Daily_Summary__c> map_DS_value - daily summary values per Type
* Daily_Summary__c DS2Insert - store data to insert before putting to list
* Daily_Summary__c DS2Oldvalue - store actual data from Daily Summary / is also used for updates
*/

/*External methodes used
*
* Utilities.isSaturday(d) 
* Utilities.isSunday(d)
*/

trigger timeoffCalculateSummary_AI on Time_off_Territory__c (after insert) {
/*We assume that submitts will not be done by other trigger or loader. 
* For this reason we will have only one user that fires the trigger
*/  

    
    Time_off_Territory__c t = trigger.new[0];
    
    // Get Target of the user
    List<Target__c> list_target = [select Id from Target__c where MedRep__c = :t.OwnerId];
    
    if (t.Type__c == 'Submit'){
        
        //Get actual picklist values for Type__c 
        Schema.Describefieldresult DS_Picklist_Field = Daily_Summary__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> list_DS_Picklist = DS_Picklist_Field.getPicklistValues();
        
        List<String> list_types = new List<String>();  /* list_types - contains all Types for Daily Summary */
        Date mindate = date.newinstance(9999,12,31);   /* mindate - Lowest Date to process */
        Date maxdate = date.newInstance(1900, 1, 1);   /* maxdate - Highest date to process */
        Map<Date,Integer> map_month_sum_counter = new Map<Date,Integer>(); /* map_month_sum_counter - total quartes off per month */
        Boolean without_open=false;
        //Fill list_type from picklist
        for (Schema.PicklistEntry p:list_DS_Picklist)
            list_types.add(p.getLabel());
        Map<date,Map<String,Integer>> map_type_count_month = new Map<date,Map<String,Integer>>(); /* map_type_count_month - counted values per Date and type */
        list<Time_off_Territory__c> list_To_Lock = new list<Time_off_Territory__c>();
        
        //User did a submit and we have to get all open time off territory up to given end date
        for(Time_off_Territory__c [] ToT_User:[Select All_Day__c, Id, OwnerId, Start_Date__c, End_Date__c, Type_First_Quarter__c, Type_Second_Quarter__c, Type_Third_Quarter__c, Type_Fourth_Quarter__c, Type__c 
                                               from Time_off_Territory__c  
                                               where OwnerId = :t.OwnerId and Type__c='Open' and End_Date__c <= :t.End_Date__c]){
            Integer counter; /* counter - counts types per quarter */
            map_type_count_month.clear();
            map_month_sum_counter.clear();
            
            for (Time_off_Territory__c ToT: ToT_User){
                ToT.RecordTypeId =Utilities.getRecordTypeId('Time_off_Territory__c', 'Time_Off_Locked');
                ToT.Type__c='Closed';
                list_To_Lock.add(ToT);
                Map<String,Integer> map_type_count = new Map<String,Integer>(); /* map_type_count - counted values per type*/
                
                //Lowest start date for selected data
                if (mindate > ToT.Start_Date__c){
                    mindate = date.newInstance(ToT.Start_Date__c.year(), ToT.Start_Date__c.month(), 1);
                }
                
                //Highest end date for selected data (must not be end date of trigger)
                if (maxdate < ToT.End_Date__c)
                    maxdate = ToT.End_Date__c;
            
                //it is possible to have more than one day per selected data
                system.debug('Start' + ToT.Start_Date__c);
                system.debug('Ende' + ToT.End_Date__c);
                for (Date dat = ToT.Start_Date__c ; dat <= ToT.End_Date__c ; dat = dat.addDays(1)){
                    date actualmonth=date.newinstance(dat.year(),dat.month(),1);
                    Integer sumcounter = 0; /* sumcounter - store number of quarter*/
                    
                    //Initializing map_type_count
                    if(map_type_count_month.containsKey(actualmonth)){
                        Map<String,Integer> tmp_map= new Map<String,Integer>(map_type_count_month.get(actualmonth));
                        map_type_count=tmp_map.clone();
                    }
                    else
                        for (String p:list_types)
                            map_type_count.put(p, 0);
                    
                    //Is All Day checked
                    if (ToT.All_Day__c){
                        if (map_type_count.containsKey(ToT.Type_First_Quarter__c))
                            counter = map_type_count.get(ToT.Type_First_Quarter__c);
                        else
                            counter=0;
                        counter += 4;
                        sumcounter=4;
                        map_type_count.put(ToT.Type_First_Quarter__c,counter);
                        
                    }
                    else
                    {
                        sumcounter=0;
                        if (map_type_count.containsKey(ToT.Type_First_Quarter__c))
                            counter = map_type_count.get(ToT.Type_First_Quarter__c);
                        else
                            counter=0;
                        counter += 1;
                        if (ToT.Type_First_Quarter__c != null){
                            map_type_count.put(ToT.Type_First_Quarter__c,counter);
                            sumcounter +=counter;
                        }
                        if (map_type_count.containsKey(ToT.Type_Second_Quarter__c))
                            counter = map_type_count.get(ToT.Type_Second_Quarter__c);
                        else
                            counter=0;
                        counter += 1;
                        if (ToT.Type_Second_Quarter__c != null){
                            map_type_count.put(ToT.Type_Second_Quarter__c,counter);
                            sumcounter +=counter;
                        }
                        if (map_type_count.containsKey(ToT.Type_Third_Quarter__c))
                            counter = map_type_count.get(ToT.Type_Third_Quarter__c);
                        else
                            counter=0;
                        counter += 1;
                        if(ToT.Type_Third_Quarter__c != null){
                            map_type_count.put(ToT.Type_Third_Quarter__c,counter);
                            sumcounter +=counter;
                        }
                        if (map_type_count.containsKey(ToT.Type_Fourth_Quarter__c))
                            counter = map_type_count.get(ToT.Type_Fourth_Quarter__c);
                        else
                            counter=0;
                        counter += 1;
                        if(ToT.Type_Fourth_Quarter__c!=null){
                            map_type_count.put(ToT.Type_Fourth_Quarter__c,counter);
                            sumcounter +=counter;
                        }
                    }
                system.debug('Sumcounter '+sumcounter);
                    //total quarters per month (used to calculate what is to be substracted from workung days to get On Territory)
                    if (map_month_sum_counter.get(actualmonth)!=null)
                        sumcounter = map_month_sum_counter.get(actualmonth);
                    map_month_sum_counter.put(actualmonth,sumcounter);
                    
                    
                    //store quarters per month and type
                    map_type_count_month.put(actualmonth,map_type_count);
                    

                }//End of Day
            }    //End of single ToT
        }        //End of all user open ToT

        //Only Submit without new open off times?

        //possible days on Territory for month
        Map<Integer,Integer> map_workingday = new Map<Integer,Integer>(); /* map_workingday - working days per month */
        date newmonth=t.End_Date__c.addDays(1);
        //Only Submit without new open off times?
        list<date> list_last_submit=new list<date>();
        for (Daily_Summary__c date1:[Select d.Last_Submit_Date__c from Daily_Summary__c d  where ownerid=:t.OwnerId order by Last_Submit_Date__c desc])
            list_last_submit.add(date1.Last_Submit_Date__c);
        if (mindate == date.newinstance(9999,12,31)){
            integer year;
            integer month;
            if (list_last_submit.size() > 0){
                year=list_last_submit[0].year();
                month=list_last_submit[0].month();
            }
            else{
                year=t.End_Date__c.year();
                month=t.End_Date__c.month();
            }
            mindate = date.newinstance(year,month,1);
            without_open=true;
        }

        
        //count working days between first day of startdate month and end date given by trigger
        for (Date d=mindate;d<newmonth;d = d.addDays(1)){
            integer wd_month=d.month(); /* wd_month - month for workingday calculation */
            integer count = 0; /* count - counter for working days */
            
            //do we have weekend
            if (!Utilities.isSaturday(d) && !Utilities.isSunday(d) ){
                if (map_workingday.get(wd_month) == null){
                    count=0;
                }
                else{
                    count=map_workingday.get(wd_month);
                }
                // add day
                count++;
                // store day 
                map_workingday.put(wd_month,count);
            }
        }
        if (without_open)
            maxdate=t.End_Date__c;
        
        integer year_loop=mindate.year(); /* year_loop - starting year */
        list<Daily_Summary__c> list_updateDS = new  list<Daily_Summary__c>(); /* list_updateDS - list for Update Daily Summary */
        list<Daily_Summary__c> list_insertDS = new  list<Daily_Summary__c>(); /* list_insertDS - list for Insert Daily Summary */
        
        //Process per month
        system.debug('Mindate: '+mindate);
        system.debug('Maxdate: '+maxdate);

        
        for (Integer a=mindate.month();a<=maxdate.month();a++){
            //Has year changed ?
            if (a>12){
                a=0;
                year_loop++;
            }
    system.debug('loop Month' + a);
            Date beginn_date=date.newInstance(year_loop, a, 1); /* beginn_date - for select of calls*/
            Date end_date=beginn_date.addMonths(1); /* end_date - for select of calls*/
            
            //Get number of calls for Owner and given Month
            Integer calls=[Select count() from Call_Report__c where ownerid=:t.ownerid and Type__c='1:1' and CallDate__c >= :beginn_date and CallDate__c <= :t.End_date__c];
            Map<String,Daily_Summary__c> map_DS_value = new Map<String,Daily_Summary__c>(); /* map_DS_value - daily summary values depending on Type*/
            //select Daily Summary for user and month
            for (Daily_Summary__c DailySummary :[Select  Id, Calls__c,  Days__c,  Last_Submit_Date__c,  Medical_Rep__c,  Month__c,  OwnerId,  Type__c from Daily_Summary__c where OwnerId=:t.OwnerId and Month__c = :beginn_date]){
                map_DS_value.put(DailySummary.Type__c,DailySummary);
                
            }
            Map<String,Integer> map_type_count = new Map<String,Integer>(); /* map_type_count - counted values per type*/
            
            //copy counted values depending on month
            Decimal offday = 0.00;
            if (!without_open){
                map_type_count.putall(map_type_count_month.get(beginn_date));
                offday=(map_month_sum_counter.get(beginn_date));
            }
            offday = offday.divide(4,2); //offday are only new values
            //getting old off days stored on Daily_Summary__c
            decimal storedDays = 0.00;
            for (String p:list_types){
                    Daily_Summary__c actualDS = new Daily_Summary__c();
                    actualDS = map_DS_value.get(p);
                    if (actualDS != null && p != 'On Territory')
                        storedDays += actualDS.Days__c;
            }
            system.debug('stored days at the moment '+ storedDays);
            system.debug('offdays '+ offday);
            system.debug('Workingday '+ map_workingday.get(a));
            decimal workingday = map_workingday.get(a)- offday - storedDays;
            system.debug('Workingday without timeoff'+ workingday);

            
            
            Decimal DayForQuarter= 0;
            //DayForQuarter.scale(2);
            for (String p:list_types){
                Daily_Summary__c DS2Insert = new Daily_Summary__c(); /* DS2Update - store data for Daily Summary before putting to list */
                Daily_Summary__c DS2Oldvalue = new Daily_Summary__c(); /* DS2Oldvalue - store actual data from Daily Summary */
        
                DS2Oldvalue = map_DS_value.get(p);

                if (DS2Oldvalue == null){
                    //No existing record at SFDC
                    if (p=='On Territory'){
                        DS2Insert.Calls__c=calls;
                        DS2Insert.Days__c=workingday;               
                    }
                    else{
                        if (!without_open){
                            DayForQuarter=Map_type_count.get(p);
                            DayForQuarter=DayForQuarter.divide(4,2);
                            DS2Insert.Days__c=DayForQuarter;
                        }
                    }
                    DS2Insert.Last_Submit_Date__c=t.End_Date__c;
                    DS2Insert.Medical_Rep__c=t.OwnerId;
                    DS2Insert.Month__c=beginn_date;
                    DS2Insert.OwnerId=t.OwnerId;
                    if (list_target.size() > 0)
                        DS2Insert.Target__c = list_target[0].Id;
                    DS2Insert.Type__c=p;
                    if (DS2Insert.Days__c!=0&& DS2Insert.Days__c!=null)
                         list_insertDS.add(DS2Insert);
                    
                }
                else{
                    //Record exist on SFDC
                    if (p=='On Territory'){                 
                        DS2Oldvalue.Calls__c=calls;
                        DS2Oldvalue.Days__c=workingday;
                    }
                    else{
                        if (!without_open){
                            DayForQuarter=map_type_count.get(p);
                            DayForQuarter=DayForQuarter.divide(4,2);
                            DS2Oldvalue.Days__c = DS2Oldvalue.Days__c + DayForQuarter;
                        }
                    }
                    DS2Oldvalue.Month__c=beginn_date;
                    DS2Oldvalue.Last_Submit_Date__c=t.End_Date__c;
                    if (DS2Oldvalue.Days__c!=0 && DS2Oldvalue.Days__c!=null)
                        list_updateDS.add(DS2Oldvalue);
                    
                }
            }//end of loop type

        }   
        system.debug('Insert:' + list_insertDS);
        system.debug('Update:' + list_updateDS);
        system.debug('Update Lock:' + list_To_Lock);
        if (list_insertDS != null)
            insert list_insertDS;
        if (list_updateDS != null)
            update list_updateDS;
        update list_To_Lock;
    }//End of Type Submit
}