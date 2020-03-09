public with sharing class subChildController {
	@AuraEnabled
    public static Integer createContribution(Id id){
        Integer count;
        Feedback__c feedback = [SELECT Id, Advocacy_Rating__c, Date__c, Expertise_Rating__c, Name, Generosity_Rating__c, Leadership_Rating__c, Nominator__c, Status__c FROM Feedback__c WHERE Id=:id];
		Contribution__c contri = new Contribution__c();
        contri.Contact__c = feedback.Nominator__c;
        List<String> categ = new List<String>();
        if(feedback.Advocacy_Rating__c != null && feedback.Advocacy_Rating__c > 0){
            categ.add('Advocacy');
        }
        if(feedback.Expertise_Rating__c != null && feedback.Expertise_Rating__c > 0){
            categ.add('Expertise');
        }
        if(feedback.Generosity_Rating__c != null && feedback.Generosity_Rating__c > 0){
            categ.add('Generosity');
        }
        if(feedback.Leadership_Rating__c != null && feedback.Leadership_Rating__c > 0){
            categ.add('Leadership');
        }
        String categories;
        if(categ.size() > 1){
        	categories = String.join(categ,';');
        } else if(categ.size() == 1){
            categories = categ[0];
        } 
        
        contri.Pillars__c = categories;
        contri.Name = feedback.Id + 'contribution';
        contri.Date__c = Date.today();
        contri.Feedback__c = id;
        try{
            insert contri;
            System.debug('Inserted successfully with id'+ contri.Id);
        } catch(Exception e){
            System.debug(e.getMessage());
        }
        String q = 'Select count(Id) Amount from Contribution__c where Contact__r.Id=\''+Feedback.Nominator__c+'\'';
        System.debug('query:'+q);
        List<AggregateResult> temp = Database.query(q);
        count = (Integer)temp[0].get('Amount');     
        System.debug('Count is: '+count);
        return count;
    }
}