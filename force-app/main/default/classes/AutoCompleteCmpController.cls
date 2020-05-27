public class AutoCompleteCmpController {
	@auraEnabled(cacheable=true)
    public static List<SObject> getRecords(String searchString, String objectApiName, String idFieldApiName, String valueFieldApiName, String extendedWhereClause, Integer maxRecords){
        searchString = String.escapeSingleQuotes(searchString);
        objectApiName = String.escapeSingleQuotes(objectApiName);
        idFieldApiName = String.escapeSingleQuotes(idFieldApiName);
        valueFieldApiName = String.escapeSingleQuotes(valueFieldApiName);
        
        if(extendedWhereClause == null){
            extendedWhereClause = '';
        }
        System.debug('@@@@-->'+extendedWhereClause);
        String query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+' FROM '+objectApiName+' WHERE '+valueFieldApiName+' LIKE \'%'+searchString+'%\' '+extendedWhereClause+' LIMIT '+maxRecords;
        if(objectApiName.equalsIgnoreCase('Account')){
            if(extendedWhereClause.startsWith('001'))
                extendedWhereClause = ' AND Parent__c = \'' +extendedWhereClause+ '\' AND Recordtype.Name =\'Customer\' ';
        	//query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+',LastName,PersonEmail FROM '+objectApiName+' WHERE Recordtype.Name =\'Customer\' AND '+valueFieldApiName+' LIKE \'%'+searchString+'%\' '+extendedWhereClause+' LIMIT '+maxRecords;
        	query = 'SELECT '+idFieldApiName+', '+valueFieldApiName+',LastName,PersonEmail FROM '+objectApiName+' WHERE '+valueFieldApiName+' LIKE \'%'+searchString+'%\' '+extendedWhereClause+' LIMIT '+maxRecords;
        }       
        
        return Database.query(query);
    }
}