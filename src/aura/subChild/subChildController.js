({
    
	doInit : function(component, event, helper) {
		var key = component.get('v.key');
        var map = component.get('v.result');
        var yearList = [];
        component.set('v.recMapOfYear', map['horizontalData']);
        var recMapOfYear = component.get('v.recMapOfYear');
        for(var yr in recMapOfYear){
            if(key==yr){
            	component.set('v.recList',recMapOfYear[yr]);
                break;
            }
        }
        component.set('v.vfs', map['verticalData']);
        component.set('v.dfs', map['detailsData']);
        var DataMap = map['TableData'];
        var fieldTypes = map['TableFieldTypes'];
        var fields = map['TableFields'];
        var fieldLabels = map['TableFieldLables'];
        var columns = [];
        if(fields != null){
        	for(var i=0; i < fields.length; i++){
                if(i == 0){
                	columns.push({label: fieldLabels[i], 
                                  fieldName: 'linkName', 
                                  type: 'url',
    							  typeAttributes: { 
        							label: {
            							fieldName: 'Name'
        							},
        							target: '_blank'
    							   },
                                 });    
                } else{
            		columns.push({label: fieldLabels[i], fieldName: fields[i], type: fieldTypes[i]});
                }
            }
            
        	component.set('v.columns', columns);
        	for(var yr in recMapOfYear){
            	if(key==yr){
                    var records = DataMap[yr];
					records.forEach(function(record){
                        console.log('Record:' +JSON.stringify(record.Id));
						record.linkName = '/lightning/r/Contribution__c/'+record.Id+'/view';
                        console.log('Record Link:' + record.linkName);
					});
        			component.set('v.data',records);
                    console.log('data:' + JSON.stringify(component.get('v.data')));
                    break;
            	}
        	}
        }
	},
    Add : function (component, event, helper) {
        var createContribution = component.get('c.createContribution');
        var recId = event.currentTarget.name;
        createContribution.setParams({
                    "id" : recId
                });
        createContribution.setCallback(this, function(response){
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
                $A.enqueueAction(createContribution);
    }
})