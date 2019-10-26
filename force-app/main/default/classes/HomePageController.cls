public with sharing class HomePageController {

    private List<Appointment__c> pastAppointments;
    private List<Appointment__c> futureAppointments;

    // Get the current time in order to display past/future appointments
    // that were scheduled for today
    private Datetime now = Datetime.now();

    private Integer years = now.year();
    private Integer months = now.month();
    private Integer days = now.day();
    private Date today = Date.newInstance(years, months, days);

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
                ,Contact__c
                ,Cancelled__c
            FROM Appointment__c 
            WHERE (Contact__c =: ApexPages.currentPage().getParameters().get('Id'))
                AND ((Date__c < TODAY) 
                OR (Date__c = TODAY AND StartTime__c <: currentTime))
        ];

        futureAppointments = [
            SELECT 
                Id 
                ,Date__c 
                ,StartTime__c 
                ,Location__c 
                ,Doctor__c 
                ,Contact__c
                ,Cancelled__c
            FROM Appointment__c 
            WHERE (Contact__c =: ApexPages.currentPage().getParameters().get('Id'))
                AND ((Date__c > TODAY)
                OR (Date__c = TODAY AND StartTime__c >: currentTime))
        ];
    }

    public List<Appointment__c> getPastAppointments() {  
        for (Appointment__c appointment : pastAppointments) {
            if (appointment.Date__c == today) {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.INFO, 'You had an appointment today.')); 
                break;
            }
        }    
         
        return pastAppointments;
    }

    public List<Appointment__c> getFutureAppointments() {
        for (Appointment__c appointment : futureAppointments) {
            if (appointment.Date__c == today) {
                ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.INFO, 'You have an appointment today.')); 
                break;
            }
        }    
        return futureAppointments;
    }
}