global  class FullCalendarController {
    
    public String selectedTeacher{get;set;}
    public String selectedLocation{get;set;}
    public String selectedCourse{get;set;}
    public String selectedResourcesType {get;set;}
    public List<SelectOption> locationList{get;set;}
    public List<SelectOption> teacherList{get;set;}  
    public List<SelectOption> courseList{get;set;}
    public List<SelectOption> classList{get;set;}
    public List<SelectOption> resourcesList{get;set;}
    public List<SelectOption> resourcesTypeList{get;set;}
    public Full_Calendar_Configuration__mdt calendarConfigMetadataObject {get;set;}
    private List<Full_Calendar_Configuration__mdt> calendarConfigMetaList;
    //public List<Account> allTeacherList {get;set;}
    
    public FullCalendarController(){
        locationList  = new list<SelectOption>();
        teacherList   = new list<SelectOption>();
        courseList    = new list<SelectOption>();
        classList     = new list<SelectOption>();
        resourcesList = new list<SelectOption>();
        calendarConfigMetaList = new list<Full_Calendar_Configuration__mdt>();
        resourcesTypeList = new list<SelectOption>();
        
        getFullCalendatMetadata();
        
        populateLocations();
        selectedLocation = locationList.get(0).getValue();   
        
        populateTeachers();   
        selectedTeacher = teacherList.get(0).getValue();
        
        populateCourses();
        selectedCourse = courseList.get(0).getValue();
        populateClasses();
        
        populateResourceType();
        selectedResourcesType = resourcesTypeList.get(0).getValue();
        
        populateResource();
    }
    
    /**
    Name        :   populateTeachers
    Date        :   19 Feb 2020
    Description :   Function is use for to get avaiable accounts records which records type is teacher and have lookup based on Location Id 
    Developer   :   
	*/
    private void populateTeachers(){
        //allTeacherList = new List<Account>();
        teacherList = new List<SelectOption>();
        system.debug('selectedLocation '+selectedLocation);
        teacherList.add( new SelectOption( 'All_Teachers', 'All Teachers'));
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Teacher').getRecordTypeId();            
        for(Account accObj : [SELECT Id,Name FROM Account WHERE recordtype.Id =: devRecordTypeId AND Location__c =: selectedLocation]){
            teacherList.add( new SelectOption( accObj.Id, accObj.name ));
           // allTeacherList.add(accObj);
        }        
        
    }
    
    /**
    Name        :   populateLocations
    Date        :   19 Feb 2020
    Description :   Function is use for to get avaiable accounts records which records type is Location
    Developer   :   
	*/
    private void populateLocations(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();            
        for(Account accObj : [SELECT Id,Name FROM Account WHERE recordtype.Id =: devRecordTypeId]){
            locationList.add( new SelectOption( accObj.Id, accObj.name ));
        }        
        system.debug('locationList->'+locationList.get(0));        
    }
    
    /**
    Name        :   popluateCourses
    Date        :   24 Feb 2020
    Description :   Function is use for to get avaiable courses from course object
    Developer   :   
	*/
    private void populateCourses(){
         courseList.add(new SelectOption('All_Courses', 'All Courses'));
        for(Course__c courObj : [SELECT Id, Name FROM Course__c WHERE Status__c = 'Active']){
            courseList.add(new SelectOption(courObj.Id, courObj.Name));
        }
    }
    
    /**
    Name        :   populateClasses
    Date        :   24 Feb 2020
    Description :   Function is use for to get avaiable Classes from Class object
    Developer   :   
	*/
    private void populateClasses(){
        classList  = new list<SelectOption>();
        classList.add(new SelectOption('All_Class', 'All Class'));
        String query = 'SELECT Id, Course__c, Name, Teacher__c FROM Class__c WHERE ';
        if(String.isNotBlank(selectedCourse) && selectedCourse != 'All_Courses'){
         	   query += ' Course__c =: selectedCourse AND ';
        }
        query += ' Location__c =: selectedLocation';
        for(Class__c classObj : Database.query(query)){
            classList.add(new SelectOption(classObj.Id, classObj.Name));
        }
    }
    
    /**
    Name        :   populateClasses
    Date        :   21 Feb 2020
    Description :   Function is use for to refresh the teacher list when location is changed
    Developer   :   
	*/
    public void refreshFilters(){
        populateTeachers();
        selectedTeacher = teacherList.get(0).getValue();
        populateClasses();
        
        populateResource();        
        system.debug('selectedLocation'+selectedLocation);
    }
    
    /**
    Name        :   getTodayDate
    Date        :   19 Feb 2020
    Description :   Function is use for to get currrent date for full calendar
    Developer   :   
	*/
    public String getTodayDate(){
        Datetime myDT = Datetime.now();
        return myDT.format('YYYY-MM-dd');       
    }  
    
    private void populateResourceType(){
        Schema.DescribeFieldResult fieldResult = Resource__c.Type__c.getDescribe();
        resourcesTypeList.add(new SelectOption('All_Resources_Type','All Resources Type'));
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            resourcesTypeList.add(new SelectOption(pickListVal.getLabel(), pickListVal.getValue()));
        } 
    }
    
    private void populateResource(){
        resourcesList = new List<SelectOption>();
        String query = 'SELECT Id,Name FROM Resource__c WHERE ';
        if(String.isNotBlank(selectedResourcesType) && selectedResourcesType != 'All_Resources_Type'){
         	   query += ' Type__c =: selectedResourcesType AND ';
        }
        query += ' Location__c =: selectedLocation';
        resourcesList.add(new SelectOption('All_Resources', 'All Resources'));
        for(Resource__c resObj : Database.query(query)){
            resourcesList.add(new SelectOption(resObj.id, resObj.Name));
        }
    }
    
    public void refreshResources(){
        populateResource();       
    }
    
    public void refreshClasses(){
        populateClasses();
    }
    
    private void getFullCalendatMetadata(){
        calendarConfigMetaList = [SELECT Mode_Button_Color__c,Scheduler_License_Key__c, Selected_Mode_Button_Color__c, Selected_View_Button_Color__c, View_Button_Color__c,Non_Business_Hours_Color__c, Modal_Header_Footer_Color__c FROM Full_Calendar_Configuration__mdt];       
    	calendarConfigMetadataObject = calendarConfigMetaList.get(0);
        system.debug('calendarConfigMetaList  -> '+calendarConfigMetaList);
    }
}