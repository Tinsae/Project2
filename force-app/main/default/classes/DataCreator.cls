public class DataCreator {
    public static void createData() {
	    deleteExistingData();
        
        createAccount();
        createDoctors();
         
        // The Specialty__c object has lookups to Doctor__c and Condition__c
        createSpecialties();
    }
    
    private static void deleteExistingData() {
        deleteExistingPossibleConditions();
        deleteExistingAppointments();
        deleteExistingSpecialties();
        deleteExistingContacts();
        deleteExistingAccount();
        deleteExistingDoctors();
    }
    
    private static void deleteExistingAccount() { delete [SELECT Id FROM Account]; }
    private static void deleteExistingContacts() { delete [SELECT Id FROM Contact]; }
    private static void deleteExistingAppointments() { delete [SELECT Id FROM Appointment__c]; }
    private static void deleteExistingDoctors() { delete [SELECT Id FROM Doctor__c]; }
    private static void deleteExistingSpecialties() { delete [SELECT Id FROM Specialty__c]; }
    private static void deleteExistingPossibleConditions() { delete [SELECT Id FROM PossibleCondition__c]; }
    
    private static void createAccount() {
        Account account = new Account(Name = 'Patient Account');
        insert account;
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
        
        doctors.add(new Doctor__c(Birthdate__c = Date.newInstance(1961, 09, 19)
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

        doctors.add(new Doctor__c(Birthdate__c = Date.newInstance(1978, 02, 22)
                   ,Sex__c = 'Male'
                   ,Name = 'Calvin Franhs'
                   ,HourOpen__c = Time.newInstance(11, 0, 0, 0)
                   ,HourClose__c = Time.newInstance(15, 0, 0, 0)
                   ,Location__c = '11730 Plaza America Dr. Reston, VA 20190'
                   ,DaysOpen__c = 'Monday;Tuesday;Wednesday;Thursday;Friday'
                   ,DurationHrs__c = 2
                   ,DurationMin__c = 45));

        doctors.add(new Doctor__c(Birthdate__c = Date.newInstance(1940, 10, 22)
                   ,Sex__c = 'Female'
                   ,Name = 'Berta Green'
                   ,HourOpen__c = Time.newInstance(6, 0, 0, 0)
                   ,HourClose__c = Time.newInstance(12, 0, 0, 0)
                   ,Location__c = '4000 Hall Ct. Pomona, IL 19851'
                   ,DaysOpen__c = 'Saturday;Sunday'
                   ,DurationHrs__c = 1
                   ,DurationMin__c = 0));
        
        insert doctors;
    }
    
    private static void createSpecialties() {
        
        List<Specialty__c> specialties = new List<Specialty__c>();
        List<Doctor__c> doctors = [SELECT Id FROM Doctor__c];
        List<Condition__c> conditions = [SELECT Id FROM Condition__c];

        // Divide the conditions up evenly among the doctors
        Integer size = doctors.size();
        for (Integer i = 0; i < conditions.size(); ++i) {

            specialties.add(new Specialty__c(Doctor__c = doctors[Math.mod(i,size)].Id
                                            ,Condition__c = conditions[i].Id));
        }
        insert specialties;
    }
}
