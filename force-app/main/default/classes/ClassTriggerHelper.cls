Global class ClassTriggerHelper implements Database.Batchable <sObject> {
    /*
    public static void createSession(Boolean isUpdate, List<Class__c> clsList){
        List<Session__c> sessList  = new List<Session__c>();
        Map<Id, Date>    updClsMap = new Map<Id, Date>();
        for(Class__c cls: clsList){
            DateTime stDate = (DateTime) cls.Start_Date__c;
            Integer i = 1;
            while(i<=cls.Sessions__c){
                if(cls.Days_of_Week__c.contains(stDate.format('EEE'))){
                    sessList.add(fillSession(cls, i, stDate.date()));
                    i++;        
                }
                stDate = stDate.addDays(1);
            }
            Date lastLessDate = stDate.date().addDays(-1);
            if(cls.Last_Session_Scheduled_Date__c == null || cls.Last_Session_Scheduled_Date__c < lastLessDate){
                updClsMap.put(cls.Id, lastLessDate);
            }
        }
        
        if(sessList.size() > 0)
            insert sessList;
        
        if(updClsMap.size() > 0)
            updateLastLessonDate(updClsMap);
    }
    
    private static Session__c fillSession(Class__c cls, Integer seqNo, Date dt){
        Session__c sess = new Session__c();
        sess.Sequence__c = seqNo;
        sess.Class__c = cls.Id;
        sess.Teacher__c = cls.Teacher__c;
        sess.Status__c = 'Scheduled';
        sess.Start_Date__c = Datetime.newInstance(dt, cls.Start_Time__c);
        sess.End_Date__c = Datetime.newInstance(dt, cls.End_Time__c);
        return sess;
    }
    
     @future
    public static void updateLastLessonDate(Map<Id, Date> clsMap){
        List<Class__c> clsList = new List<Class__c>();
        if(clsMap.size() > 0){
            for(String clsId: clsMap.keySet())
                clsList.add(new Class__c(Id = clsId, Last_Session_Scheduled_Date__c = clsMap.get(clsId)));
            
            update clsList;
        }
    }*/
  
    
 //-------   Helper method to create a classTerm when A cLass is created (Mar 4,2020)   -------//
    
    public static void createClassTerm (List<Class__c> ClsList){
        List <Class_Term__c> clsTermlist = new List <Class_Term__c>();
        for (Class__c cls : ClsList){
             if (String.isNotBlank(cls.Name)){
               Class_Term__c clsTerm = new Class_Term__c();
                clsTerm.Class__c=cls.id;
                clsTerm.Name='Term 1';
                clsTerm.Status__c='Draft';
                clsTerm.Start_Date__c=cls.Start_Date__c;  
                clsTerm.Sessions__c=cls.Sessions__c; 
                clsTermlist.add(clsTerm); 
              }
         }
        insert clsTermlist;
    }
    
    //---------------   Batch class for creation of classTerm 2 (Mar 16,2020)   ---------------//
    
    List<Class_Term__c> clsTermList = new List<Class_Term__c>();
	global Database.QueryLocator start(Database.BatchableContext bc) {
	String query = 'SELECT Id, Name FROM Class__c WHERE Id IN(SELECT Class__c FROM Class_Term__c)';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc,List<Class__c> batch) {
        for (Class__c cls : batch) {
            if (String.isNotBlank(cls.Name)){
               Class_Term__c clsTerm  = new Class_Term__c();
                clsTerm.Class__c      = cls.id;
                clsTerm.Name          = 'Term 2';
                clsTerm.Status__c     = 'Draft';
                clsTerm.Start_Date__c = cls.Start_Date__c;  
                clsTerm.Sessions__c   = cls.Sessions__c; 
                clsTermlist.add(clsTerm); 
        	}
        insert clsTermList;
        }
    }
     
    global void finish(Database.BatchableContext bc) {
        
    }
}