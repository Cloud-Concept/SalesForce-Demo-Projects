//We keep the itinerary meta data seperate from the itinerary list so we don't have to worry about re-ordering
//it etc.
var itineraryMetaData = [];
var routeLegNames = [];    
var unsavedChanges = false;

function ClearGeocode()
{
    mapIFrame.bingMapsSearchLayer.DeleteAllShapes();
    document.getElementById('SearchInputValue').value = "";
}
    
function Geocode()
{
    var onlyRouteStops = document.getElementById("MapOnlyRouteStops");
    
    if( onlyRouteStops.checked == true )
    {
        onlyRouteStops.checked = false;
        mapIFrame.FilterMapToStops();
    }
    
    mapIFrame.Geocode(document.getElementById('SearchInputValue').value);
}

//Clear the current route   
function ClearRoute()
{
    //When we clear we also remove the list elements, though leave the list intact.
    j$('#routelist li').remove();
    itineraryMetaData = [];
    mapIFrame.itineraryLayer.DeleteAllShapes();
    unsavedChanges = false
    InvalidateRoute();
    
    //Check that our layers are ok...
    if( !mapIFrame.salesforceSearchLayer.IsVisible() )
    {
        mapIFrame.salesforceSearchLayer.Show();
        mapIFrame.UpdateForBoundingBox();
    }
}

function InvalidateRoute()
{
    mapIFrame.InvalidateRoute();

    j$('#routeResultsAccordion').empty();
    document.getElementById("DisplayTrip").style.visibility = 'hidden';
    setActiveTab('search');
    
    RenumberItinerary();
}

//Calculate route based on the routelist waypoint order
function CalculateRoute(alertIfNotValidRoute)
{   
    try
    {                   
        j$('#routeResultsAccordion').empty();
                    
        //Enumerate our route to find... using the ID to define the order of waypoints
        var routeToFind = [];
        routeLegNames = [];
        
        jQuery.each(j$('#routelist li'), function(index, value)
        {
            routeToFind.push(itineraryMetaData[j$(value).attr('id')].mapDisplayLatLong);
            routeLegNames.push(itineraryMetaData[j$(value).attr('id')].name);
        })
                    
        if( routeToFind.length < 2 )
        {
            if( alertIfNotValidRoute == true )
                alert('Please add two or more stops to calculate a route');
        }
        else
        {                        
            mapIFrame.CalculateRoute(routeToFind, routeLegNames);
            setActiveTab('route');                
        }            
    }
    catch(Error)
    {
        alert(Error);
    }
}  

function ShowTripSummary( summaryDetails )
{
    //Lets display the trip details in the summary window
    document.getElementById("DisplayTrip").style.visibility = 'visible';            

    var tripSummary = document.getElementById("TripLeftPaneSummary");                
    tripSummary.innerHTML = summaryDetails;                 
}

function AppendToRouteAccordion(accordianEntry, resetAccordion)
{
    if( resetAccordion )
    {
        j$('#routeResultsAccordion').append(accordianEntry)
            .accordion('destroy').accordion({
                collapsible: true,
                autoHeight: false
            });            
    }
    else
    {
        j$('#routeResultsAccordion').append(accordianEntry);           
    }    
}

function AddSalesforceTableItemToRoute(recordId, name)
{
    if( j$('#routelist li').size() == 24 )
    {
        alert('Sorry, only 24 stops may be added to a trip');
        return;
    }
    
    AddSalesforcePushpinToRoute(recordId, false);
    
    alert(name + " was added to the trip as stop number " + j$('#routelist li').size() );
}

function AddSalesforcePushpinToRoute(recordId, addToStart)
{
    var salesforceRecordDetail = salesforceRecordArray[recordId];

    var name = salesforceRecordDetail[0];
    var mapDisplayLatitude = salesforceRecordDetail[1];
    var mapDisplayLongitude = salesforceRecordDetail[2];
    var id = salesforceRecordDetail[3];
    var routingLatitude = salesforceRecordDetail[4];
    var routingLongitude = salesforceRecordDetail[5];
    var bestMapViewTopLeftLatitude = salesforceRecordDetail[6];
    var bestMapViewTopLeftLongitude = salesforceRecordDetail[7];
    var bestMapViewBottomRightLatitude = salesforceRecordDetail[8];
    var bestMapViewBottomRightLongitude = salesforceRecordDetail[9];
    var subtitle = salesforceRecordDetail[10];
    var parentRecordType = salesforceRecordDetail[11];

    var mapDisplayLatLong = mapIFrame.GetVELatLong(mapDisplayLatitude, mapDisplayLongitude);
    var routeLatLong = mapIFrame.GetVELatLong(routingLatitude, routingLongitude);
    var bestMapViewTopLeft = mapIFrame.GetVELatLong(bestMapViewTopLeftLatitude, bestMapViewTopLeftLongitude);
    var bestMapViewBottomRight = mapIFrame.GetVELatLong(bestMapViewBottomRightLatitude, bestMapViewBottomRightLongitude);

    mapIFrame.AddToRoute(id, name, subtitle, mapDisplayLatLong, routeLatLong, bestMapViewTopLeft, bestMapViewBottomRight, parentRecordType, addToStart, false);
    
    unsavedChanges = true;
}

