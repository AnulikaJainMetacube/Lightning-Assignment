({
    onInit : function(component, event, helper){
        var designationId = component.get('v.recordId');
        var getRecordId = component.get('c.getRecordId');
        getRecordId.setParams({
            "DesignationId" : designationId
        });
        getRecordId.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                var contactId = response.getReturnValue();
                component.set('v.contactId', contactId);
            }else if(state==='INCOMPLETE'){
                console.log('User is Offline System does not support drafts '
                           + JSON.stringify(response.getError()));
            }else if(state ==='ERROR'){
                console.log(response.getError());
            }else{
                
            }
        });
        $A.enqueueAction(getRecordId);
        
        
        var FiledSetMember = component.get('c.getFieldSetMember');
        var selectedfieldSet = component.get('v.dynamicFieldSet');
        FiledSetMember.setParams({
            "objectName" : 'Contact',
            "fieldSetName" : selectedfieldSet
        });
        FiledSetMember.setCallback(this, function(response){
            var state = response.getState();
            var fields = [];
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                var fieldsFetched = response.getReturnValue();
                for(var i = 0; i< fieldsFetched.length; i++){
                    fields.push(fieldsFetched[i]);
                }
                component.set('v.fields', fields);
            }else if(state==='INCOMPLETE'){
                console.log('User is Offline System does not support drafts '
                           + JSON.stringify(response.getError()));
            }else if(state ==='ERROR'){
                console.log(response.getError());
            }else{
                
            }
        });
        $A.enqueueAction(FiledSetMember);
    },
})