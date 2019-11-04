public class SymptomExtension {
	public List<Symptom__c> Symptoms { get; set; }
	public List<Map<String, String>> PresentingSymptoms { get; set; }
	public List<String> SelectedConditions { get; set; }
	public Contact UserContact { get; set; }

	public SymptomExtension() {
		Symptoms = [
			SELECT Present__c, CommonName__c, InfermedicaId__c, OwnerId 
			FROM Symptom__c
			LIMIT 1000
		];
		String userId = UserInfo.getUserId();
		UserContact = [
			SELECT Id, Name, Age__c, Sex__c
			FROM Contact
			WHERE Id IN(SELECT ContactId
			FROM User
			WHERE Id = :userId)
		];
	}

	public PageReference goToPossibleConditions() {
		String url = '/apex/ConditionChecker';
		Pagereference pageRef = new Pagereference(url);
		return pageRef;
	}

	public PageReference submitSymptoms() {
		presentingSymptoms = new List<Map<String, String>>();
		for (Symptom__c s :Symptoms) {
			if(s.Present__c == true) {
				Map<String, String> presenting = new Map<String, String>();
				presenting.put('id', s.InfermedicaId__c);
				presenting.put('choice_id', 'present');
				presentingSymptoms.add(presenting);
			}
		}
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Symptoms: ' + PresentingSymptoms);
		ApexPages.addMessage(myMsg);
		insertPossibleConditions();
		return goToPossibleConditions();
	}
	public void insertPossibleConditions() {

		try{
			APIInput a = new APIInput();
			a.sex = userContact.Sex__c.toLowerCase();
			a.age = String.valueOf(userContact.Age__c);
			a.evidence = presentingSymptoms;
			List<Object> conditions = InfermedicaTester.sendRequest(a, 'diagnosis');

			List<Map<String, Object>> conditionList = new List<Map<String, Object>>();
			List<PossibleCondition__c> newPossibleConditions = new List<PossibleCondition__c>();

			for (Object condition :conditions) {
				String s = JSON.serialize(condition);
				Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(s);
				conditionList.add(m);
			}
			List<Condition__c> newConditions = [
				SELECT Id, CommonName__c
				FROM Condition__c
			];

			for (Map<String, Object> condition :conditionList) {
				PossibleCondition__c p = new PossibleCondition__c();
				p.Probability__c = (Decimal) condition.get('probability');
				for (Condition__c c :newConditions) {
					if(condition.get('name') == c.CommonName__c)
						p.Condition__c = c.Id;
				}
				newPossibleConditions.add(p);
			}
			insert newPossibleConditions;
		} 
		catch(Exception ex) {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage());
			ApexPages.addMessage(myMsg);
		}
	}

}