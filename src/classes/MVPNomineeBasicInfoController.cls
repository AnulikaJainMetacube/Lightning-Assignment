public with sharing class MVPNomineeBasicInfoController {
	
    @AuraEnabled 
    public static List<String> getFieldSetMember(String objectName , String fieldSetName){
        List<String> fields = new List<String>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
            fields.add(fieldMember.getFieldPath());    
        }
        return fields;
    }
    @AuraEnabled 
    public static Id getRecordId(Id DesignationId){
        Id contactId;
        contactId = [Select  Contact__r.Id from Designation__c where Id=:DesignationId][0].Contact__r.Id;
        return contactId;
    }
}