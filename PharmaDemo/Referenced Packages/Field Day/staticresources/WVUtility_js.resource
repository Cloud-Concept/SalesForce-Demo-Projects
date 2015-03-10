//-------------------------------------------------------------------------------
//Wherevantage utility helper functions for time and other 
//-------------------------------------------------------------------------------

function HourToDisplay(hour)
{
    return hour + 'h';                      
}

function MinuteToDisplay(minute)
{
    var timeEntry = minute + 'm';

    if( timeEntry.length < 3 )
    {
        timeEntry = '0' + timeEntry;
    }  
     
    return timeEntry;
}
 
function DisplayTimeToInteger(timeValue)
{
    return parseInt(timeValue.substring(0, timeValue.length-1));
}
                   
function DecodeTimeDisplayValues(TimeIn)
{
    var returnTime = '';
    
    for( var count=0; count<TimeIn.length-1; count++ )
    {
        returnTime += TimeIn[count];
    }
    
    return returnTime;
}                    
                    
function HoursAndMinutesToSeconds(HoursIn, MinutesIn)
{
    var timeSeconds = MinutesIn * 60;
    timeSeconds += HoursIn * 3600;
    return timeSeconds;
}

function TimeOfDayToSeconds(HoursIn, MinutesIn, IsAm)
{
    var timeSeconds = MinutesIn * 60;

    if( !IsAm )
    {
        timeSeconds += 43200;
    }        
    
    if( HoursIn != 12 )
    {
        timeSeconds += HoursIn * 3600;
    }
    
    return timeSeconds;
}
          
//Converts seconds to the time of day in 12 hour format with am/pm
function SecondsToTimeOfDay(SecondsIn)
{
    var timeSeconds = parseInt(SecondsIn, 10);
    timeSeconds %= 86400;
    var hour = Math.floor(timeSeconds / 3600);

    var isAm = true;
    
    if(hour > 12)
    {
        hour = hour - 12;
    }    
    
    if( hour < 24 && hour >= 12 )
    {                    
        isAm = false;    
    }
    
    if( hour == 0 )
    {                    
        hour = 12;
    }
    
    timeSeconds %= 3600;
    var minutes = Math.floor(timeSeconds / 60);
    var minutesString = '' + minutes;
    
    if( minutesString.length == 1 )
    {
        minutesString = '0' + minutesString;
    }
    
    var ampmField = isAm ? 'am' : 'pm';
    return hour + ':' + minutesString + ampmField; 
}

//Converts seconds to an hour and minutes string 
function SecondsToHourAndMinutesString(SecondsIn)
{
    var timeSeconds = parseInt(SecondsIn, 10);
    var hour = Math.floor(timeSeconds / 3600);
    timeSeconds %= 3600;
    var minutes = Math.floor(timeSeconds / 60);

    if( hour != 0 )
    {
        return hour + ' hr ' + minutes + ' min';            
    }
    else
    {
        return minutes + ' min';            
    }
}


//Note: we encode the single and double quote string so they play nice in HTML display. These technically don't need
//to be encoded for HTML, but we do need to encode as we sometimes use string to build Javascript call functions.
//HTML doesn't recognize XML encode for these two, so encoding as characters.
function XmlEncode(input)
{	
    if( !ActionableObject(input) )
    {
        return '';
    }
    
    input = input.toString();
    
	var replace	=	'&amp;';
	input = input.replace(/&/g,	replace);
	replace = '&lt;';
	input = input.replace(/</g,	replace);
	replace = '&gt;';
	input = input.replace(/>/g,	replace);
	replace = '&#39;';
	input = input.replace(/'/g,	replace);
	replace = '&#34;';
	input = input.replace(/"/g,	replace);
	
	return input;
}

//format lat long such that it can be used in javascript parameter
function LatLongFunctionParam(latitude, longitude)
{
    return "new VELatLong(" + latitude + "," + longitude + ")";            
}

//Add Lat Long xml nodes
function AddXmlLatLongNodes( name, value )
{
    if( !ActionableObject(value) )
    {
        return '';
    }
    
    var nodeString = "<" + name + "Latitude>";
    nodeString += value.Latitude;
    nodeString += "</" + name + "Latitude>";
    
    nodeString += "<" + name + "Longitude>";
    nodeString += value.Longitude;
    nodeString += "</" + name + "Longitude>";
    
    return nodeString;
}

//Add an xml node
function AddXmlNode( name, value )
{
    if( !ActionableObject(value) )
    {
        return '';
    }
    
    var nodeString = "<" + name + ">";
    nodeString += XmlEncode(value);
    nodeString += "</" + name + ">";
    
    return nodeString;
}

//Add an xml node
function AddXmlBooleanNode( name, value )
{
    if( value == undefined || value == null )
    {
        return ''; 
    }
    
    var nodeString = "<" + name + ">";
    
    if( value )
    {
        nodeString += "true";
    }
    else
    {
        nodeString += "false";
    }
    
    nodeString += "</" + name + ">";
    
    return nodeString;
}

//Check to see if the object is actionable such as for serialization
function ActionableObject(value)
{
    //Check null
    if( value == null )
    {
        return false;
    }

    //Check undefined
    if(typeof value == "undefined")
    {
        return false;
    }

    if(typeof value == "string")
    {
        return true;
    }
    
    //Check empty
    for( var property in value )
    {
        return true;
    }
     
    return false;
}