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

/**
 * return a string for the appointment startTime with the hours and
 * minutes separated by a comma
 * @param {*} time 
 */
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
