public with sharing class HomePageController {

    private List<Appointment__c> pastAppointments;
    private List<Appointment__c> futureAppointments;

    // Parameter to pass to appointment wizard URL
    public String idParam {get;set;}

    // User info
    private String userId;
    private List<Contact> userContact;

    // Get the current time and date in order to display 
    // past/future appointments scheduled for today, along with 
    // info messages
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

        userId = UserInfo.getUserId();
        userContact = [
            SELECT 
                Id
                ,Name
                ,Age__c
                ,Sex__c
            FROM Contact
            WHERE Id IN (
                SELECT ContactId
                FROM User
                WHERE Id = :userId
            )
            LIMIT 1
        ];

        pastAppointments = [
            SELECT 
                Id 
                ,Date__c 
                ,StartTime__c 
                ,Location__c 
                ,Doctor__c 
                ,Doctor__r.Name
                ,Contact__c
                ,Contact__r.FirstName
                ,Contact__r.LastName
                ,Cancelled__c
            FROM Appointment__c 
            WHERE (Contact__c =: userContact[0].Id) 
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
                ,Doctor__r.Name
                ,Contact__c
                ,Contact__r.FirstName
                ,Contact__r.LastName
                ,Cancelled__c
            FROM Appointment__c 
            WHERE (Contact__c =: userContact[0].Id) 
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

    public PageReference goToAppointmentWizard() {
        idParam = (String)userContact[0].Id;
        String url = '/apex/SymptomsChecker?id=' + idParam;
        Pagereference pageRef = new Pagereference(url);
        return pageRef;
    }
}