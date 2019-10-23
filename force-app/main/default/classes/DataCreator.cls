public class DataCreator {
    public static void createData() {
		deleteExistingData();
        
        createPatients();
        createDoctors();
        createConditions();
        
        // Lookup(Doctor)
        // Lookup(Patient)
        createAppointments();
        
        // Lookup(Appointment)
        // Lookup(Condition)
        createPossibleConditions();
         
        // Lookup(Doctor)
        // Lookup(Condition)
        createSpecialties();
    }
    
    private static void deleteExistingData() {
                deleteExistingPossibleConditions();
        deleteExistingAppointments();

        deleteExistingSpecialties();
        deleteExistingConditions();
        deleteExistingSymptoms();
        deleteExistingPatients();
        deleteExistingDoctors();
    }
    
    private static void deleteExistingSymptoms() { delete [SELECT Id FROM Symptom__c]; }
    private static void deleteExistingPatients() { delete [SELECT Id FROM Patient__c]; }
    private static void deleteExistingAppointments() { delete [SELECT Id FROM Appointment__c]; }
    private static void deleteExistingDoctors() { delete [SELECT Id FROM Doctor__c]; }
    private static void deleteExistingSpecialties() { delete [SELECT Id FROM Specialty__c]; }
    private static void deleteExistingPossibleConditions() { delete [SELECT Id FROM PossibleCondition__c]; }
    private static void deleteExistingConditions() { delete [SELECT Id FROM Condition__c]; }
    
    private static void createPatients() {
        
        List<Patient__c> patients = new List<Patient__c>();
        
        patients.add(new patient__c(DateOfBirth__c = Date.newInstance(1945, 01, 01)
                                   ,Gender__c = 'Male'
                                   ,Name = 'Sylvestor'));
        patients.add(new patient__c(DateOfBirth__c = Date.newInstance(1947, 12, 07)
                                   ,Gender__c = 'Female'
                                   ,Name = 'Adrienne'));
        patients.add(new patient__c(DateOfBirth__c = Date.newInstance(2016, 10, 31)
                                   ,Gender__c = 'Male'
                                   ,Name = 'Mortem'));
        patients.add(new patient__c(DateOfBirth__c = Date.newInstance(1978, 12, 25)
                                   ,Gender__c = 'Female'
                                   ,Name = 'Willma'));
        
        insert patients;
        
    }
    
    private static void createDoctors() {
        
        List<Doctor__c> doctors = new List<Doctor__c>();
        
        doctors.add(new Doctor__c(DateOfBirth__c = Date.newInstance(1998, 02, 22)
                   ,Gender__c = 'Male'
                   ,Name = 'Doctor Acula'
                   ,HourOpen__c = Time.newInstance(8, 0, 0, 0)
                   ,HourClose__c = Time.newInstance(17, 0, 0, 0)
                   ,Location__c = '123 Doc Street Reston, VA 20190'));
        
        doctors.add(new Doctor__c(DateOfBirth__c = Date.newInstance(1970, 05, 17)
                   ,Gender__c = 'Female'
                   ,Name = 'Doctor Agon'
                   ,HourOpen__c = Time.newInstance(9, 0, 0, 0)
                   ,HourClose__c = Time.newInstance(16, 0, 0, 0)
                   ,Location__c = '999 Doctor Ave Billings, MT 59101'));
        
        doctors.add(new Doctor__c(DateOfBirth__c = Date.newInstance(1998, 02, 22)
                   ,Gender__c = 'Male'
                   ,Name = 'Medic Anne'
                   ,HourOpen__c = Time.newInstance(9, 30, 0, 0)
                   ,HourClose__c = Time.newInstance(18, 0, 0, 0)
                   ,Location__c = '123 Doc Street Reston, VA 20190'));
        
        doctors.add(new Doctor__c(DateOfBirth__c = Date.newInstance(1961, 11, 29)
                   ,Gender__c = 'Female'
                   ,Name = 'Doctor Amatic'
                   ,HourOpen__c = Time.newInstance(6, 0, 0, 0)
                   ,HourClose__c = Time.newInstance(11, 30, 0, 0)
                   ,Location__c = '123 Doc Street Reston, VA 20190'));
        
        insert doctors;
    }
    
    private static void createConditions() {
        
        List<Condition__c> conditions = new List<Condition__c>();
        
        conditions.add(new Condition__c(InfermedicaId__c = 'c_111'
                                       ,Description__c = ''
                                       ,Name = 'Acne'));
        
        conditions.add(new Condition__c(InfermedicaId__c = 'c_132'
                                       ,Description__c = ''
                                       ,Name = 'Appendicitis'));
        
        conditions.add(new Condition__c(InfermedicaId__c = 'c_137'
                                       ,Description__c = ''
                                       ,Name = 'Hangover'));
        
        conditions.add(new Condition__c(InfermedicaId__c = 'c_127'
                                       ,Description__c = ''
                                       ,Name = 'Pneumonia'));
        
        insert conditions;
    }
    
    private static void createAppointments() {
        
        List<Appointment__c> appointments = new List<Appointment__c>();
        List<Patient__c> patients = [SELECT Id FROM Patient__c];
        List<Doctor__c> doctors = [SELECT Id FROM Doctor__c];
        Integer hour = 0;
        
        for (Patient__c patient : patients) {
            for (Doctor__c doctor : doctors) {
				appointments.add(new Appointment__c(Date__c = Date.today() //Date.newInstance(2019, 10, 31)
                                    				,StartTime__c = Time.newInstance(Math.mod(hour,24), 0, 0, 0)
                                                    ,Location__c = ''
                                                    ,Patient__c = patient.Id
                                                    ,Doctor__c = doctor.Id));   
                hour++;
            }    
        }
       insert appointments;
    }
    
    private static void createPossibleConditions() {
        
        List<PossibleCondition__c> possibleConditions = new List<PossibleCondition__c>();
        List<Appointment__c> appointments = [SELECT Id FROM Appointment__c];
        List<Condition__c> conditions = [SELECT Id FROM Condition__c];
        
        for (Appointment__c appointment : appointments) {
            for (Condition__c condition : conditions) {
                possibleConditions.add(new PossibleCondition__c(Appointment__c = appointment.Id
                                                               ,Condition__c = condition.Id
                                                               ,Probability__c = Math.random() * 100));
            }
        }
        insert possibleConditions;
    }
    
    private static void createSpecialties() {
        
        List<Specialty__c> specialties = new List<Specialty__c>();
        List<Doctor__c> doctors = [SELECT Id FROM Doctor__c];
        List<Condition__c> conditions = [SELECT Id FROM Condition__c LIMIT 4];
        
        for (Integer i = 0; i < conditions.size(); ++i) {
            specialties.add(new Specialty__c(Doctor__c = doctors[i].Id
                                            ,Condition__c = conditions[i].Id));
        }
        /*for (Doctor__c doctor : doctors) {
            for (Condition__c condition : conditions) {
                specialties.add(new Specialty__c(Doctor__c = doctor.Id
                               					,Condition__c = condition.Id));
            }
        }*/
        insert specialties;
    }
}