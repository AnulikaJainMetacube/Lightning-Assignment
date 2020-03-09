({
    doInit : function(component, event, helper) {
        helper.onInit(component, event, helper);
    }, 
    refreshMe : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var ObjectType = params.ObjectType;
            var idValue = params.idValue;
            var order = params.order;
            var recType = params.recType;
        	component.set("v.sObjectType", ObjectType);
            component.set("v.idValue", idValue);
            component.set("v.order", order);
            component.set("v.recType", recType);
            helper.onInit(component, event, helper);
        }
        
    }
})