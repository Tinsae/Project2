public with sharing class AppointmentCalendarController {

    public static String doctor{
        get{
            return 'a022F000003lwYdQAI';
        } set;
    }

    public static String patient{
        get{
            return 'a032F0000032x5sQAA';
        } set;
    }
    

    @RemoteAction
    public static String createAppointment(Integer year, Integer month, Integer day, Integer startTime){
        Appointment__c a = new Appointment__c();
        a.Doctor__c = doctor;
        a.Patient__c = patient;
        a.Date__c = Date.newInstance(year, month, day);
        a.StartTime__c = Time.newInstance(startTime, 0,0,0);
        try{
            insert a;
        }
        catch(Exception e){
            return 'Sorry something went wrong.';
        }
        return 'Success'; 
    }

    @RemoteAction
    public static List<Time> getDoctorStartAndEndTimes(){
        Doctor__c doc = [SELECT Id, HourClose__c, HourOpen__c FROM Doctor__c WHERE Id =: doctor];
        List<Time> openCloseHours = new List<Time>();
        openCloseHours.add(doc.HourOpen__c);
        openCloseHours.add(doc.HourClose__c);
        return openCloseHours;
    }

    @RemoteAction
    public static List<String> getAppointmentInfo(){
        List<Appointment__c> existingAppointments = [SELECT Doctor__r.Id, Date__c, StartTime__c 
                                                    FROM Appointment__c 
                                                    WHERE Doctor__r.Id =:doctor
                                                    AND Date__c != NULL
                                                    AND StartTime__c != NULL];
        List<String> appointmentStrings = new List<String>();
        String dateFormat;
        for(Appointment__c app: existingAppointments){
            dateFormat = app.Date__c.year() + ',' + app.Date__c.month() + ',' + app.Date__c.day() + ',' + app.StartTime__c.hour();
            appointmentStrings.add(dateFormat);
        }
        return appointmentStrings;
    }
}
