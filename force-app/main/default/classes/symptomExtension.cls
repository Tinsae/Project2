public with sharing class symptomExtension {
    ApexPages.StandardSetController ctrl {get;set;}
    public symptomExtension(ApexPages.StandardSetController ctrl) {
        this.ctrl = new ApexPages.StandardSetController(
            [SELECT Id, Name FROM Symptom__c]
        );
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
    public List<Symptom__c> displayedSymptoms {
        get {return ctrl.getRecords();}
        set;
    }
    public Contact userContact {
        get;
        set;
    }
}
