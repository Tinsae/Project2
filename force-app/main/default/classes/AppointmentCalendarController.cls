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
    public static Map<String, Object> getDoctorInfo(String doctorId){
        Doctor__c doc = [SELECT Id, Name, Location__c, HourClose__c, HourOpen__c, DaysOpen__c, DurationMin__c, DurationHrs__c
                        FROM Doctor__c WHERE Id =: doctorId];
        Map<String, Object> doctorInfo = new Map<String, Object>();
        doctorInfo.put('startTime', doc.HourOpen__c);
        doctorInfo.put('endTime', doc.HourClose__c);
        doctorInfo.put('doctorName', doc.Name);
        doctorInfo.put('doctorAddress', doc.Location__c);
        doctorInfo.put('daysOpen', doc.DaysOpen__c);
        doctorInfo.put('durationHours', doc.DurationHrs__c);
        doctorInfo.put('durationMinutes', doc.DurationMin__c);
        return doctorInfo;
    }

    @RemoteAction
    public static Map<String, Object> getAppointmentInfo(String doctorId, String patientId){
        List<Appointment__c> existingAppointments = [SELECT Doctor__r.Id, Contact__r.Name, Date__c, StartTime__c 
                                                    FROM Appointment__c 
                                                    WHERE Doctor__r.Id =: doctorId
                                                    AND Date__c != NULL
                                                    AND StartTime__c != NULL];
        Map<String, Object> appointmentInfo = new Map<String, Object>();
        List<String> appointmentStrings = new List<String>();
        String dateFormat;
        for(Appointment__c app: existingAppointments){
            dateFormat = app.Date__c.year() + ',' + app.Date__c.month() + ',' + app.Date__c.day() + ',' + app.StartTime__c.hour();
            appointmentStrings.add(dateFormat);
            if(app.Contact__c==patientId){
                appointmentInfo.put('patientName', app.Contact__r.Name);
            }
        }
        appointmentInfo.put('existingAppointments', appointmentStrings);
        return appointmentInfo;
    }
}