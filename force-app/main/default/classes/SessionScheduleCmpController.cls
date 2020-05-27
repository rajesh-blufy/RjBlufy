public class SessionScheduleCmpController {
    
	@auraEnabled
    public static List<sessionWrapper> generateSession(String clsTermId){
        List<Class_Term__c> clsTermList = [SELECT Id, Name, Class__c, Class__r.Name, Class__r.Teacher__c, Class__r.Teacher__r.Name, Start_Date__c, 
                                          Class__r.Start_Time__c, Class__r.End_Time__c, Class__r.Days_of_Week__c, Sessions__c, Class__r.Duration__c 
                                  		  FROM Class_Term__c WHERE Id=:clsTermId AND Status__c='Draft' LIMIT 1];
        List<sessionWrapper> sessList  = new List<sessionWrapper>();
        
        if(clsTermList.size() > 0){
            Class_Term__c clsTrm = clsTermList.get(0);
            
            Map<Date, Teacher_Leave__c> tchrLeaveMap = new Map<Date, Teacher_Leave__c>();
            for(Teacher_Leave__c tchrLv: [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c 
                                          FROM Teacher_Leave__c WHERE Teacher__c =: clsTrm.Class__r.Teacher__c AND 
                                          Start_Date__c != null AND End_Date__c != null]){
                                              
                for(Date stDt=tchrLv.Start_Date__c; stDt<=tchrLv.End_Date__c; stDt=stDt.addDays(1)){
                	tchrLeaveMap.put(stDt, tchrLv);
                }
            }
            
      List<Date> ListOfHolidays = new List<Date>();
            for (Holiday__c Holidays : [Select Start_Date__c,End_Date__c from Holiday__c]){
                if (Holidays.Start_Date__c!=NULL && Holidays.End_Date__c!=NULL){
                    while (Holidays.Start_Date__c<=Holidays.End_Date__c){
                        ListOfHolidays.add(Holidays.Start_Date__c);
                        Holidays.Start_Date__c=Holidays.Start_Date__c.addDays(1);                       
                    }
                }
                else if (Holidays.End_Date__c==NULL && Holidays.Start_Date__c!=NULL){
                        ListOfHolidays.add(Holidays.Start_Date__c);
                }
            }
            
            DateTime stDate = (DateTime) clsTrm.Start_Date__c;
            Integer i = 1;
            while(i<=clsTrm.Sessions__c){
                if((!ListOfHolidays.contains(stDate.date())) && clsTrm.Class__r.Days_of_Week__c.contains(stDate.format('EEE'))){
                    //sessList.add(fillSession(cls, i, stDate.date()));
                    sessionWrapper sess = new sessionWrapper();
                    sess.seqNo    = i;
                    sess.clsId    = clsTrm.Class__c;
                    sess.clsName  = clsTrm.Class__r.Name;
                    sess.tchrId   = clsTrm.Class__r.Teacher__c;
                    sess.tchrName = clsTrm.Class__r.Teacher__r.Name;
                    sess.status   = 'Scheduled';
                    sess.stDate	  = stDate.date();
                    sess.sessDay  = stDate.format('EEE');
                    sess.stTime   = clsTrm.Class__r.Start_Time__c;
                    sess.duration = clsTrm.Class__r.Duration__c;
                    if(tchrLeaveMap.containsKey(sess.stDate))
                        sess.isOnLeave = true;
                    
                    
                    sessList.add(sess);
                    //sess.Start_Date__c = Datetime.newInstance(dt, cls.Start_Time__c);
                    //sess.End_Date__c = Datetime.newInstance(dt, cls.End_Time__c);
                    
                    i++;	    
                    System.debug('@@@-->'+stDate);
                }
                stDate = stDate.addDays(1);
            }
        }
        
        return sessList;
    }
    
    
    @auraEnabled
    public static void insertSessions (List<sessionWrapper> sessList,Id recordId) {
        List <Session__c> insertSessList = new List<Session__c>();
        for (sessionWrapper sess : sessList){
           	 Session__c session  = new Session__c();
           	 session.Class__c        = sess.clsId;
           	 session.Sequence__c     = sess.seqNo;
           	 session.Teacher__c      = sess.tchrId;
           	 session.Status__c       = sess.status;
           	 session.Session_Date__c = sess.stDate;
        	 session.Duration__c     = sess.duration;
          	 session.Start_Time__c   = sess.stTime;
             session.Class_Term__c   = recordId;
             insertSessList.add(session);
           } 
        
        if (insertSessList.size()>0){ 
            insert insertSessList; 
        }
        
        if(recordId!=null) {
            system.debug('recordId-->'+recordId);
        	Class_Term__c clsTerm = new Class_Term__c();
        	clsTerm.id                                      = recordId;
        	clsTerm.Status__c                               = 'Scheduled';
            clsTerm.Start_Date__c                           = insertSessList[0].Session_Date__c;
            clsTerm.End_Date__c                             = insertSessList[insertSessList.size()-1].Session_Date__c;
            update clsTerm;   
            
            Class__c clsUpd = new Class__c();
            clsUpd.Id                             = insertSessList[0].Class__c;
            clsUpd.Last_Session_Date__c           = insertSessList[insertSessList.size()-1].Session_Date__c; 
            clsUpd.Last_Session_Scheduled_Date__c = Date.today();
            clsUpd.Next_Schedule_Date__c 		  = clsUpd.Last_Session_Date__c.addMonths(-1);
            update clsUpd;
        }             
        
        
        
    } 
    
    public static Session__c fillSession(Class__c cls, Integer seqNo){
        Session__c sess = new Session__c();
        sess.Sequence__c = seqNo;
        sess.Class__c = cls.Id;
        sess.Teacher__c = cls.Teacher__c;
        sess.Status__c = 'Scheduled';
        //sess.Start_Date__c = Datetime.newInstance(dt, cls.Start_Time__c);
        //sess.End_Date__c = Datetime.newInstance(dt, cls.End_Time__c);
        return sess;
    }
    
    public class sessionWrapper{
        @AuraEnabled public Integer seqNo{get;set;}
        @AuraEnabled public String  clsId{get;set;}
        @AuraEnabled public String  clsName{get;set;}
        @AuraEnabled public String  tchrId{get;set;}
        @AuraEnabled public String  tchrName{get;set;}
        @AuraEnabled public String  status{get;set;}
        @AuraEnabled public Date    stDate{get;set;}
        @AuraEnabled public String  sessDay{get;set;}
        //@AuraEnabled public Date    endDate{get;set;}
        @AuraEnabled public Boolean isOnLeave{get;set;}
        @AuraEnabled public Time    stTime{get;set;}
        @AuraEnabled public Decimal duration{get;set;}
        
        public sessionWrapper(){
            isOnLeave = false;
        }
    }
}