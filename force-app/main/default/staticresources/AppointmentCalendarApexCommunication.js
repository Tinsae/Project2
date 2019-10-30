var doctor = {
    id:document.getElementById("doctor").value,
    name: '',
    startTime: 0,
    endTime: 0,
    durationHours: 2.5,
    daysOpen: [],
    existingAppointments: [],
    address: '',
};
var patient = {
    id: document.getElementById("patient").value,
    name: ''
};



document.addEventListener('DOMContentLoaded', onWindowLoad(), false);

/**
    * grab the office open and close times for the current doctor
    * and create the calendar
    */
function onWindowLoad(){
    Visualforce.remoting.Manager.invokeAction(
        document.getElementById('getDoctorInfo').value, doctor.id,function(result){
            doctor.startTime = parseInt(result.startTime) /3600000;
            doctor.endTime = parseInt(result.endTime) / 3600000;
            doctor.name = result.doctorName;
            doctor.address = result.doctorAddress;
            doctor.daysOpen = result.daysOpen.split(';');
            doctor.durationHours = result.durationHours + (result.durationMinutes/60);
            Visualforce.remoting.Manager.invokeAction(
                document.getElementById('getAppointmentInfo').value, doctor.id, patient.id, function(result){
                    doctor.existingAppointments = result.existingAppointments;
                    patient.name = result.patientName;
                    createCalendar();
            });
        }
    );
}

/**
    * call the apex function that creates an appointment
    * @param {*} buttonId the date and time of the appointment in the format
    * year,month,day,time
    */
function createAppointment(){
    var dateArray = dateInfo.dateString.split(',');
    dateArray[3] = getAppointmentStartTime(dateArray[3]);
    Visualforce.remoting.Manager.invokeAction(
        document.getElementById('createAppointment').value, 
            dateArray[0], dateArray[1], dateArray[2], dateArray[3], doctor.id, patient.id,function(result){}
    );
}

function getAppointmentStartTime(time){
    var startTime = '' + time;
    startTime = startTime.split('.');
    if(startTime[1]){
        if(startTime[1].length==1){
            startTime[1] *= 6;
        }
        else{
            startTime[1] *= .6
        }
    }
    else{
        startTime[1]=0;
    }
    return startTime;
}