//Add placename with corresponding latlong to the route    
function AddToRouteList(id, name, subtitle, mapDisplayLatLong, routeLatLong, bestMapViewTopLeft, bestMapViewBottomRight, parentType, prepend, logCall, itineraryShape)
{
    if( j$('#routelist li').size() == 24 )
    {
        alert('Sorry, only 24 stops may be added to a trip');
        return;
    }

    document.getElementById("WelcomePane").style.display = 'none';            
    document.getElementById("DisplayTrip").style.display = 'inline';            
    document.getElementById("DisplayTrip").style.visibility = 'visible';            
    document.getElementById("TripPane").style.display = 'none';

    var shapes = new Array();

    //Invalidate the current route, if any
    InvalidateRoute();    

    //We're goint to add a lat/long to our list of points. As the waypoints can be re-ordered, lets keep a ref to these
    var index = itineraryMetaData.length; 

    //We need to keep a record of lat/long and other detail for each point        
    var itineraryPoint = [];

    itineraryPoint.id = id;
    itineraryPoint.name = name;    
    itineraryPoint.subtitle = subtitle;
    itineraryPoint.mapDisplayLatLong = mapDisplayLatLong;
    itineraryPoint.routeLatLong = routeLatLong;
    itineraryPoint.bestMapViewTopLeft = bestMapViewTopLeft;
    itineraryPoint.bestMapViewBottomRight = bestMapViewBottomRight;
    itineraryPoint.parentType = parentType;
    itineraryPoint.itineraryShape = itineraryShape;
    itineraryPoint.logCall = logCall;
    itineraryPoint.index = index;
            
    itineraryMetaData.push(itineraryPoint);
 
    var text = GetSortableText(index, 0, name);       
             
    if( prepend )
    {                   
        j$('#routelist').prepend(text);                    
    }
    else
    {                   
        j$('#routelist').append(text);                    
    }

    RegisterRouteListEvents();

    unsavedChanges = true;
    RenumberItinerary();    
}    

function GetSortableText(index, number, name)
{
    return "<li id=" +
        "\'" + 
        index + 
        "\' " + 
        " class=\"ui-state-default\"><span class=\"ui-icon ui-icon-arrowthick-2-n-s\"></span>" +
        number + ".  " + name +
        "<span class=\"closeButton\"><button class=\"ui-icon ui-icon-closethick ui-state-default\" ></button></span>" +
        "</li>";
}

function RenumberItinerary()
{
    var position = 1;
    
    jQuery.each(j$('#routelist li'), function(index, value)
    {
        mapIFrame.SetRouteIconNumber( itineraryMetaData[j$(value).attr('id')].itineraryShape, position );
        
        //OK, now update the sortable text
        var text = GetSortableText(itineraryMetaData[j$(value).attr('id')].index, position, itineraryMetaData[j$(value).attr('id')].name);               
        j$(value).replaceWith(text);
        
        position++;    
    })

    RegisterRouteListEvents();
}

function RemoveFromItinerary(Id)
{
    jQuery.each(j$('#routelist li'), function(index, value)
    {   
        if( itineraryMetaData[j$(value).attr('id')].id == Id )
        {
            //itineraryLayer.DeleteShape( itineraryMetaData[j$(value).attr('id')].itineraryShape );
            mapIFrame.DeleteShape( itineraryMetaData[j$(value).attr('id')].itineraryShape );
            j$(value).remove(); 
            j$("#routelist").sortable('refresh'); 
            InvalidateRoute();                    
        }
    })
    
    unsavedChanges = true;    
}

