var monthInfo = [["January",31], ["February", 28], ["March",31], ["April", 30], ["May",31], ["June",30],
                    ["July",31], ["August",31], ["September",30], ["October",31], ["November",30], ["December",31]];
        var weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
        var endings = ['th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th'];
        var daysOpen = ["Monday", "Tuesday", "Wednesday", "Friday", "Saturday"];
        var existingAppointments;
        var todaysDate = new Date();
        var currentMonth = todaysDate.getMonth();
        var currentYear = todaysDate.getFullYear();
        var calendar = document.getElementById("calendar");
        var monthYear = document.getElementById("monthYear");
        var startTime;
        var endTime;
        var doctor;
        var doctorId = document.getElementById("doctor").value;
        var patient;
        var patientId = document.getElementById("patient").value;
        var address;
        var b;

        document.addEventListener('DOMContentLoaded', onWindowLoad(), false);
        /**
         * grab the office open and close times for the current doctor
         * and create the calendar
         */
        function onWindowLoad(){
            Visualforce.remoting.Manager.invokeAction(
                document.getElementById('getDoctorInfo').value, doctorId,function(result){  
                    startTime = result[0] /3600000;
                    endTime = result[1] / 3600000;
                    doctor = result[2];
                    address = result[3];
                    Visualforce.remoting.Manager.invokeAction(
                        document.getElementById('getAppointmentInfo').value, doctorId, patientId, function(result){
                            existingAppointments = result;
                            patient = result[result.length-1];
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
            var dateArray = b.split(',');
            Visualforce.remoting.Manager.invokeAction(
                document.getElementById('createAppointment').value, 
                 dateArray[0], dateArray[1], dateArray[2], dateArray[3], doctorId, patientId,function(result){}
            );
        }

        function openPopup(buttonId){
            document.getElementById("Doctor").innerHTML = `Doctor: ${doctor}`;
            document.getElementById("Patient").innerHTML = `Patient: ${patient}`;
            document.getElementById("Address").innerHTML = `Address: ${address}`;
            var timeString = getTimeString(parseInt(buttonId.split(',')[3]));
            document.getElementById("Time").innerHTML = `Time: ${timeString[0]} - ${timeString[1]}`;
            document.getElementsByClassName("AppointmentButton").disabled="true";
            document.getElementById("popupDiv").style.display = "grid";
            b = buttonId;
        }

        /**
         * create a calendar for the current month
         * currentMonth var can be modified to display different months
         */
        function createCalendar(){
            // display the current month and year at the top of the calendar
            monthYear.innerHTML = '<button onClick="previous()" id="previous">&lt</button>    '
                                     + monthInfo[currentMonth][0] + ' ' + currentYear +
                                     '    <button onClick="next()" id="next">&gt</button>';
            checkLeapYear();
            var startDay = getFirstSunday();
            // add the days from the past month
            if(startDay!=1){
                var numberOfDaysInPreviousMonth = getNumberOfDaysInPreviousMonth();
                while(startDay<=numberOfDaysInPreviousMonth){
                    createDayDiv(currentYear, currentMonth-1, startDay);
                    startDay++;
                }
            }
            // add the days for the current month
            for(var i=1;i<=monthInfo[currentMonth][1];i++){
                createDayDiv(currentYear, currentMonth, i);
            }
            // add the days for the next month
            if(new Date(currentYear, currentMonth, monthInfo[currentMonth][1],0,0,0,0).getDay()!=6){
                var day = new Date(currentYear, currentMonth+1, 1,0,0,0,0).getDay();
                var j=1;
                for(i=day;i<=6;i++){
                    createDayDiv(currentYear, currentMonth+1, j++);
                }
            }
        }

        /**
         * display the next month on the calendar
         */
        function next(){
            if(currentMonth!=11){
                currentMonth++;
            }
            else{
                currentYear++;
                currentMonth=0;
            }
            while (calendar.firstChild) {calendar.removeChild(calendar.firstChild);}
            createCalendar();   
        }

        /**
         * display the previous month on the calendar
         */
        function previous(){
            if(currentMonth!=0){
                currentMonth--;
            }
            else{
                currentYear--;
                currentMonth=11;
            }
            while (calendar.firstChild) {calendar.removeChild(calendar.firstChild);}
            createCalendar();
        }



        function getNumberOfDaysInPreviousMonth(){
            
            if(currentMonth>0){
                return monthInfo[currentMonth-1][1];
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
            if(currentYear%4==0){
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
            var date = new Date(currentYear, currentMonth, 1, 0, 0, 0, 0);
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
            var dayDiv;
            var dayOfTheWeek = getDayOfTheWeek(year, month, day);
            var dayEnding = getDayEnding(day);
            dayDiv = document.createElement("div");
            dayDiv.innerHTML = `${dayOfTheWeek} the ${day}${dayEnding}`;
            dayDiv.className = "dayDiv";
            calendar.appendChild(dayDiv);
            if(daysOpen.includes(dayOfTheWeek)){
                createButtons(dayDiv, year, month, day);
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
            for(var i=startTime;i<endTime;i++){
                timeString = getTimeString(i);
                buttonId = `${year},${month+1},${day},${i}`;
                if(existingAppointments.includes(buttonId)==false){
                    newButton = document.createElement("button");
                    newButton.innerHTML = `${timeString[0]} - ${timeString[1]}`;
                    newButton.id = buttonId;
                    newButton.className = "AppointmentButton";
                    newButton.setAttribute("onclick", "openPopup(this.id)");
                    buttonDiv.appendChild(newButton);
                    numberOfButtons++;
                }
            }
            numberOfButtons *= 2.1;
            buttonDiv.style = `margin-bottom: ${numberOfButtons}px`;
            currentDiv.appendChild(buttonDiv);
        }


        /**
         * returns the 12hr format of the start of the appointment in 24hr format
         * as well as the time one hour later
         * @param {*} timeOfDay start of the appointment in 24hr format
         */
        function getTimeString(timeOfDay){
            var start;
            var end;
            if(timeOfDay<11){
                start = `${timeOfDay} A.M.`;
                end =  `${timeOfDay+1} A.M.`;
            }
            else if(timeOfDay==11){
                start = `${timeOfDay} A.M.`;
                end = `${timeOfDay+1} P.M.`;
            }
            else if(timeOfDay==12){
                start = `${timeOfDay} P.M.`;
                end = `1 P.M.`;
            }
            else{
                start = `${timeOfDay-12} P.M.`;
                end = `${timeOfDay-11} P.M.`;
            }
            var timeArray = [start, end];
            return timeArray;
        }