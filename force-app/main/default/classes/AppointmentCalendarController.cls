public with sharing class AppointmentCalendarController {

    public String doctor{get;set;}

    public String patient{get;set;}

    public List<String> appointments{get;set;}

    public AppointmentCalendarController(){
        Id docId = ApexPages.currentPage().getParameters().get('docId');
        doctor = getDoctorInfo(docId);
        appointments = getAppointmentInfo(docId);
        patient = getPatientInfo(ApexPages.currentPage().getParameters().get('patId'));
    }

    /**
    * when an appointment has been created go back to that users home page
     */
    public PageReference redirectToHome(){
        PageReference pageRef = new PageReference('/apex/HomePage?id='+patient);
        return pageRef;
    }

    /**
    * called by javascript to create the appointment
     */
    @RemoteAction
    public static void createAppointment(Integer year, Integer month, Integer day, List<Integer> startTime, String doctorId, String patientId){
        Appointment__c appointment = new Appointment__c();
        appointment.Doctor__c = doctorId;
        appointment.Contact__c = patientId;
        appointment.Date__c = Date.newInstance(year, month, day);
        appointment.StartTime__c = Time.newInstance(startTime[0], startTime[1],0,0);
        try{
            insert appointment;
            List<PossibleCondition__c> condition = [SELECT Id FROM PossibleCondition__c WHERE Appointment__c =: NULL];
            for(PossibleCondition__c c: condition){
                c.Appointment__c = appointment.Id;
            }
            insert condition;
        } catch(Exception e){
        }
    }

    /**
    * return a JSON formatted string that contains all necessary information about a specified doctor
     */
    public String getDoctorInfo(String doctorId){
        Doctor__c doc = [SELECT Id, Name, Location__c, HourClose__c, HourOpen__c, DaysOpen__c, DurationMin__c, DurationHrs__c
                        FROM Doctor__c WHERE Id =: doctorId];
        Map<String, Object> doctorInfo = new Map<String, Object>();
        Decimal startTime = (Decimal)doc.HourOpen__c.hour() + (doc.HourOpen__c.minute()/60.0);
        Decimal endTime = (Decimal)doc.HourClose__c.hour() + (doc.HourClose__c.minute()/60.0);
        doctorInfo.put('startTime', startTime);
        doctorInfo.put('endTime', endTime);
        doctorInfo.put('name', doc.Name);
        doctorInfo.put('address', doc.Location__c);
        doctorInfo.put('daysOpen', doc.DaysOpen__c);
        doctorInfo.put('durationHours', (Decimal)doc.DurationHrs__c + (doc.DurationMin__c/60.0));
        doctorInfo.put('id', doc.Id);
        return JSON.serialize(doctorInfo);
    }

    /**
    * return a JSON formatted string that contains all necessary information about a specified patient
     */
    public String getPatientInfo(String patientId){
        Contact patient = [SELECT Id, Name FROM Contact WHERE Id =: patientId];
        Map<String,Object> patientInfo = new Map<String, Object>();
        patientInfo.put('id', patient.Id);
        patientInfo.put('name', patient.Name);
        return JSON.serialize(patientInfo);
    }

    /**
    * return a list of all appointments for a specified doctor in 
    * year,month,day,startTime String format
     */
    public List<String> getAppointmentInfo(String doctorId){
        List<Appointment__c> existingAppointments = [SELECT Doctor__r.Id, Contact__r.Name, Date__c, StartTime__c 
                                                    FROM Appointment__c 
                                                    WHERE Doctor__r.Id =: doctorId
                                                    AND Date__c != NULL
                                                    AND StartTime__c != NULL
                                                    ORDER BY Date__c];
        List<String> appointmentStrings = new List<String>();
        String dateFormat;
        Double minutes;
        for(Appointment__c app: existingAppointments){
            minutes = app.StartTime__c.minute()/60.0;
            dateFormat = app.Date__c.year() + ',' + app.Date__c.month() + ',' + app.Date__c.day() + ',' + (app.StartTime__c.hour() + minutes);
            appointmentStrings.add(dateFormat);
        }
        return appointmentStrings;
    }
}