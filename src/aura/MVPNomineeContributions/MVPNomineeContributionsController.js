({
    refreshChild : function(component, event, helper){
        console.log('refreshChild called');
        var childCmp = component.find("child");
        var idValue = component.get("v.recordId");
        var order = component.get("v.order");
        childCmp.refreshMe("Feedback__c", idValue, order, "Feedback");
    }
})