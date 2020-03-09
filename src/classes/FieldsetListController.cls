global class FieldsetListController extends VisualEditor.DynamicPickList{
	global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None',''); 
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues(){
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get('Contribution__c');
        VisualEditor.DynamicPickListRows pickListValues = new VisualEditor.DynamicPickListRows();
        for(Schema.FieldSet FS : sObj.getDescribe().fieldSets.getMap().values()){
            VisualEditor.DataRow pickListRowValue = new VisualEditor.DataRow(fs.getLabel()+' Contribution', fs.getName());
            pickListValues.addRow(pickListRowValue);
        }
        sObj = Schema.getGlobalDescribe().get('Feedback__c');
        for(Schema.FieldSet FS : sObj.getDescribe().fieldSets.getMap().values()){
            VisualEditor.DataRow pickListRowValue = new VisualEditor.DataRow(fs.getLabel()+' Feedback', fs.getName());
            pickListValues.addRow(pickListRowValue);
        }
        return pickListValues;
    }
}