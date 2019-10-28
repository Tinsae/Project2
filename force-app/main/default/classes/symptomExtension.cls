public class symptomExtension {    
    public List<Symptom__c> ctrl {get;set;}
    public Contact userContact {get;set;}
    public List<Map<String, String>> presentingSymptoms {get;set;}

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
    public Integer getCount() {return count;}
    public PageReference incrementCounter() {
            count++;
            return null;
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
        insertPossibleConditions();
    }

    public void insertPossibleConditions() {
        APIInput a = new APIInput();
        a.sex = userContact.Sex__c.toLowerCase();
        a.age = String.valueOf(userContact.Age__c);
        a.evidence = presentingSymptoms;
        List<Object> conditions = InfermedicaTester.sendRequest(a);

        List<String> conditionNames = new List<String>();
        List<Map<String, Object>> conditionList = new List<Map<String, Object>>();
        List<PossibleCondition__c> newPossibleConditions = new List<PossibleCondition__c>();

        for (Object condition : conditions) {
            String s = JSON.serialize(condition);
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(s);
            conditionList.add(m);
            conditionNames.add((String)m.get('name'));
        }

        List<Condition__c> conditionRecords = [
            SELECT Id, Name 
            FROM Condition__c 
            WHERE Name 
            IN :conditionNames
        ];

        for (Map<String, Object> condition : conditionList) {
            PossibleCondition__c p = new PossibleCondition__c();
            p.Probability__c = (Decimal)condition.get('probability');
            for (Condition__c c : conditionRecords) {
                if (condition.get('name') == c.Name) p.Condition__c = c.Id;
            }
            newPossibleConditions.add(p);
        } insert newPossibleConditions;
    }
}