//Create a function for passing XML data for stop detail to the server
function SerializeItineraryXml()
{
    var returnXml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><WVItineraryStopDetail>";
    
    jQuery.each(j$('#routelist li'), function(index, value)
    {
        var itineraryPoint = itineraryMetaData[j$(value).attr('id')];
    
        returnXml += "<Record>";                    
        returnXml += AddXmlNode("StandardRecordId", itineraryPoint.id);
        returnXml += AddXmlNode("DisplayName", itineraryPoint.name);
        returnXml += AddXmlNode("Subtitle", itineraryPoint.subtitle);
        returnXml += AddXmlLatLongNodes("MapDisplay", itineraryPoint.mapDisplayLatLong);
        returnXml += AddXmlLatLongNodes("Route", itineraryPoint.routeLatLong);
        returnXml += AddXmlLatLongNodes("BestMapViewTopLeft", itineraryPoint.bestMapViewTopLeft);
        returnXml += AddXmlLatLongNodes("BestMapViewBottomRight", itineraryPoint.bestMapViewBottomRight);
        returnXml += AddXmlNode("ParentRecordType", itineraryPoint.parentType);
        returnXml += AddXmlBooleanNode("LogCall", itineraryPoint.logCall);        
        returnXml += "</Record>";                    
    })
    
    returnXml += "</WVItineraryStopDetail>";

    return returnXml;
}

var tripMouseDownList = [];
var tripMouseUpList = [];
var closeButtonAction = false;

function RegisterRouteListEvents()
{          
    j$("#routelist  li").find("button").css('visibility', 'hidden');

    j$(function(){ j$("#routelist  li") 
            .hover( 
                  function(){                   
                      j$(this).addClass("ui-state-hover");
                      j$(this).find("button").css('visibility', 'visible');
                  },
                  function(){ 
                    j$(this).find("button").css('visibility', 'hidden');
                      j$(this).removeClass("ui-state-hover");
                  }) ;                                     
    }); 

    j$(function() {                     
            j$("#routelist > li button").mousedown(function(event) {
                            
                event.preventDefault();
                closeButtonAction = true;
            } );
    }); 

    j$(function() {                     
            j$("#routelist > li button").click(function(event) {
                            
                event.preventDefault();                
                
                j$(this).parent().parent().remove(); 
                mapIFrame.DeleteShape( itineraryMetaData[j$(this).parent().parent().attr('id')].itineraryShape );
                j$("#routelist").sortable('refresh'); 
                InvalidateRoute();
            } );
    }); 

    j$(function() {                     
            j$("#routelist").bind("sortupdate", function(event, ui) {                
                unsavedChanges = true;
            } );                
    });    

    j$(function() {                     
            j$("#routelist > li").mousedown(function(event) {
                event.preventDefault();

                tripMouseDownList = [];
                
                if( closeButtonAction == false )
                {                                                    
                    jQuery.each(j$('#routelist li'), function(index, value)
                    {
                        tripMouseDownList.push(j$(value).attr('id'));
                    })
                }
            } );                
    });                     

    j$(function() {                     
            j$("#routelist > li").mouseup(function(event) {                

                event.preventDefault();
                var zoomOnUp = false;
                
                tripMouseUpList = [];
                                         
                jQuery.each(j$('#routelist li'), function(index, value)
                {
                    tripMouseUpList.push(j$(value).attr('id'));
                })
                
                if( tripMouseDownList.length == tripMouseUpList.length )
                {
                    for( var count=0; count<tripMouseDownList.length; count++ )
                    {
                        if( tripMouseDownList[count] != tripMouseUpList[count] )
                        {
                            break;
                        }
                        
                        zoomOnUp = true;  
                    }
                }
                
                if( zoomOnUp )
                {
                    var bestMapViewTopLeft = itineraryMetaData[j$(this).attr('id')].bestMapViewTopLeft;
                    var bestMapViewBottomRight = itineraryMetaData[j$(this).attr('id')].bestMapViewBottomRight;
                    
                    if(  bestMapViewTopLeft && bestMapViewBottomRight )
                    {
                        mapIFrame.SetBestMapView( bestMapViewTopLeft, bestMapViewBottomRight );
                    }
                    else //if we don't have a best map view, we can set to level 15 for the map view
                    {
                        var location = itineraryMetaData[j$(this).attr('id')].mapDisplayLatLong;
                        wvMap.SetCenterAndZoom(location, 15);                    
                    }
                    
                    mapIFrame.UpdateForBoundingBox();
                }
                
                closeButtonAction = false;            
            } );                
    });                     
}   
  
