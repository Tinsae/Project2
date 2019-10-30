public class DataCreator {
    public static void createData() {
		deleteExistingData();
        
        createAccount();
        createContacts();
        createDoctors();
        createConditions();
        
        // Lookup(Doctor)
        // Lookup(Contact)
        createAppointments();
        
        // Lookup(Appointment)
        // Lookup(Condition)
        createPossibleConditions();
         
        // Lookup(Doctor)
        // Lookup(Condition)
        createSpecialties();

        createSymptoms();
    }
    
    private static void deleteExistingData() {
        deleteExistingPossibleConditions();
        deleteExistingAppointments();
        deleteExistingSpecialties();
        deleteExistingConditions();
        deleteExistingSymptoms();
        deleteExistingContacts();
        deleteExistingAccount();
        deleteExistingDoctors();
    }
    
    private static void deleteExistingSymptoms() { delete [SELECT Id FROM Symptom__c]; }
    private static void deleteExistingAccount() { delete [SELECT Id FROM Account]; }
    private static void deleteExistingContacts() { delete [SELECT Id FROM Contact]; }
    private static void deleteExistingAppointments() { delete [SELECT Id FROM Appointment__c]; }
    private static void deleteExistingDoctors() { delete [SELECT Id FROM Doctor__c]; }
    private static void deleteExistingSpecialties() { delete [SELECT Id FROM Specialty__c]; }
    private static void deleteExistingPossibleConditions() { delete [SELECT Id FROM PossibleCondition__c]; }
    private static void deleteExistingConditions() { delete [SELECT Id FROM Condition__c]; }
    
    private static void createAccount() {
        Account account = new Account(Name = 'Patient Account');
        insert account;
    }

    private static void createContacts() {

        List<Contact> contacts = new List<Contact>();
        Account account = [SELECT Id FROM Account LIMIT 1];

        contacts.add(new Contact(Birthdate = Date.newInstance(1945, 01, 01)
                                ,FirstName = 'Sylvestor'
                                ,LastName = 'Smallone'
                                ,Sex__c = 'Male'
                                ,AccountId = account.Id));

        contacts.add(new Contact(Birthdate = Date.newInstance(1947, 12, 07)
                                   ,Sex__c = 'Female'
                                   ,FirstName = 'Adrienne'
                                   ,LastName = 'Ann'
                                   ,AccountId = account.Id));

        contacts.add(new Contact(Birthdate = Date.newInstance(2016, 10, 31)
                                   ,Sex__c = 'Male'
                                   ,FirstName = 'Mortem'
                                   ,LastName = 'Hartzell'
                                   ,AccountId = account.Id));

        contacts.add(new Contact(Birthdate = Date.newInstance(1978, 12, 25)
                                   ,Sex__c = 'Female'
                                   ,FirstName = 'Willma'
                                   ,LastName = 'Willy'
                                   ,AccountId = account.Id));

        insert contacts;
    }
    
    private static void createDoctors() {
        
        List<Doctor__c> doctors = new List<Doctor__c>();
        
        doctors.add(new Doctor__c(Birthdate__c = Date.newInstance(1998, 02, 22)
                   ,Sex__c = 'Male'
                   ,Name = 'Doctor Acula'
                   ,HourOpen__c = Time.newInstance(8, 0, 0, 0)
                   ,HourClose__c = Time.newInstance(17, 0, 0, 0)
                   ,Location__c = '123 Doc Street Reston, VA 20190'
                   ,DaysOpen__c = 'Monday;Wednesday;Friday'
                   ,DurationHrs__c = 2
                   ,DurationMin__c = 30));
        
        doctors.add(new Doctor__c(Birthdate__c = Date.newInstance(1970, 05, 17)
                   ,Sex__c = 'Female'
                   ,Name = 'Doctor Agon'
                   ,HourOpen__c = Time.newInstance(9, 0, 0, 0)
                   ,HourClose__c = Time.newInstance(16, 0, 0, 0)
                   ,Location__c = '999 Doctor Ave Billings, MT 59101'
                   ,DaysOpen__c = 'Monday;Tuesday;Wednesday;Thursday;Friday'
                   ,DurationHrs__c = 1
                   ,DurationMin__c = 15));
        
        doctors.add(new Doctor__c(Birthdate__c = Date.newInstance(1998, 02, 22)
                   ,Sex__c = 'Male'
                   ,Name = 'Medic Anne'
                   ,HourOpen__c = Time.newInstance(9, 30, 0, 0)
                   ,HourClose__c = Time.newInstance(18, 0, 0, 0)
                   ,Location__c = '123 Doc Street Reston, VA 20190'
                   ,DaysOpen__c = 'Sunday;Monday;Tuesday;Wednesday;Thursday'
                   ,DurationHrs__c = 0
                   ,DurationMin__c = 45));
        
        doctors.add(new Doctor__c(Birthdate__c = Date.newInstance(1961, 11, 29)
                   ,Sex__c = 'Female'
                   ,Name = 'Doctor Amatic'
                   ,HourOpen__c = Time.newInstance(6, 0, 0, 0)
                   ,HourClose__c = Time.newInstance(11, 30, 0, 0)
                   ,Location__c = '123 Doc Street Reston, VA 20190'
                   ,DaysOpen__c = 'Sunday;Monday;Wednesday;Friday;Saturday'
                   ,DurationHrs__c = 1
                   ,DurationMin__c = 45));
        
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
        List<Contact> patients = [SELECT Id FROM Contact];
        List<Doctor__c> doctors = [SELECT Id FROM Doctor__c];
        Integer hour = 0;
        
        for (Contact patient : patients) {
            for (Doctor__c doctor : doctors) {
				appointments.add(new Appointment__c(Date__c = Date.today() //Date.newInstance(2019, 10, 31)
                                    				,StartTime__c = Time.newInstance(Math.mod(hour,24), 0, 0, 0)
                                                    ,Location__c = ''
                                                    ,Contact__c = patient.Id
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
        insert specialties;
    }

    private static void createSymptoms() {
        List<Symptom__c> symptoms = new List<Symptom__c>();

        symptoms.add(new Symptom__C(InfermedicaId__c = 's_1277'
                    ,Name = 'Decreased tongue motility'));

        symptoms.add(new Symptom__C(InfermedicaId__c = 's_124'
                    ,Name = 'Scotoma, eye floaters'));

        symptoms.add(new Symptom__C(InfermedicaId__c = 's_1561'
                    ,Name = 'Xanthoma'));

        symptoms.add(new Symptom__C(InfermedicaId__c = 's_1183'
                    ,Name = 'Winterbottom\'s sign'));

        symptoms.add(new Symptom__C(InfermedicaId__c = 's_478'
                    ,Name = 'Facial pain'));

        symptoms.add(new Symptom__C(InfermedicaId__c = 's_1283'
                    ,Name = 'Cogwheel muscle rigidity'));

        insert symptoms;
    }
}