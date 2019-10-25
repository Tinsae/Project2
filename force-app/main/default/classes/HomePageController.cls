public with sharing class HomePageController {

    private List<Appointment__c> pastAppointments;
    private List<Appointment__c> futureAppointments;

    // Get the current time in order to display past/future appointments
    // that were scheduled for today
    private Date today = Date.newInstance(2019, 10, 31);
    private Datetime now = Datetime.now();
    private Integer hours = now.hour();
    private Integer minutes = now.minute();
    private Integer seconds = now.second();
    private Time currentTime = Time.newInstance(hours, minutes, seconds, 0);

    public HomePageController() {

        pastAppointments = [
            SELECT 
                Id 
                ,Date__c 
                ,StartTime__c 
                ,Location__c 
                ,Doctor__c 
                ,Patient__c
                ,Cancelled__c
            FROM Appointment__c 
            WHERE (Patient__c =: ApexPages.currentPage().getParameters().get('Id')
                AND Date__c < TODAY) 
                OR (Date__c = TODAY AND StartTime__c <: currentTime)
        ];

        futureAppointments = [
            SELECT 
                Id 
                ,Date__c 
                ,StartTime__c 
                ,Location__c 
                ,Doctor__c 
                ,Patient__c
                ,Cancelled__c
            FROM Appointment__c 
            WHERE (Patient__c =: ApexPages.currentPage().getParameters().get('Id')
                AND Date__c > TODAY)
                OR (Date__c = TODAY AND StartTime__c >: currentTime)
        ];
    }

    public List<Appointment__c> getPastAppointments() {        
        return pastAppointments;
    }

    public List<Appointment__c> getFutureAppointments() {
        return futureAppointments;
    }
}
