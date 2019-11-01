var monthInfo = [["January",31], ["February", 28], ["March",31], ["April", 30], ["May",31], ["June",30],
                    ["July",31], ["August",31], ["September",30], ["October",31], ["November",30], ["December",31]];
var weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
var endings = ['th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th'];
var calendar = document.getElementById("calendar");
var calendarHeader = document.getElementById("calendarHeader");
var todaysDate = new Date();
var dateInfo = {
    today: new Date(),
    currentMonth: todaysDate.getMonth(),
    currentYear: todaysDate.getFullYear(),
    dateString: ''
}


function openPopup(buttonId){
    dateInfo.dateString = buttonId;
    var dateString = dateInfo.dateString.split(',');
    document.getElementById("Doctor").innerHTML = `Doctor: ${doctor.name}`;
    document.getElementById("Patient").innerHTML = `Patient: ${patient.name}`;
    document.getElementById("Address").innerHTML = `Address: ${doctor.address}`;
    var timeString = getTimeString(dateString[3]);
    document.getElementById("Time").innerHTML = `Time: ${timeString[0]} - ${timeString[1]}`;
    document.getElementById("Date").innerHTML = `Date: ${dateString[1]}/${dateString[2]}/${dateString[0]}`;
    buttonDisable(document.getElementsByClassName("AppointmentButton"), true);
    document.getElementById("popupDiv").style.display = "grid";
}


function buttonDisable(buttons, disabled){
    for(var i=0;i<buttons.length;i++){
        buttons[i].disabled = disabled;
    }
}





function cancel(){
    document.getElementById("popupDiv").style.display = "none";
    return false;
}


/**
* create a calendar for the current month
* currentMonth var can be modified to display different months
*/
function createCalendar(){
    // display the current month and year at the top of the calendar
    calendarHeader.innerHTML = `<h1>${monthInfo[dateInfo.currentMonth][0]} ${dateInfo.currentYear}</h1>`;
    checkLeapYear();
    addDaysFromPastMonth();
    addDaysFromCurrentMonth();
    addDaysFromNextMonth();
}


function addDaysFromPastMonth(){
    var startDay = getFirstSunday();
    if(startDay!=1){
        var numberOfDaysInPreviousMonth = getNumberOfDaysInPreviousMonth();
        while(startDay<=numberOfDaysInPreviousMonth){
            createDayDiv(dateInfo.currentYear, dateInfo.currentMonth-1, startDay);
            startDay++;
        }
    }
}

function addDaysFromCurrentMonth(){
    for(var i=1;i<=monthInfo[dateInfo.currentMonth][1];i++){
        createDayDiv(dateInfo.currentYear, dateInfo.currentMonth, i);
    }
}

function addDaysFromNextMonth(){
    if(new Date(dateInfo.currentYear, dateInfo.currentMonth, monthInfo[dateInfo.currentMonth][1],0,0,0,0).getDay()!=6){
        var day = new Date(dateInfo.currentYear, dateInfo.currentMonth+1, 1,0,0,0,0).getDay();
        var j=1;
        for(i=day;i<=6;i++){
            createDayDiv(dateInfo.currentYear, dateInfo.currentMonth+1, j++);
        }
    }
}

/**
* display the next month on the calendar
*/
function next(){
    if(dateInfo.currentMonth!=11){
        dateInfo.currentMonth++;
    }
    else{
        dateInfo.currentYear++;
        dateInfo.currentMonth=0;
    }
    while (calendar.firstChild) {calendar.removeChild(calendar.firstChild);}
    createCalendar();
    document.documentElement.scrollTop = 0;  
}

/**
* display the previous month on the calendar
*/
function previous(){
    if(dateInfo.currentMonth!=0){
        dateInfo.currentMonth--;
    }
    else{
        dateInfo.currentYear--;
        dateInfo.currentMonth=11;
    }
    while (calendar.firstChild) {calendar.removeChild(calendar.firstChild);}
    createCalendar();
    document.documentElement.scrollTop = 0;
}



function getNumberOfDaysInPreviousMonth(){
    if(dateInfo.currentMonth>0){
        return monthInfo[dateInfo.currentMonth-1][1];
    }
    else{
        
        return monthInfo[11][1];
    }
}

