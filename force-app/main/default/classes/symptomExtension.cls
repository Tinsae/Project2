public class symptomExtension {    
    public List<Symptom__c> ctrl {get;set;}
    public Contact userContact {get;set;}
    public List<Map<String, String>> presentingSymptoms;

    public symptomExtension() {
        ctrl = [SELECT Present__c, Name, InfermedicaId__c, OwnerId FROM Symptom__c];
        String userId = UserInfo.getUserId();
        userContact = [
            SELECT Id, Name, Age__c, Sex__c
            FROM Contact
            WHERE Id IN (
                SELECT ContactId
                FROM User
                WHERE Id = :userId
            )
        ];
    }

    Integer count = 0;
                        
    public PageReference incrementCounter() {
            count++;
            return null;
    }
                    
    public Integer getCount() {
        return count;
    }

    public void submit() {
        presentingSymptoms = new List<Map<String, String>>();
        for (Symptom__c s : ctrl) {
            if (s.Present__c == true) {
                Map<String, String> presenting = new Map<String, String>();
                presenting.put('id', s.InfermedicaId__c);
                presenting.put('choice_id', 'present');
                presentingSymptoms.add(presenting);
            }
        }
        APIInput a = new APIInput();
        a.sex = userContact.Sex__c;
        a.age = String.valueOf(userContact.Age__c);
        a.evidence = presentingSymptoms;

        List<Object> conditions = InfermedicaTester.sendRequest(a);
        List<PossibleCondition__c> gg = new List<PossibleCondition__c>();
        insert gg;
    }

    public List<Map<String, String>> getPresentingSymptoms() {
        return presentingSymptoms;
    }

    public String getAPIKeys() {
        return '';
    }
}