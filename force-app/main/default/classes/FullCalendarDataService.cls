global class FullCalendarDataService {         
    
    private static String getSOQLQuery(){
        return 'SELECT Id,Name, Sequence__c, Class__c, Session_Date__c, Start_Time__c, End_Time__c, ID__c, Teacher__c,Teacher__r.Name, Status__c,Event_Color__c  FROM Session__c WHERE Status__c != \'Canceled\' AND ';
    }
    
    /**
    Name        :   fetchSessions
    Date        :   19 Feb 2020
    Description :   Function is use for to get current sessions records based on teacher Id
    Developer   :   
    */
    @RemoteAction
    global static SessionRecordModel fetchSessions(String selectedTeacher, String selectedLocation, String selectedClass, String selectedCourse){       
       	system.debug('selectedClass '+selectedClass);
        List<Session__c> sessionList = new List<Session__c>();         
        String query = getSOQLQuery();
        if(selectedTeacher == 'All_Teachers'){            
           query += ' Session_Date__c = TODAY AND Teacher__r.location__c =: selectedLocation ';
        }else{          
            query += ' teacher__c =: selectedTeacher AND Session_Date__c = TODAY ';   
        }      
        if(String.isNotBlank(selectedClass) && selectedClass != 'All_Class'){
             query += ' AND Class__c IN ('+ selectedClass+') ' ;
        }
        if(String.isNotBlank(selectedCourse) && selectedCourse != 'All_Courses' && String.isBlank(selectedClass)){
             sessionList = new List<Session__c>();
        }else{
             sessionList = Database.query(query);
        }      
        return getSessionData(selectedTeacher, selectedLocation, sessionList);
    }
    
    /**
    Name        :   SessionRecordModel
    Date        :   20 Feb 2020
    Description :   Function is use for to get sessions records based on teacher Id and selected Date
    Developer   :   
    */
    @RemoteAction
    global static SessionRecordModel fetchSessionsByDate(String selectedTeacher, String selectedLocation, String selectedDate, String selectedClass, String selectedCourse){        
        system.debug('selectedClass '+selectedClass);
        List<Session__c> sessionList = new List<Session__c>();  
        String query = getSOQLQuery();
        if(String.isNotBlank(selectedDate)){     
            date selectDate = date.valueOf(selectedDate);            
            if(selectedTeacher == 'All_Teachers'){                
                query += ' Session_Date__c =: selectDate AND Teacher__r.location__c =: selectedLocation ';
            }else{                
                query += ' teacher__c =: selectedTeacher AND Session_Date__c =: selectDate ';   
            }
            
            if(String.isNotBlank(selectedClass) && selectedClass != 'All_Class'){
                query += 'AND Class__c IN ('+ selectedClass+')' ;
            }
            if(String.isNotBlank(selectedCourse) && selectedCourse != 'All_Courses' && String.isBlank(selectedClass)){
                sessionList = new List<Session__c>();
            }else{
                sessionList = Database.query(query);
            }      
            system.debug('query '+query);
            //sessionList = Database.query(query);
        }            
        return getSessionData(selectedTeacher, selectedLocation, sessionList);
    }
    
    /**
    Name        :   fetchSessionsByWeek
    Date        :   20 Feb 2020
    Description :   Function is use for to get sessions records based on teacher Id and date ranage
    Developer   :   
    */
    @RemoteAction
    global static SessionRecordModel fetchSessionsByWeek(String selectedTeacher, String selectedLocation, String startDate, String endDate, String selectedClass, String selectedCourse){        
        system.debug('selectedClass '+selectedClass);
        List<Session__c> sessionList = new List<Session__c>();        
        String query = getSOQLQuery();
        if(String.isNotBlank(startDate) && String.isNotBlank(endDate)){                
            date startDt = date.valueOf(startDate);  
            date endDt = date.valueOf(endDate);            
            if(selectedTeacher == 'All_Teachers'){               
                 query += ' Session_Date__c >=: startDt AND  Session_Date__c <=: endDt AND Teacher__r.location__c =: selectedLocation ';
            }else{               
                 query += ' teacher__c =: selectedTeacher AND Session_Date__c >=: startDt AND  Session_Date__c <=: endDt ';   
            }                  
             if(String.isNotBlank(selectedClass) && selectedClass != 'All_Class'){
                query += 'AND Class__c IN ('+ selectedClass+')' ;
            }
            if(String.isNotBlank(selectedCourse) && selectedCourse != 'All_Courses' && String.isBlank(selectedClass)){
                sessionList = new List<Session__c>();
            }else{
                sessionList = Database.query(query);
            }      
            system.debug('query '+query);
            //sessionList = Database.query(query);
        }            
        return getSessionData(selectedTeacher, selectedLocation, sessionList);
    }
    
    /**
    Name        :   getSessionData
    Date        :   21 Feb 2020
    Description :   Function is use for to get sessions records
    Developer   :   
    */
    public static SessionRecordModel getSessionData(String selectedTeacher, String selectedLocation, List<Session__c> sessionList){
        SessionRecordModel sessionModelObj = new SessionRecordModel();                             
        if(sessionList.size() > 0){           
            sessionModelObj.locationId = selectedLocation;
            sessionModelObj.teacherId = selectedTeacher;
            sessionModelObj.sessionModelList = sessionList;   
        }         
        return sessionModelObj;
    }
    
    /**
    Name        :   getWorkingHours
    Date        :   22 Feb 2020
    Description :   Function is use for to get working hours of current location
    Developer   :   
    */
    @RemoteAction
    global static List<Location_Working_Hours__c> getWorkingHours(String locationId){
        List<Location_Working_Hours__c> workingHourList = new List<Location_Working_Hours__c>();
        if(String.isNotBlank(locationId)){
            for(Location_Working_Hours__c wokObj : [SELECT Id, Name, Day__c, Start_Time__c, End_Time__c, Active__c, Location__c FROM Location_Working_Hours__c WHERE location__c =: locationId]){
                if(wokObj.Active__c == true){
                    workingHourList.add(wokObj);
                }
            }
        }
        return workingHourList;
    }
    
    /**
    Name        :   getSessionResources
    Date        :   25 Feb 2020
    Description :   
    Developer   :   
    */
    @RemoteAction
    global static SessionRecordModel getSessionResources(String resourceId, String selectedLocation, String teacherId, String startDate, String resourceType ){
        String query = 'SELECT Id, Name,Resource__c, Resource__r.Name,Session__r.Name, Session__r.Start_Time__c, Session__r.Session_Date__c, Session__r.End_Time__c, Session__r.Event_Color__c, Session__r.Teacher__r.Name FROM Session_Resource__c WHERE ';
        List<Session_Resource__c> sessionResList = new List<Session_Resource__c>();
        SessionRecordModel sessionModelObj = new SessionRecordModel();          
        if(String.isNotBlank(resourceId)){
            date startDt = date.valueOf(startDate);  
            system.debug(' startDt  '+startDt);
            system.debug(' selectedLocation  '+ selectedLocation);
            system.debug('teacherId '+teacherId);
            query += 'Resource__r.Id IN ('+resourceId+') AND Session__r.Teacher__r.location__c =: selectedLocation AND Session__r.Session_Date__c =: startDt ';
            if(String.isNotBlank(teacherId) && teacherId != 'All_Teachers'){
                query += 'AND Session__r.teacher__c =: teacherId ';
            }
            if(String.isNotBlank(resourceType)  && resourceType != 'All_Resources_Type'){
                 query += 'AND Resource__r.type__c =: resourceType';            
            }
            system.debug('query  -- '+query);
            sessionResList = Database.query(query);
            if(sessionResList.size() > 0){
                sessionModelObj.locationId = selectedLocation;
                sessionModelObj.teacherId = teacherId;
                sessionModelObj.sessionResourceModelList = sessionResList;   
            }
        }
        return sessionModelObj;
    }
    
    @RemoteAction
    global static SessionRecordModel getSessionResourcesByWeek(String selectedLocation, String selectedTeacher, String resourceId, String startDate, String endDate, String resourceType){
        String query = 'SELECT Id, Name,Resource__c, Resource__r.Name, Session__r.Name, Session__r.Start_Time__c, Session__r.End_Time__c, Session__r.Session_Date__c, Session__r.Event_Color__c, Session__r.Teacher__r.Name FROM Session_Resource__c WHERE ';
        List<Session_Resource__c> sessionResList = new List<Session_Resource__c>();
        SessionRecordModel sessionModelObj = new SessionRecordModel();     
        date startDt = date.valueOf(startDate);  
        date endDt = date.valueOf(endDate);  
        system.debug(' startDt  '+startDt);
        system.debug(' selectedLocation  '+ selectedLocation);
        system.debug('teacherId '+selectedTeacher);
        if(String.isNotBlank(resourceId) && String.isNotBlank(startDate) && String.isNotBlank(endDate) && String.isNotBlank(selectedLocation) && String.isNotBlank(selectedTeacher)){  
        	 query += 'Resource__r.Id IN ('+resourceId+') AND Session__r.Teacher__r.location__c =: selectedLocation AND  Session__r.Session_Date__c >=: startDt AND Session__r.Session_Date__c <=: endDt ';
        	if(String.isNotBlank(selectedTeacher) && selectedTeacher != 'All_Teachers'){
                query += 'AND Session__r.teacher__c =: selectedTeacher ';
            }
            if(String.isNotBlank(resourceType) && resourceType != 'All_Resources_Type'){
                 query += 'AND Resource__r.type__c =: resourceType';            
            }
            sessionResList = Database.query(query);
            if(sessionResList.size() > 0){
                sessionModelObj.locationId = selectedLocation;
                sessionModelObj.teacherId = selectedTeacher;
                sessionModelObj.sessionResourceModelList = sessionResList;   
            }
            system.debug('query  -- '+query);
        }
        return sessionModelObj;
    }
    
    @RemoteAction
    global static List<Teacher_Working_Hours__c> getTeacherWorkingHours(String locationId){
        List<Teacher_Working_Hours__c> teacherWorkingHourList = new List<Teacher_Working_Hours__c>();
        if(String.isNotBlank(locationId)){
            for(Teacher_Working_Hours__c teacherObj : [Select id,start_time__c,end_time__c,location__c,teacher__c,Day__c from Teacher_Working_Hours__c WHERE location__c =: locationId AND is_Active__c  = true ]){
                teacherWorkingHourList.add(teacherObj);               
            }
        }
        return teacherWorkingHourList;
    }
    
   @RemoteAction
    global static void setNewSessionTiming(Id recId, String parentId, String newStartTime, String currentDate){
        system.debug('recId  '+recId);
        Session__c sessionObj;
        List<Session_Resource__c> sessionResList = new List<Session_Resource__c>();
        if(String.isNotBlank(recId)){
            String sObjName = recId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Session__c'){
                sessionObj = new Session__c(id = recId);
                if(String.isNotBlank(parentId)){
                    sessionObj.Teacher__c = parentId;
                }
            }else if(sObjName == 'Session_Resource__c'){
                sessionResList = [SELECT id,Session__r.id,Resource__c FROM Session_Resource__c WHERE id =: recId LIMIT 1];  
                system.debug('sessionResObj.Session__r.Id->'+sessionResList[0].Session__r.Id);
                if(sessionResList.size() > 0){
                    sessionObj = new Session__c(Id = sessionResList[0].Session__r.Id);
                    if(String.isNotBlank(parentId)){
                        sessionResList[0].Resource__c = parentId;
                    }   
                }               
            }
            String[] strTimeSplit = newStartTime.split(':');
            Time startTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                               ,Integer.valueOf(strTimeSplit[1]) //min
                                               ,Integer.valueOf(strTimeSplit[2]) //sec
                                               ,0);    
            sessionObj.Start_Time__c = startTime; 
            sessionObj.Session_Date__c = date.valueOf(currentDate);
            try{
                update sessionObj;
                if(sObjName == 'Session_Resource__c' && sessionResList.size() > 0){
                    update sessionResList;
                }
            }catch(Exception ex){
                system.debug('Error--> '+ ex.getMessage() +' ---- '+ ex.getLineNumber());
            }
        }
    }
    /**
    Name        :   
    Date        :   05 Mar 2020
    Description :   
    Developer   :   
    */
    @RemoteAction
    global static void setNewTimeForAllSession(String sessionId, String newStartTime){
        if(String.isNotBlank(sessionId)){
            List<Session__c> sessionList = [SELECT Id, Teacher__c, Teacher__r.location__c, Session_Date__c, Start_Time__c FROM Session__c WHERE id =: sessionId];
            sessionList =  [SELECT Id, Start_Time__c FROM Session__c 
                            WHERE Teacher__c =: sessionList[0].Teacher__c AND 
                            Teacher__r.location__c =: sessionList[0].Teacher__r.location__c AND
                            Session_Date__c >=: sessionList[0].Session_Date__c AND 
                            Start_Time__c =: sessionList[0].Start_Time__c];
            
            String[] strTimeSplit = newStartTime.split(':');
            Time startTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                              ,Integer.valueOf(strTimeSplit[1]) //min
                                              ,Integer.valueOf(strTimeSplit[2]) //sec
                                              ,0);  
            
            for(Session__c sessionObj : sessionList){
                sessionObj.Start_Time__c = startTime; 
            }
            
            try{
                update sessionList;                                 
            }catch(Exception ex){
                system.debug('Error--> '+ ex.getMessage() +' ---- '+ ex.getLineNumber());
            }
        }
    }
    
    /**
    Name        :   setNewDateTimeForCurrentAndUpComingSession
    Date        :   09 Mar 2020
    Description :   
    Developer   :   
    */
    @RemoteAction 
    global static void setNewDateTimeForCurrentAndUpComingSession(String sessionId, String newStartTime,  Integer dayDiffernce, Integer previousDay){
        if(String.isNotBlank(sessionId)){
            
             system.debug('sessionId  '+sessionId);
            system.debug('newStartTime  '+newStartTime);
            system.debug('dayDiffernce  '+dayDiffernce);
            system.debug('previousDay  '+previousDay);
            
            List<Session__c> sessionList = [SELECT Id, Teacher__c, Teacher__r.location__c, Session_Date__c, Start_Time__c FROM Session__c WHERE id =: sessionId];
            
            sessionList =  [SELECT Id, Start_Time__c,Session__c.Session_Date__c FROM Session__c 
                            WHERE Teacher__c =: sessionList[0].Teacher__c AND 
                            Teacher__r.location__c =: sessionList[0].Teacher__r.location__c AND
                            Session_Date__c >=: sessionList[0].Session_Date__c AND 
                            Start_Time__c =: sessionList[0].Start_Time__c AND
                            DAY_IN_WEEK(Session_Date__c) =: previousDay+1];
            
            if(sessionList.size() > 0){
                string[] strTimeSplit = newStartTime.split(':');
                Time startTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                  ,Integer.valueOf(strTimeSplit[1]) //min
                                                  ,Integer.valueOf(strTimeSplit[2]) //sec
                                                  ,0);  
                
                for(Session__c sessionObj : sessionList){
                    sessionObj.Start_Time__c = startTime; 
                    Date currentDate = sessionObj.Session_Date__c;
                    sessionObj.Session_Date__c = currentDate.addDays(dayDiffernce);
                }  
                
                try{
                    update sessionList;                                 
                }catch(Exception ex){
                    system.debug('Error--> '+ ex.getMessage() +' ---- '+ ex.getLineNumber());
                }
            }
            
        }
    }
    
   @RemoteAction
    global static void rescheduleSessionForStudent(String studentId, String newSessionId){
        if(String.isNotBlank(studentId) && String.isNotBlank(newSessionId)){
            Student_Session__c studentSessionObj = new Student_Session__c(id = studentId, session__c = newSessionId);
            try{
                update studentSessionObj;
            }catch(Exception ex){
                system.debug('Error--> '+ ex.getMessage() +' ---- '+ ex.getLineNumber());
            }
            
        }
    }
    
    /**
    Name        :   studentIsExistsForSession
    Date        :   11 Mar 2020
    Description :   
    Developer   :   
    */
     @RemoteAction
    global static boolean studentIsExistsForSession(String sessionId, String studentId){
        //query on student session and get id of Student(Account) based on session Id
        //check studentId to Account so we can find out that student is already exists or not
        if(String.isNotBlank(sessionId) && String.isNotBlank(studentId)){
            List<Student_session__c> stuSessionList = [SELECT Id, Account__c, Session__c FROM Student_session__c WHERE Session__c =: sessionId];
            if(stuSessionList.size() > 0){
                for(Student_session__c sobj : stuSessionList){
                    if(sobj.Account__c == studentId){
                        return true;
                    }
                }
            }
        }
        return false;      
    }
    /**
    Name        :   updateStudenSessionsInAllSessions
    Date        :   11 Mar 2020
    Description :   
    Developer   :   
    */
    @RemoteAction
    global static void updateStudenSessionsInAllSessions(Integer oldDay, Integer newDay, String accId){               
        List<student_session__c> sessionList = [SELECT id,Name,Session__r.session_date__c FROM student_session__c WHERE DAY_IN_WEEK(Session__r.session_date__c) =: oldDay+1 AND account__c =: accId];
        Map<String,Id> newSessionResMap = new Map<String,Id>();
        for(student_session__c sobj : [SELECT id,Name,Session__r.session_date__c FROM student_session__c WHERE DAY_IN_WEEK(Session__r.session_date__c) =: newDay+1 AND account__c =: accId]){
            newSessionResMap.put(sobj.Session__r.session_date__c+'', sobj.Session__c);
        }
        Integer dayDiffernce = newDay - oldDay;
        for(student_session__c sessionObj : sessionList){
            //Date sessionDate = new Date(sessionObj.Session__r.session_date__c);	
            //sessionObj.Session__r.session_date__c.addDays(dayDiffernce);
            //sessionDate.addDays(dayDiffernce);
            sessionObj.session__c = newSessionResMap.get(sessionObj.Session__r.session_date__c.addDays(dayDiffernce)+'');
        }
        system.debug('sessionList->'+sessionList);
        try{
            update sessionList;
        }catch(Exception ex){
            system.debug('Error--> '+ ex.getMessage() +' ---- '+ ex.getLineNumber());
        }
        //update sessionList;
        
    }
    
    global class SessionRecordModel{
        public String locationId;
        public String teacherId;
        public List<Session__c> sessionModelList; 
        public List<Session_Resource__c> sessionResourceModelList;
    }
}