/**
* determine if it is a leap year and adjust the number of
* days in February accordingly
*/
function checkLeapYear(){
    if(dateInfo.currentYear%4==0){
        monthInfo[1][1] = 29;
    }
    else{
        monthInfo[1][1] = 28;
    }
}


/**
* returns the Sunday at the beginning of the calendar
* typically falls in the previous month, unless Sunday is the 1st
*/
function getFirstSunday(){
    var date = new Date(dateInfo.currentYear, dateInfo.currentMonth, 1, 0, 0, 0, 0);
    if(date.getDay()==0){
        return 1;
    }
    else
    {
        startDay = getNumberOfDaysInPreviousMonth();
        // start at the endo of the month and subtract the number of days to get Sunday
        for(var i=0;i<date.getDay()-1;i++){
            startDay--;
        }
        return startDay;
    }
}

/**
* create a div that represents one day on the calendar
* @param {*} year  
* @param {*} month 
* @param {*} day 
*/
function createDayDiv(year, month, day){   
    var dayDiv = document.createElement("div");
    var dayOfTheWeek = getDayOfTheWeek(year, month, day);
    var dayEnding = getDayEnding(day);
    dayDiv.innerHTML = `<h2 class='dateHeaders'>${dayOfTheWeek} the ${day}${dayEnding}</h2>`;
    dayDiv.className = "dayDiv";
    calendar.appendChild(dayDiv);
    if(doctor.daysOpen.includes(dayOfTheWeek)){
        createButtons(dayDiv, year, month, day);
    }
    else{
        var buttonDiv = document.createElement("div");
        buttonDiv.className = "buttonDiv";
        dayDiv.appendChild(buttonDiv);
    }
}

/**
* return the string representation of the day of the week
* @param {*} year 
* @param {*} month 
* @param {*} day 
*/
function getDayOfTheWeek(year, month, day){
    var day = new Date(year, month, day, 0,0,0,0);
    return weekDays[day.getDay()];
}

/**
* return the suffix for a given day
* @param {*} day 
*/
function getDayEnding(day){
    if(day==11 || day==12 || day==13){
        return 'th';
    }
    else{
        return endings[day%10];
    }
}


/**
* create the buttons that represent the available appointments for that day
* and add them to the div representing the day
* @param {*} currentDiv the div representing the day
* @param {*} year 
* @param {*} month 
* @param {*} day 
*/
function createButtons(currentDiv, year, month, day){
    var newButton;
    var buttonDiv = document.createElement("div");
    buttonDiv.className = "buttonDiv";
    var buttonId;
    var numberOfButtons = 0;
    var timeString;
    var buttonNum = 0;
    for(var i=doctor.startTime;i<doctor.endTime;i+=doctor.durationHours){
        timeString = getTimeString(i);
        if(i%1==0){
            buttonId = `${year},${month+1},${day},${i.toFixed(1)}`;
        }
        else{
            buttonId = `${year},${month+1},${day},${i}`;
        }
        if(doctor.existingAppointments.includes(buttonId)==false){
            newButton = document.createElement("button");
            newButton.innerHTML = `${timeString[0]} - ${timeString[1]}`;
            newButton.id = buttonId;
            newButton.className = `AppointmentButton${buttonNum++%4}`;
            newButton.setAttribute("onclick", "openPopup(this.id)");
            buttonDiv.appendChild(newButton);
            numberOfButtons++;
        }
    }
    currentDiv.appendChild(buttonDiv);
}


/**
* returns the 12hr format of the start of the appointment in 24hr format
* as well as the time one hour later
* @param {*} timeOfDay start of the appointment in 24hr format
*/
function getTimeString(timeOfDay){
    var start = convertTimeToString('' + timeOfDay);
    var end = parseFloat(timeOfDay) + doctor.durationHours;
    if(end>doctor.endTime){
        end = doctor.endTime;
    }
    end = convertTimeToString('' + end);
    return [start, end];
}


function convertTimeToString(time){
    var ending;
    time = time.split('.');
    if(time[0]<12){
        ending = 'A.M.';
    }
    else{
        if(time[0]!=12){
            time[0] -= 12;
        }
        ending = 'P.M.';
    }
    if(time[1]){
        if(time[1]==0){
            time[1] = '00';
        }
        else if(time[1].length==1){
            time[1] *= 6;
        }
        else{
            time[1] *= .6;
        }
        
    }
    else{
        time[1] = '00';
    }
    return `${time[0]}:${time[1]} ${ending}`;
}