trigger ClassTrigger on Class__c (after insert, after update) {
    /*
    List<Class__c> clsList = new List<Class__c>();
    for(Class__c cls: Trigger.new){
        if(String.isNotBlank(cls.Status__c) && cls.Status__c.equalsIgnoreCase('Open') && cls.Sessions__c != null 
           && cls.Start_Date__c != null && cls.Start_Time__c != null && cls.End_Time__c != null){
            if(Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(cls.Id).Status__c != cls.Status__c)){
                clsList.add(cls);
            }    
        }
    }
    
    if(clsList.size() > 0){
        ClassTriggerHelper.createSession(Trigger.isUpdate, clsList);
    }*/
    
    
    //-------   Trigger to create a classTerm when A cLass is created (Mar 4,2020)   -------//
    
    if (trigger.isInsert){
         ClassTriggerHelper.createClassTerm(Trigger.new);
     }
    
}