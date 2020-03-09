public with sharing class ChildController {
	
    @AuraEnabled 
    public static List<String> getFieldSetMember(String objectName , String fieldSetName){
        List<String> fields = new List<String>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        if(sObj.getDescribe().fieldSets.getMap().get(fieldSetName) != null){
            for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
                fields.add(fieldMember.getFieldPath());    
            }
        	return fields;
        } 
        return null;
    }
    class Field{
        public String APIName;
        public String Label;
        public String fieldType;
        public Field(String APIName, String Label ){
            this.APIName = APIName;
            this.Label = Label;
        }
    }
    @AuraEnabled 
    public static List<Field> getTableFieldSetMember(String objectName , String tableFieldSet){
        List<Field> fields = new List<Field>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        Field f;
        if(sObj.getDescribe().fieldSets.getMap().get(tableFieldSet) != null){
            for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(tableFieldSet).getFields()){
                f = new Field(fieldMember.getFieldPath(), fieldMember.getLabel());
                if(fieldMember.getType() == Schema.DisplayType.TextArea || fieldMember.getType() == Schema.DisplayType.String || fieldMember.getType() == Schema.DisplayType.MULTIPICKLIST || fieldMember.getType() == Schema.DisplayType.PICKLIST){
                    f.fieldType = 'text';
                } else if(fieldMember.getType() == Schema.DisplayType.DOUBLE){
                    f.fieldType = 'number';
                } else{
                    f.fieldType = 'text';
                }
                fields.add(f);    
            }
            return fields;
        } 
        return null;
    }
    @AuraEnabled
    public static Integer getCountContribution(Id contactId){
        Integer count;
        String q = 'Select count(Id) Amount from Contribution__c where Contact__r.Id=\''+contactId+'\'';
        List<AggregateResult> temp = Database.query(q);
        count = (Integer)temp[0].get('Amount');     
        return count;
    }
    @AuraEnabled
  	public static Map<String, Object> getContributions(String sObjectName, Id contactId, String order, 
                                                       String recType, String dynamicDFieldSet, 
                                                       String dynamicVFieldSet, String cardOrTable, String tableFieldSet){
       String vfs = 'Vertical_Fieldset';
       String dfs = 'Detail_fieldset';
       if(dynamicDFieldSet != null && sObjectName.equals('Contribution__c') && !dynamicDFieldSet.contains('Detail_fieldset')){
            dfs = dynamicDFieldSet;
       }
       if(dynamicVFieldSet != null && sObjectName.equals('Contribution__c') && !dynamicVFieldSet.contains('Vertical')){
            vfs = dynamicVFieldSet;
       } 
       if(dynamicDFieldSet != null && sObjectName.equals('Feedback__c') && !dynamicDFieldSet.contains('Detail_fieldset')){
       	   dfs = dynamicDFieldSet;       
       }
       if(dynamicVFieldSet != null && sObjectName.equals('Feedback__c') && !dynamicVFieldSet.contains('Vertical_Fieldset')){
            vfs = dynamicVFieldSet;       
       } 
       List<String> horizontalFields = getFieldSetMember(sObjectName, 'Horizontal_Fieldset');
       List<String> verticalFields = getFieldSetMember(sObjectName, vfs);
       List<String> detailFields = getFieldSetMember(sObjectName, dfs);
                                                           
       if(verticalFields ==  null){
           verticalFields = getFieldSetMember(sObjectName, 'Vertical_Fieldset');
       }
       if(detailFields ==  null){
           detailFields = getFieldSetMember(sObjectName, 'Detail_fieldset');
       } 
       Map<String, object> returnMap = new Map<String, object>();
       String query1;
       String q;
       if(sObjectName.equals('Feedback__c')){
           if(cardOrTable.equals('Card')){
       	   List<Feedback__c> contriList = new List<Feedback__c>();
           q = 'Select Id, Date__c, '+ String.join(horizontalFields, ',') + ' FROM ' + sObjectName + ' WHERE RecordType.Name = \''+recType+'\' and Nominator__c = \''+contactId+'\' ORDER BY Date__c '+ order;
           contriList = (List<Feedback__c>)Database.query(q);
           query1 = 'Select Count(Id), Calendar_Year(Date__c) Year1 from ' + sObjectName + ' WHERE RecordType.Name = \'Self-feedback\' and Nominator__c = \''+contactId+'\' group by Calendar_Year(Date__c) order by Calendar_Year(Date__c) ' +  order;
           List<AggregateResult> listAgg = Database.query(query1);
           Map<Integer, List<Feedback__c>> contributionMap = new Map<Integer, List<Feedback__c>>();
           for(Feedback__c contri : contriList){
                if(contri.Date__c != null){
                    Integer year = contri.Date__c.year();
                    for(AggregateResult res : listAgg){
                        if(res.get('Year1') == year){
                            List<Feedback__c> temp = contributionMap.get(year);
                            if(temp == null){
                                temp = new List<Feedback__c>();
                            } 
                            temp.add(contri);
                            contributionMap.put(year, temp);
                            break;
                        }   
                    }
                }
           }
           returnMap.put('horizontalData', contributionMap);
           }
       } else if(sObjectName.equals('Contribution__c')){
           List<Contribution__c> contriList = new List<Contribution__c>();
           List<Contribution__c> contriTableList = new List<Contribution__c>();
           List<String> fieldLabel = new List<String>();
           List<String> fieldList = new List<String>();
           List<String> fieldType = new List<String>();
           Map<Id,Contribution__c > contriTableMap = new Map<Id,Contribution__c >(); 
           q = 'Select Id, Date__c, '+ String.join(horizontalFields, ',') + ' FROM ' + sObjectName + ' WHERE Contact__r.Id = \''+contactId+'\' ORDER BY Date__c '+ order;
           contriList = Database.query(q);
           query1 = 'Select Count(Id), Calendar_Year(Date__c) Year1 from ' + sObjectName + ' WHERE Contact__r.Id = \''+contactId+'\' group by Calendar_Year(Date__c) order by Calendar_Year(Date__c) ' +  order;
           if(cardOrTable.equals('DataTable')){
                List<Field> tableFields = getTableFieldSetMember(sObjectName, tableFieldSet);
               	fieldLabel.add('Name');
                fieldList.add('Name');
                fieldType.add('text');
                for(Field f : tableFields){
                    if(!((f.APIName).equals('Name'))){
                       fieldList.add(f.APIName); 
                       fieldLabel.add(f.Label);
                       fieldType.add(f.fieldType); 
                    }	 
                }
				String query = 'Select '+ String.join(fieldList,',') +',Date__c, Id  FROM ' + sObjectName + ' WHERE Contact__r.Id = \''+contactId+'\' ORDER BY Date__c '+ order;               
           		contriTableList = Database.query(query);
               	for(Contribution__c cont : contriTableList)
		   		{
     				contriTableMap.put(cont.Id, cont);
		   		}
                fieldList.add('Date__c'); 
                fieldLabel.add('Date');
                fieldType.add('date');
                fieldList.add('Id'); 
                fieldLabel.add('Id');
                fieldType.add('text');
           }
           List<AggregateResult> listAgg = Database.query(query1);
           Map<Integer, List<Contribution__c>> contributionMap = new Map<Integer, List<Contribution__c>>();
           Map<Integer, List<Contribution__c>> contributionTableMap = new Map<Integer, List<Contribution__c>>();
           for(Contribution__c contri : contriList){
                if(contri.Date__c != null){
                    Integer year = contri.Date__c.year();
                    for(AggregateResult res : listAgg){
                        if(res.get('Year1') == year){
                            List<Contribution__c> temp = contributionMap.get(year);
                            if(temp == null){
                                temp = new List<Contribution__c>();
                            } 
                            temp.add(contri);
                            if(cardOrTable.equals('DataTable')){
                                List<Contribution__c> temp1 = contributionTableMap.get(year);
                                if(temp1 == null){
                                    temp1 = new List<Contribution__c>();
                                } 
                                temp1.add(contriTableMap.get(contri.Id));
                                contributionTableMap.put(year, temp1);
                            }
                            contributionMap.put(year, temp);
                            break;
                        }   
                    }
                }
           }
           if(cardOrTable.equals('DataTable')){
               returnMap.put('TableData', contributionTableMap);
               returnMap.put('TableFields', fieldList);
               returnMap.put('TableFieldLables', fieldLabel);
               returnMap.put('TableFieldTypes',fieldType);
           }
           returnMap.put('horizontalData', contributionMap);
       }
       if(cardOrTable.equals('Card')){    
           if(verticalFields == null){
                returnMap.put('verticalData', null);	
           } else {
                returnMap.put('verticalData', verticalFields);
           }
           if(detailFields == null || (sObjectName.equals('Feedback__c') && recType.equals('Self-feedback'))){
                returnMap.put('detailsData', null);	
           } else {
                returnMap.put('detailsData', detailFields);
           }
       }
       System.debug(returnMap);
       return returnMap;
  }
    @AuraEnabled 
    public static Id getRecordId(Id DesignationId){
        Id contactId;
        contactId = [Select  Contact__r.Id from Designation__c where Id=:DesignationId][0].Contact__r.Id;
        return contactId;
    }
}