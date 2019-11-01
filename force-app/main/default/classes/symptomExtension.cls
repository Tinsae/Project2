public class SymptomExtension {    
    public List<Symptom__c> Symptoms {get;set;}
    public List<Map<String, String>> PresentingSymptoms {get;set;}
    public List<Specialty__c> Specialties {get;set;}
    public List<PossibleCondition__c> PossibleConditions {get;set;}
    public List<String> SelectedConditions {get;set;}

    public Contact UserContact {get;set;}

    public SymptomExtension() {
        Symptoms = [SELECT Present__c, Name, InfermedicaId__c, OwnerId FROM Symptom__c];
        String userId = UserInfo.getUserId();
        if (userId.length() > 0) {
            UserContact = [
                SELECT Id, Name, Age__c, Sex__c
                FROM Contact
                WHERE Id IN (
                    SELECT ContactId
                    FROM User
                    WHERE Id = :userId
                )
            ];
        } else {
            UserContact.LastName = 'Unknown';
            UserContact.Birthdate = Date.parse('7/22/1995');
            UserContact.Sex__c = 'male';
        }
        PossibleConditions = [
            SELECT 
                Selected__c, 
                Condition__c, 
                Probability__c 
            FROM 
                PossibleCondition__c 
            WHERE 
                OwnerId =: userId 
                AND 
                Appointment__c != ''];
    }

    Integer count = 0;
    public Integer getCount() {return count;}
    public PageReference incrementCounter() {
            count++;
            return null;
    }

    // public List<PossibleCondition__c> getPossibleConditions(){
    //     return PossibleConditions;
    // }

    public void submitSymptoms() {
        presentingSymptoms = new List<Map<String, String>>();
        for (Symptom__c s : Symptoms) {
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