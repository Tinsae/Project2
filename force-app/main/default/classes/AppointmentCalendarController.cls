public with sharing class AppointmentCalendarController {

    public String doctor{get;set;}

    public String patient{get;set;}


    public AppointmentCalendarController(){
        doctor = ApexPages.currentPage().getParameters().get('docId');
        patient = ApexPages.currentPage().getParameters().get('patId');
    }

    public PageReference redirectToHome(){
        PageReference pageRef = new PageReference('/apex/HomePage?id='+patient);
        return pageRef;
    }

    @RemoteAction
    public static void createAppointment(Integer year, Integer month, Integer day, List<Integer> startTime, String doctorId, String patientId){
        Appointment__c appointment = new Appointment__c();
        appointment.Doctor__c = doctorId;
        appointment.Contact__c = patientId;
        appointment.Date__c = Date.newInstance(year, month, day);
        appointment.StartTime__c = Time.newInstance(startTime[0], startTime[1],0,0);
        try{
            insert appointment;
        } catch(Exception e){
        }
    }

    @RemoteAction
    public static Map<String, Object> getDoctorAndPatientInfo(String doctorId, String patientId){
        Doctor__c doc = [SELECT Id, Name, Location__c, HourClose__c, HourOpen__c, DaysOpen__c, DurationMin__c, DurationHrs__c
                        FROM Doctor__c WHERE Id =: doctorId];
        Contact patient = [SELECT Id, Name FROM Contact WHERE Id =: patientId];
        Map<String, Object> doctorAndPatientInfo = new Map<String, Object>();
        doctorAndPatientInfo.put('startTime', doc.HourOpen__c);
        doctorAndPatientInfo.put('endTime', doc.HourClose__c);
        doctorAndPatientInfo.put('doctorName', doc.Name);
        doctorAndPatientInfo.put('doctorAddress', doc.Location__c);
        doctorAndPatientInfo.put('daysOpen', doc.DaysOpen__c);
        doctorAndPatientInfo.put('durationHours', doc.DurationHrs__c);
        doctorAndPatientInfo.put('durationMinutes', doc.DurationMin__c);
        doctorAndPatientInfo.put('patientName', patient.Name);
        return doctorAndPatientInfo;
    }

    @RemoteAction
    public static Map<String, Object> getAppointmentInfo(String doctorId){
        List<Appointment__c> existingAppointments = [SELECT Doctor__r.Id, Contact__r.Name, Date__c, StartTime__c 
                                                    FROM Appointment__c 
                                                    WHERE Doctor__r.Id =: doctorId
                                                    AND Date__c != NULL
                                                    AND StartTime__c != NULL
                                                    ORDER BY Date__c];
        Map<String, Object> appointmentInfo = new Map<String, Object>();
        List<String> appointmentStrings = new List<String>();
        String dateFormat;
        Double minutes;
        for(Appointment__c app: existingAppointments){
            minutes = app.StartTime__c.minute()/60.0;
            dateFormat = app.Date__c.year() + ',' + app.Date__c.month() + ',' + app.Date__c.day() + ',' + (app.StartTime__c.hour() + minutes);
            appointmentStrings.add(dateFormat);
        }
        appointmentInfo.put('existingAppointments', appointmentStrings);
        return appointmentInfo;
    }
}