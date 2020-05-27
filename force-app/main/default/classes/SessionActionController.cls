global class SessionActionController {
    /**
    Name        :   fetchSessionsDetail
    Date        :   03 Mar 2020
    Description :   
    Developer   :   
    */
    @RemoteAction
    global static  List<Session__c> fetchSessionsDetail(String sessionId){ 
    	String query = 'SELECT Id, Teacher__r.location__r.Name, Teacher__r.Name, Class__r.Name, Duration__c, Session_date__c, Start_Time__c FROM Session__c ';
        if(String.isNotBlank(sessionId)){
            query += 'WHERE Id =: sessionId ';
        }
        List<Session__c> sessionList = Database.query(query);
        if(sessionList.size() > 0){
            return sessionList;
        }
        return null;
    }      
    
    @RemoteAction
    global static List<Student_Session__c> getSessionStudent(string sessionId){
        List<Student_Session__c> studentList = new List<Student_Session__c>();
        if(String.isNotBlank(sessionId)){
            studentList = [SELECT Id, Session__r.Teacher__r.Name, Account__r.Name, Session__r.Class__r.Name, Status__c, Notes__c FROM Student_Session__c WHERE Session__c =: sessionId];
            if(studentList.size() > 0){
               return studentList;
            }
        }
        return null;
    }
    
    /**
    Name        :   
    Date        :   04 Mar 2020
    Description :   
    Developer   :   
    */
    @RemoteAction
    global static void changeStudentStatus(String sessionStudentsId,String status){ 
        List<Student_Session__c> studentList = new List<Student_Session__c>();
        if(String.isNotBlank(sessionStudentsId)){
            List<String> ids = sessionStudentsId.split(',');
            for(String strObj : ids){
                Student_Session__c sessionObj = new Student_Session__c(id = strObj);
                if(status == 'Completed'){
                    sessionObj.Status__c = 'Attended';
                }else if(status == 'No-show'){
                    sessionObj.Status__c = 'Not Attended';
                }  
                studentList.add(sessionObj);
            }
            if(studentList.size() > 0){
                try{
                    update studentList;
                }catch(Exception ex){
                    system.debug('Error -> '+ex.getMessage());                   
                }
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
    global static void cancelStudentForSession(String sessionStudentsId){
        if(String.isNotBlank(sessionStudentsId)){
            Student_Session__c sessionStuObj = new Student_Session__c(id = sessionStudentsId);            
            sessionStuObj.status__c = 'Canceled';
            try{
                update sessionStuObj;
            }catch(Exception ex){
                system.debug('Error -> '+ex.getMessage());                   
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
    global static void cancelSession(String sessionId){
        if(String.isNotBlank(sessionId)){
            Session__c sessionObj = new Session__c(id = sessionId);            
            sessionObj.status__c = 'Canceled';
            try{
                update sessionObj;
            }catch(Exception ex){
                system.debug('Error -> '+ex.getMessage());                   
            }
        }
    }
    
     /**
    Name        :   
    Date        :   12 Mar 2020
    Description :   
    Developer   :   
    */
    @RemoteAction
    global static List<SessionHistoryModal> getSessionHistoryRecords(String sessionId){
        List<SessionHistoryModal>  sessionHistoryModalList = new List<SessionHistoryModal>();       
        if(String.isNotBlank(sessionId)){
            for(Session__History sessionHistoryObj : [SELECT Id, ParentId, CreatedBy.Name, CreatedById, CreatedDate, Field, OldValue, NewValue FROM Session__History WHERE ParentId =: sessionId]){
                SessionHistoryModal sessionModalObj = new SessionHistoryModal();
                String description = '';
                sessionModalObj.historyBy = sessionHistoryObj.CreatedBy.Name;
                sessionModalObj.createdDate = sessionHistoryObj.CreatedDate.format('EEE, MMM dd yyyy h:mm a');
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType leadSchema = schemaMap.get('Session__c');
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();                                                                                   
                description += 'Session ';
                if(sessionHistoryObj.Field != 'created'){
                    description +=  fieldMap.get(sessionHistoryObj.Field).getDescribe().getLabel();
                    String[] strTimeSplit;
                    String newTime;
                    description += ' changed from ';                  
                    if(sessionHistoryObj.OldValue instanceOf TIME && sessionHistoryObj.NewValue instanceOf TIME){
                        strTimeSplit = String.valueOf(sessionHistoryObj.OldValue).split(':');
                        newTime = strTimeSplit[0] +':'+strTimeSplit[1] +':00';  
                        description +=  newTime + ' to '; 
                        
                        strTimeSplit = String.valueOf(sessionHistoryObj.NewValue).split(':');
                        newTime = strTimeSplit[0] +':'+strTimeSplit[1] +':00';    
                        description +=  newTime; 
                    }else if(sessionHistoryObj.OldValue instanceOf date && sessionHistoryObj.NewValue instanceOf date){
                        description += Date.valueOf(sessionHistoryObj.OldValue).format()+' to '+Date.valueOf(sessionHistoryObj.NewValue).format();
                    }else{
                         description += sessionHistoryObj.OldValue+' to '+sessionHistoryObj.NewValue;
                    }                   
                }else{
                    description += sessionHistoryObj.Field;
                }
                sessionModalObj.description = description;
                sessionHistoryModalList.add(sessionModalObj);
            }           
        }
        return sessionHistoryModalList;
    }
    /**
    Name        :   
    Date        :   13 Mar 2020
    Description :   
    Developer   :   
    */
    @RemoteAction
    global static List<Account> getStudentRecords(String keywordToSearch){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        system.debug('devRecordTypeId '+devRecordTypeId);
        String query = 'SELECT Id, Name, PersonEmail, Phone FROM Account WHERE  recordtype.Id =: devRecordTypeId';
        if(String.isNotBlank(keywordToSearch)){
            query += ' AND Name like  \'%' + keywordToSearch + '%\'';
        }else{
            query += ' LIMIT 5';
        }
        system.debug('query '+query);
        List<Account> accList = Database.query(query);
        system.debug('accList->' +accList);
        if(accList.size() > 0){
            return accList;
        }
        return null;
    }
    
    
    global class SessionHistoryModal{
        public String createdDate;           
        public String historyBy;        
        public String description;        
    }
}