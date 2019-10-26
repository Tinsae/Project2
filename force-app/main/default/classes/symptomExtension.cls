public with sharing class symptomExtension {    
    public List<Symptom__c> ctrl {get;set;}
    public Contact userContact {get;set;}
    public List<Map<String, String>> presentingSymptoms = new List<Map<String, String>>();

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
        // submit();
    }

    public Object gg {
        get{
            for (Symptom__c s : ctrl) {
                if (s.Present__c == true) {
                    Map<String, String> presenting = new Map<String, String>();
                    presenting.put('id', s.InfermedicaId__c);
                    presenting.put('choice_id', 'present');
                    presentingSymptoms.add(presenting);
                }
            }
            return presentingSymptoms;
        }
        set;
    }
    public void submit() {
        for (Symptom__c s : ctrl) {
            if (s.Present__c == true) {
                Map<String, String> presenting = new Map<String, String>();
                presenting.put('id', s.InfermedicaId__c);
                presenting.put('choice_id', 'present');
                presentingSymptoms.add(presenting);
            }
        }
    }

    public String getAPIKeys() {
        return '';
    }

    public String postSymptoms() {
        Map<String, Object> body = new Map<String, Object>();
        body.put('sex', userContact.Sex__c);
        body.put('age', userContact.Age__c);
        body.put('evidence', JSON.serialize(presentingSymptoms));

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.infermedica.com/v2/diagnosis');
        request.setMethod('POST');
        request.setHeader('App-Id', 'f2df8ab0');
        request.setHeader('App-Key', '89cc1171442a8489fde825246238ed8c');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(body));

        HttpResponse response = http.send(request);
        return response.getBody();
    }
    public List<Object> getConditions(HttpResponse response) {
        if (response.getStatusCode() != 200) return new List<Object>();
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        return (List<Object>)results.get('conditions');
    }
}
