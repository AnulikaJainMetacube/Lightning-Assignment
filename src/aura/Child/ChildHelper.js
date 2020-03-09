({
	onInit : function(component, event, helper){
        console.log('doInit in child helper');
        console.log('cardOrtable:' + component.get('v.cardOrTable'));
        var objectName = component.get('v.sObjectType');
        var designationId = component.get('v.idValue');
        var getRecordId = component.get('c.getRecordId');
        getRecordId.setParams({
            "DesignationId" : designationId
        });
        getRecordId.setCallback(this, function(response){
            component.set('v.result',[]);
            var state = response.getState();
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                var contactId = response.getReturnValue();
                component.set('v.contactId', contactId);
                var order = component.get('v.order');
                var getContributions = component.get('c.getContributions');
                var recType = component.get('v.recType');
                var dfs = component.get('v.dynamicDFieldSet');
                var vfs = component.get('v.dynamicVFieldSet');
                var cardOrTable = component.get('v.cardOrTable');
                var dynamicTableFieldSet = component.get('v.dynamicTableFieldSet');
                getContributions.setParams({
                    "sObjectName" : objectName,
                    "contactId" : contactId,
                    "order" : order,
                    "recType" : recType,
                    "dynamicDFieldSet" : dfs,
                    "dynamicVFieldSet" : vfs,
                    "cardOrTable" : cardOrTable,
                    "tableFieldSet" : dynamicTableFieldSet
                });
                getContributions.setCallback(this, function(response){
                    var state = response.getState();
                    if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                        component.set('v.result',response.getReturnValue());
                        var map = component.get('v.result');
                        console.log('Result: '+JSON.stringify(component.get('v.result')));
                        var yearList = [];
        				component.set('v.recList', map['horizontalData']);
                        var recList = component.get('v.recList');
        				for(var year in recList){
            				yearList.push(year);
        				}
                        var order = component.get('v.order');
                        if(order=='DESC'){
                            yearList.reverse();
                            console.log('reversed');
                        }
                        console.log('yearList: ... '+ yearList);
                        component.set('v.yearList',yearList);
                    }else if(state === 'INCOMPLETE'){
                        console.log('User is Offline System does not support drafts '
                                   + JSON.stringify(response.getError()));
                    }else if(state ==='ERROR'){
                        console.log(response.getError());
                    }else{
                        
                    }
                });
                $A.enqueueAction(getContributions);
                
                var getCountContribution = component.get('c.getCountContribution');
                getCountContribution.setParams({
                    "contactId" : contactId                    
                });
                getCountContribution.setCallback(this, function(response){
                    var state = response.getState();
                    if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                        component.set('v.countContribution',response.getReturnValue());
                        
                    }else if(state === 'INCOMPLETE'){
                        console.log('User is Offline System does not support drafts '
                                   + JSON.stringify(response.getError()));
                    }else if(state ==='ERROR'){
                        console.log(response.getError());
                    }else{
                        
                    }
                });
                $A.enqueueAction(getCountContribution);

                
            }else if(state==='INCOMPLETE'){
                console.log('User is Offline System does not support drafts '
                           + JSON.stringify(response.getError()));
            }else if(state ==='ERROR'){
                console.log(response.getError());
            }else{
                
            }
        });
        $A.enqueueAction(getRecordId);
        
    },
})