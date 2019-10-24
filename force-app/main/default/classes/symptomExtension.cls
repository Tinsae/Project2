public with sharing class symptomExtension {
    ApexPages.StandardSetController ctrl {get;set;}
    public symptomExtension(ApexPages.StandardSetController ctrl) {
        this.ctrl = new ApexPages.StandardSetController(
            [SELECT Id, Name FROM Symptom__c]
        );
    }
    public List<Symptom__c> displayedSymptoms {
        get {return ctrl.getRecords();}
        set;
    }
}
