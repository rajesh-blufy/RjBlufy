@isTest
private class TestClassTrigger {
	static testmethod void validateTestCreateClsTermOnClass(){
        Course__c course=new Course__c();
        course.Name='Course Test';
        course.Status__c='Draft';
        system.debug('course-->'+course);        
         
        Account tch = new Account();
        tch.RecordTypeId = '0122v000000kAeTAAU';
        tch.LastName     = 'Test';
        system.debug('Account-->'+tch);
        
    	Class__c cls = new Class__c();
    	cls.Name             = 'Test';
    	cls.Course__c        = course.Id;
    	cls.Format__c        = 'Online';
    	cls.Status__c        = 'Draft';
    	cls.Teacher__c       = tch.Id;
        cls.Capacity__c      = 15;
        cls.Type__c          = 'Fixed';
        cls.Sessions__c		 = 2;
        cls.Start_Date__c    = Date.today()+1;
        cls.Days_of_Week__c  = 'Fri';
        cls.Start_Time__c    = Time.newInstance(4,4,5,6);
        cls.Duration_Unit__c = 'Hours';
        cls.Duration__c      = 4;
        insert cls;
        system.debug('Cls-->'+cls);
        
        Class_Term__c clsTerm = new Class_Term__c();
        clsTerm.Name          = 'Test';
        clsTerm.Class__c      = cls.id;
        clsTerm.Status__c	  = 'Draft';
        clsTerm.Start_Date__c = cls.Start_Date__c;
        clsTerm.Sessions__c   = cls.Sessions__c;
        insert clsTerm; 
        
        Session__c sess = new Session__c();
        sess.Class__c        = cls.Id;
        sess.Teacher__c      = tch.Id;
        sess.Status__c       = 'Scheduled';
        sess.Class_Term__c   = clsTerm.Id;
        sess.Duration__c     = 5;
        sess.Session_Date__c = cls.Start_Date__c;
		insert sess;
    }
}