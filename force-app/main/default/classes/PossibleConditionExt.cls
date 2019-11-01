public class PossibleConditionExt {
	public List<PossibleCondition__c> PossibleConditions { get; set; }
	public Contact userContact { get; set; }
	public List<String> SelectedConditions { get; set; }
	public List<Specialty__c> Specialties { get; set; }
	public List<SelectOption> options = new List<SelectOption>();

	public String selectedDoctor = null;
	public PossibleConditionExt() {
		String userId = UserInfo.getUserId();
		PossibleConditions = [SELECT
						      Selected__c, 
						      Condition__c, 
						      Probability__c
						      FROM
						      PossibleCondition__c
						      WHERE
						      OwnerId = :userId];

	}

	public List<SelectOption> getItems() {
		// //for (Specialty__c s : Specialties) {
		//     Integer i = 0;
		//     while(i < 5){
		//         options.add(new SelectOption('AAAAAAAa' + String.valueOf(i), 'AAAAAAAa' +  String.valueOf(i)));
		//         i += 1;
		//     }
		return options;
	}

	public String getSelectedDoctor() {
		return selectedDoctor;
	}
	public void setSelectedDoctor(String selectedDoctor) {
		this.selectedDoctor = selectedDoctor;
	}

	public void submitForDoctors() {
		//...
		SelectedConditions = new List<String>();
		// collect condition ids
		List<Id> idList = new List<Id>();

		for (PossibleCondition__c pCond :PossibleConditions) {
			if(pCond.Selected__c == true) {
				idList.add(pCond.Condition__c);
			}
		}
		Specialties = [SELECT
					   Doctor__r.Name, Condition__c
					   FROM
					   Specialty__c
					   WHERE
					   Condition__c IN :idList
		];
		Map<Id, String> condNamesMap = new Map<Id, String>();
		for (Condition__c cc :[SELECT Id, Name FROM Condition__c]) {
			if(!condNamesMap.containsKey(cc.Id)) {
				condNamesMap.put(cc.Id, cc.Name);
				}
		}


		Map<String, List<String>> doctorListOfConditions = new Map<String, List<String>>();
		for(Specialty__c sp :Specialties) {
			String docName = sp.Doctor__r.Name;
			String condName = condNamesMap.get(sp.Condition__c);

			if(doctorListOfConditions.containsKey(docName)) {
				doctorListOfConditions.get(docName).add(condName);
			} else {
				doctorListOfConditions.put(docName, new List<String>{condName});
			}
		}
		for(String key : doctorListOfConditions.keySet()) {
			String value = key + doctorListOfConditions.get(key);
			options.add(new SelectOption(key, value));
		}
	}
}