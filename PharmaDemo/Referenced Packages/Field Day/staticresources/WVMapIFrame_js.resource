<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>VE Map</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script src="https://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=6.3&s=1"></script>
	
<script>
 
var wvMap = null;

//Layer management
var itineraryLayer = new VEShapeLayer();
var itineraryRouteLayer = new VEShapeLayer();            
var salesforceSearchLayer = new VEShapeLayer();            
var bingMapsSearchLayer = new VEShapeLayer();

var customIcon = new VECustomIconSpecification();        
var routeIcon = new VECustomIconSpecification();

var onEndMapMoveTimer = null;

var routeLegNames;

// I don't want to hammer Salesforce unncessarily. The following give the refresh times after pan or zoom before hitting SF 
var onEndMapMoveTimout = 1000;

function GetMap(credentials, bestMapView)
{
	wvMap = new VEMap('myMap');
    var mapOptions = new VEMapOptions();
    mapOptions.UseEnhancedRoadStyle = true;
    wvMap.SetCredentials(credentials);    
    wvMap.LoadMap(null, null, null, null, null, false, 0, mapOptions);     
	
    wvMap.AddShapeLayer(salesforceSearchLayer);
    wvMap.AddShapeLayer(itineraryLayer);
    wvMap.AddShapeLayer(itineraryRouteLayer);
    wvMap.AddShapeLayer(bingMapsSearchLayer);
    
    wvMap.AttachEvent("onstartzoom",OnStartZoom);
    wvMap.AttachEvent("onstartpan",OnStartPan);        
    wvMap.AttachEvent("onendzoom",OnEndZoom);
    wvMap.AttachEvent("onendpan",OnEndPan);
    
    wvMap.AttachEvent("onclick",PushpinClick);
    wvMap.AttachEvent('onmouseover', function(e) { if(e.elementID) return true; });	

    wvMap.SetMapView(bestMapView);
    
    InitializeIcons();    
}

function InitializeIcons()
{
    //Custom and route icons share the same image, but only route has text                
    customIcon.ImageOffset = new VEPixel(0, -24);

    routeIcon.ImageOffset = new VEPixel(0, -24);                
    routeIcon.TextContent = "1";
    routeIcon.TextOffset = new VEPixel(7,-18);
    routeIcon.TextFont='Arial';
    routeIcon.TextBold=true;
    routeIcon.TextSize=10;
    routeIcon.Image = parent.GetRouteIcon();
}

function CalculateRoute(myRouteToFind, myRouteLegNames)
{
    var routeOptions = new VERouteOptions();
    routeOptions.DrawRoute = false;
    routeOptions.RouteCallback = OnGotRoute;
    
    routeLegNames = myRouteLegNames;
    wvMap.GetDirections(myRouteToFind, routeOptions);    
}

function InvalidateRoute()
{
    if( wvMap != null )
    {   
        itineraryRouteLayer.DeleteAllShapes();
    }
}

function SetRouteIconNumber(shape, position)
{
    shape.SetCustomIcon(GetRouteIconNumber(position));
}

function GetRouteIconNumber(position)
{
    //Update the icon number
    routeIcon.TextContent = position + "";
    
    if( routeIcon.TextContent.length > 1 )
    {
        routeIcon.TextOffset.x = 5;
        routeIcon.TextOffset.y = -19;        
    }
    else
    {
        routeIcon.TextOffset.x = 9;
        routeIcon.TextOffset.y = -19;        
    }
    
    return routeIcon;
}

function SetMapCenter(lat, lng)
{
	wvMap.SetCenter(new VELatLong(lat,lng));
}
	
//We override hover to support click for pushpins
function PushpinClick(e)
{
    // elementID is null when someone clicks on the map and not on a shape
    if(e.elementID) {

        var shape = wvMap.GetShapeByID(e.elementID); 
        if(shape)wvMap.ShowInfoBox(shape);
    }     
}        
	
function Geocode(searchInputValue)
{
    //Clear out the previous results, if any
    bingMapsSearchLayer.DeleteAllShapes();

    var options = new VESearchOptions();
    options.CreateResults = false;
        
    wvMap.Search(searchInputValue, findCallback, options);
}

function findCallback(layer, findResults, placeResults, moreResults, error)
{
    // if there are no results, display an error message and return
   if(placeResults == null && findResults == null)
   {
      alert( (error == null) ? "No results were found" : error );
      return;
   }    

    //If we have find results such as those for business listings then these should take precedence
    if( findResults )
    {
        for( var count=0; count<findResults.length; count++ )
        {
            var newShape = new VEShape(VEShapeType.Pushpin, findResults[count].LatLong);
            newShape.SetTitle(findResults[count].Name);
        
            var desc = ""; 
            
            if( parent.ActionableObject(findResults[count].Phone) )
            {
                desc += findResults[count].Phone;
                desc += "<br></br>";
            }
            
            if( parent.ActionableObject(findResults[count].Description) )
            {
                desc += findResults[count].Description;
                desc += "<p></p>";
            }
                        
            customIcon.Image = parent.GetIconForRecordType(null);
            newShape.SetCustomIcon(customIcon);
            
            bingMapsSearchLayer.AddShape(newShape);
            
            desc += BingResultPushpinRouteString(findResults[count].Name, findResults[count].LatLong, "Add to trip", null, null, false, newShape.GetID());
            newShape.SetDescription(desc);            
        }
    }    
    else if( placeResults )
    {
        for( var count=0; count<placeResults.length; count++ )
        {
            var newShape = new VEShape(VEShapeType.Pushpin, placeResults[count].LatLong);
            newShape.SetTitle(placeResults[count].Name);
            
            customIcon.Image = parent.GetIconForRecordType(null);
            newShape.SetCustomIcon(customIcon);
            
            bingMapsSearchLayer.AddShape(newShape);

            var desc = BingResultPushpinRouteString(placeResults[count].Name, placeResults[count].LatLong, "Add to trip", wvMap.GetMapView().TopLeftLatLong, wvMap.GetMapView().BottomRightLatLong, false, newShape.GetID());
            newShape.SetDescription(desc);
        }
    }    
}         

function BingResultPushpinRouteString(name, mapDisplayLatLong, linkText, bestMapViewTopLeftLatLong, bestMapViewBottomRightLatLong, prepend, pinId)
{
    var bestMapViewTopLeft = ",";
    var bestMapViewBottomRight = ",";

    if( bestMapViewTopLeftLatLong )
    {
        bestMapViewTopLeft += LatLongFunctionParam(bestMapViewTopLeftLatLong.Latitude, bestMapViewTopLeftLatLong.Longitude);        
        bestMapViewBottomRight += LatLongFunctionParam(bestMapViewBottomRightLatLong.Latitude, bestMapViewBottomRightLatLong.Longitude);
    }
    else
    {
        bestMapViewTopLeft += "null";
        bestMapViewBottomRight += "null";
    }

    var latLongString = LatLongFunctionParam(mapDisplayLatLong.Latitude, mapDisplayLatLong.Longitude); 

    var desc = "<a onclick=\'NoPrompt();\' href=\'javascript:AddToRoute(" +
          "null," +     //ID
          "\"" +        
          parent.XmlEncode(name) +                                                                     //Name
          "\"" +
          "," +
          "null," +                                                                             //Subtitle
          latLongString +                                                                       //Map Display
          ", " +                                                                                //Route LatLong
          latLongString +                                                                       //We only get map display lat long back so reuse for route lat long
          bestMapViewTopLeft +                                                                  //BMV Top Left
          bestMapViewBottomRight +                                                              //BMV Bottom Right
          ", \"4\", "; //Parent type of map result

    if( prepend )
    {
        desc += "true";
    }
    else
    {
        desc += "false";
    }

    desc += ", false); wvMap.HideInfoBox();";
    desc += "wvMap.DeleteShape(wvMap.GetShapeByID(\"" + pinId + "\"))\'>";       
    desc += desc + linkText + "</a>";    

    return desc;      
}

//Add placename with corresponding latlong to the route    
function AddToRoute(id, name, subtitle, mapDisplayLatLong, routeLatLong, bestMapViewTopLeft, bestMapViewBottomRight, parentType, prepend, logCall)
{
    var itineraryShape = new VEShape(VEShapeType.Pushpin, mapDisplayLatLong);
    
    if( parent.ActionableObject(id) )
    {       
        itineraryShape.SetTitle(GetTitleDetailsLink(id, name));
    }
    else
    {       
        itineraryShape.SetTitle(name);
    }    
        
    itineraryShape.SetDescription(subtitle);    
    itineraryShape.SetCustomIcon(routeIcon);
    itineraryLayer.AddShape(itineraryShape);
    
    parent.AddToRouteList(id, name, subtitle, mapDisplayLatLong, routeLatLong, bestMapViewTopLeft, bestMapViewBottomRight, parentType, prepend, logCall, itineraryShape);
}

function DeleteShape(shape)
{
    itineraryLayer.DeleteShape( shape );
}

function NoPrompt()
{
   allowPrompt = false;
}

//BING Helper functions

function GetVELatLong(lat, long)
{
    return new VELatLong(lat, long);
} 

function GetVELatLongRectangle(topLeft, bottomRight)
{
    return new VELatLongRectangle(topLeft, bottomRight); 
}

function SetBestMapView(topLeft, bottomRight)
{
    var bestMapView = new VELatLongRectangle(topLeft, bottomRight);
    wvMap.SetMapView( bestMapView );
}

//D
function OnStartPan()
{
    clearTimeout(onEndMapMoveTimer);
}

function OnEndPan()
{
    clearTimeout(onEndMapMoveTimer);
    onEndMapMoveTimer = setTimeout( function(){ OnEndMapMoveAndDelay(); }, onEndMapMoveTimout );
}        

function OnStartZoom()
{
    clearTimeout(onEndMapMoveTimer);
}

function OnEndZoom()
{
    clearTimeout(onEndMapMoveTimer);
    onEndMapMoveTimer = setTimeout( function(){ OnEndMapMoveAndDelay(); }, onEndMapMoveTimout );  
}

function OnEndMapMoveAndDelay()
{
    if( salesforceSearchLayer.IsVisible() )
    {
        UpdateForBoundingBox();
    }
}

//The following function sets controller values for the current map bounding box
function GetMapBoundingBox()
{
    var view = wvMap.GetMapView();
    
    var topLeft = view.TopLeftLatLong;
    var bottomRight = view.BottomRightLatLong;
 
    if( topLeft.Latitude == null )
    {
        if( wvMap.IsBirdseyeAvailable() )
        {
               var be = wvMap.GetBirdseyeScene();
               var rect = be.GetBoundingRectangle();
               
               topLeft = rect.TopLeftLatLong;
               bottomRight = rect.BottomRightLatLong;
        }    
    }   
 
    parent.SetBoundingBox(topLeft, bottomRight); 
}

//This method updates pushpins on map and results in the table to correspond with the current bounding box
function UpdateForBoundingBox()
{        
    parent.GetGeocodeDropdown().disabled = true;
    
    try
    {
        GetMapBoundingBox();
        parent.RenderPushpinsForBoundingBox();
    }
    catch(error)
    {
        parent.GetGeocodeDropdown().disabled = false;
    }                                  
}

function ClusteringCallback(clusters)
{
    for (var i=0; i < clusters.length; ++i) 
    { 
        var cluster = clusters[i]; 
        var clusterShape = cluster.GetClusterShape(); 
        var clusterDescription = "";

        var myLatLong = new VELatLong( cluster.Shapes[0].Latitude, cluster.Shapes[0].Longitude );
        var zoomToDesc = CreateZoomToString(myLatLong);
               
        if( cluster.Shapes.length > 8 && wvMap.GetZoomLevel() < 15 )
        {
            clusterShape.SetTitle("There are a large number of records here");                 
            clusterDescription += "Please zoom in for more detail" + "<p></p>";            
            clusterDescription += zoomToDesc;
        }
        else for( var j=0; j < cluster.Shapes.length; j++ )
        {
            if( j==0 )
            {
                clusterShape.SetTitle(cluster.Shapes.length + " records");                        
                clusterDescription += zoomToDesc;
                clusterDescription += "<p></p>";  
            }
        
            var shapeDescription = cluster.Shapes[j].GetDescription();
            
            var recordId = GetHiddenPropertyValue(shapeDescription, "RecordLookup");
            var salesforceRecordDetail = parent.salesforceRecordArray[recordId];
            var name = salesforceRecordDetail[0];
            
            clusterDescription += cluster.Shapes[j].GetTitle() + "<br></br>";
            clusterDescription += SalesforcePushpinRouteString(recordId, false, "Add to trip");

            clusterDescription += '<p></p>'
        }

        clusterShape.SetDescription(clusterDescription); 
    } 
}

function GetHiddenPropertyValue(description, property)
{
    var propertyStartId = description.indexOf(property);
    
    if( propertyStartId >= 0 )
    {
        var startShapeId = description.indexOf("value", propertyStartId);
        var numberPos = description.indexOf("\"", startShapeId) + 1;
        var endPos = description.indexOf("\"", numberPos);
        return description.substring(numberPos, endPos);
    }
    else
    {
        return null;
    }
}

function CreateZoomToString(myLatLong)
{
    var zoomToDesc = "";
    var latlongParam = LatLongFunctionParam(myLatLong.Latitude, myLatLong.Longitude)    
    
    if( wvMap.GetZoomLevel() < 15 )
    {
        zoomToDesc = "Zoom in to: ";
        zoomToDesc += "<a onclick=\'NoPrompt();\' href=\'javascript:wvMap.SetCenterAndZoom(" + latlongParam + ", 15); wvMap.HideInfoBox();\'>";
        zoomToDesc += "street</a>";    
        
        if( wvMap.GetZoomLevel() < 11 )
        {
            zoomToDesc += ", ";
            zoomToDesc += "<a onclick=\'NoPrompt();\' href=\'javascript:wvMap.SetCenterAndZoom(" + latlongParam + ", 11); wvMap.HideInfoBox();\'>";
            zoomToDesc += "city</a>";
            zoomToDesc += "<p></p>";    
        }
    }
    
    return zoomToDesc;
}

function RenderPushpins(pushpinClusterIcon, salesforceRecordArray)
{
    var shapes = new Array();

    //for (var count=0; count<=salesforceRecordArray.length-1; count++ )     
    var key;
    
    for( key in salesforceRecordArray )
    {                    
        var salesforceRecordDetail = salesforceRecordArray[key];
        var createdPushpin = CreateSalesforcePushpinShape(salesforceRecordDetail);                    
        customIcon.Image = parent.GetIconForRecordType(salesforceRecordArray[key][11]);
        createdPushpin.SetCustomIcon(customIcon);                    
        shapes.push(createdPushpin);
    }

    salesforceSearchLayer.DeleteAllShapes();

    var options =  new VEClusteringOptions(); 
    customIcon.Image = pushpinClusterIcon;
    options.Icon = customIcon;
    options.Callback = ClusteringCallback;

    salesforceSearchLayer.SetClusteringConfiguration(VEClusteringType.Grid, options);
    
    if( salesforceSearchLayer.IsVisible() )
    {
        salesforceSearchLayer.AddShape(shapes);
    }
    else
    {
        salesforceSearchLayer.AddShape(shapes);
        salesforceSearchLayer.Hide();
    }                
}

function GetTitleDetailsLink(detailsId , name)
{ 
    var title = "<a onclick=\'NoPrompt();\' href=\'javascript:parent.WVNavigateToDetailsPage(" + "\"" + detailsId + "\"" + "); wvMap.HideInfoBox();\'>";
    title += "<br></br>";
    title += name + "</a>";   

    return title;
}

function SalesforcePushpinRouteString(recordId, prepend, linkText)
{
    var parenRecordId = "\"" + recordId + "\"" ;
    
    var desc = "<a onclick=\'NoPrompt();\' href=\'javascript:parent.AddSalesforcePushpinToRoute(" +
                parenRecordId + 
                ",";
                
    if( prepend )
    {
        desc += "true";
    }
    else
    {
        desc += "false";
    }
    
    desc += "); wvMap.HideInfoBox();\'>";
       
    desc += desc + linkText + "</a>";    

    return desc;
}

function CreateSalesforcePushpinShape(salesforceRecordDetail)
{
    var mapDisplayLatLong = new VELatLong(salesforceRecordDetail[1], salesforceRecordDetail[2]);
    var shape = new VEShape(VEShapeType.Pushpin, mapDisplayLatLong);

    shape.SetTitle(GetTitleDetailsLink(salesforceRecordDetail[3], salesforceRecordDetail[0]));
        
    var parenRecordId = "\"" + salesforceRecordDetail[3] + "\"" ;
    
    //Note: this hidden value is read by the clustering code, preserve exactly as is or modify clustering
    var desc = "<html:hidden property=\"RecordLookup\" value=" + parenRecordId + "/>";
    desc += salesforceRecordDetail[10];
    desc += "<p></p>";    
    desc += CreateZoomToString(mapDisplayLatLong);
    desc += "<p></p>";    
    desc += SalesforcePushpinRouteString(salesforceRecordDetail[3], false, "Add to trip");    

    shape.SetDescription(desc);
        
    return shape;
}

function FilterMapToStops()
{
    if( salesforceSearchLayer.IsVisible() )
    {
        salesforceSearchLayer.Hide();
    }
    else
    {
        salesforceSearchLayer.Show();
    }   
    
    if( bingMapsSearchLayer.IsVisible() )
    {
        bingMapsSearchLayer.Hide();
    }
    else
    {
        bingMapsSearchLayer.Show();
    }   
}

//When we get a route back, apply this to the accordian control
function OnGotRoute(route)
{
    var routeDistanceDisplay = Math.round(route.Distance * 10)/10;
    
    //Q: should we display this to the user
    //console.log(routeDistanceDisplay + 'miles, ' + timeDisplay);

    wvMap.SetMapView(route.ShapePoints);
    
    var shape = new VEShape(VEShapeType.Polyline, route.ShapePoints);
    shape.SetLineColor(new VEColor(0, 118, 164, 0.5));
    shape.SetLineWidth(5);
    shape.HideIcon();
    shape.SetTitle("MyRoute");
    shape.SetZIndex(1000, 2000);

    itineraryRouteLayer.DeleteAllShapes();
    itineraryRouteLayer.AddShape(shape);

    var accordianEntry;        
    var step = 1;

    //Create a summary overview
    accordianEntry = '<h3><a href="#">Summary</a></h3>';
    accordianEntry += '<div>';
    accordianEntry += 'Total distance: ';
    accordianEntry += routeDistanceDisplay + ' miles' + '<p></p>';
    accordianEntry += 'Driving time: ';
    var timeDisplay = parent.SecondsToHourAndMinutesString(route.Time);
    accordianEntry += timeDisplay;
    //routeResultsAccordion.append(accordianEntry);         
    
    parent.AppendToRouteAccordion( accordianEntry, false );
                     
    parent.ShowTripSummary( routeDistanceDisplay + ' miles, ' + timeDisplay );
                   
    for( var index=0; index<route.RouteLegs.length; index++ )
    {
        routeDistanceDisplay = Math.round(route.RouteLegs[index].Distance * 10)/10;
        var timeDisplay = parent.SecondsToHourAndMinutesString(route.RouteLegs[index].Time);
        
        accordianEntry = '<h3><a href="#">' + routeLegNames[index] + ' to ' + routeLegNames[index+1] + '</a></h3>';

        accordianEntry += '<div>';
        accordianEntry += 'Distance: ';
        accordianEntry += routeDistanceDisplay + ' miles, ';
        accordianEntry += 'driving time: ';
        accordianEntry += timeDisplay;
        accordianEntry += '<p></p><table>'
        
        for( var inner=0; inner<route.RouteLegs[index].Itinerary.Items.length; inner++ )
        {
            var itineraryItem = route.RouteLegs[index].Itinerary.Items[inner];
            var itemDistance = Math.round(itineraryItem.Distance * 10)/10;
            accordianEntry = accordianEntry + '<tr><td>' + step + '</td><td>' + itineraryItem.Text + '</td><td>&nbsp;&nbsp;&nbsp;' + itemDistance + ' mi</td></tr>';
            step++;
        }            

        accordianEntry += '</table></div>';
        
        var resetAccordion = ( index == route.RouteLegs.length - 1 );
        parent.AppendToRouteAccordion( accordianEntry, resetAccordion );                
    }    
}

//Load custom icon, see thread;
//http://social.msdn.microsoft.com/Forums/en-US/vemapcontroldev/thread/5ee2f15d-09bf-4158-955e-e3fa92f33cda?prof=required&ppud=4
//This file is used to fix the custom icon offset issue in Bing Maps

  // Fix the SetCustomIcon() function to include pixel units for offset
  VEShape.prototype.SetCustomIcon = function(b) {
   if (typeof b == "undefined" || b == null) return null;
   if (typeof b == "object") {
    VEValidator.ValidateObject(b, "_content_", VECustomIconSpecification, "VECustomIconSpecification");
    this.Primitives[0].name = (typeof b.TextContent == "string" && b.TextContent != null ? b.TextContent : " ");  
    var a = this.Primitives[0].symbol;
    if (a.id == MC_PROPERTY_PARK || a.id == MC_PROPERTY_PUSHPIN) a = a.Clone();
    if (typeof b.Image == "string" && b.Image != null) a.imagedata_src = GetImageFullUrl(b.Image);
    else a.imagedata_src = Msn.VE.API.Constants.iconurl;
    var e = b.ForeColor;
    if (typeof e == "object" && e != null) {
     VEValidator.ValidateObject(e, "fC", VEColor, "VEColor");
     a.textbox_color = e.ToHexString();
     a.textbox_color_opacity = e.A
    } var d = b.BackColor;
    if (typeof d == "object" && d != null) {
     VEValidator.ValidateObject(d, "bC", VEColor, "VEColor");
     a.textbox_backcolor = d.ToHexString();
     a.textbox_backcolor_opacity = d.A
    } var g = b.TextOffset;
    if (typeof g == "object" && g != null) {
     VEValidator.ValidateObject(g, "tO", VEPixel, "VEPixel");
     a.textbox_OffsetX = b.TextOffset.x;
     a.textbox_OffsetY = b.TextOffset.y
    } var f = b.ImageOffset;
    if (typeof f == "object" && f != null) {
     VEValidator.ValidateObject(f, "iO", VEPixel, "VEPixel");
     a.img_offsetX = f.x;
     a.img_offsetY = f.y
    } if (b.TextBold) a.textbox_bold = true;
    if (b.TextItalics) a.textbox_italic = true;
    if (b.TextUnderline) a.textbox_underscore = true;
    var l = parseInt(b.ImageWidth);
    if (!isNaN(l)) a.img_width = l;
    var k = parseInt(b.ImageHeight);
    if (!isNaN(k)) a.img_height = k;
    a.textbox_font = b.TextFont;
    a.imagedata_on = true;
    var i = parseInt(b.TextSize);
    if (!isNaN(i)) a.textbox_size = i;
    a.isOn = true;
    this.Primitives[0].symbol = a;
    if (b.CustomHTML != null) this._customIcon = b.CustomHTML;
    else if (this.Primitives[0].name) {
     var c = [];
     c.push("<div style='position:relative'>");
     c.push(" <div style='position:absolute;left:" + a.textbox_OffsetX + "px;top:" + a.textbox_OffsetY + "px;");
     c.push("font-size:" + a.textbox_size + "pt;font-family:" + a.textbox_font + ";");
     c.push("color:" + a.textbox_color + ";");
     var h = this.GetZIndex();
     if (a.textbox_italic) c.push("font-style:italic;");
     if (a.textbox_bold) c.push("font-weight:bold;");
     if (a.textbox_underscore) c.push("text-decoration:underline;");
     c.push("z-index:" + (h + 1) + ";");
     c.push("'>");
     c.push(this.Primitives[0].name);
     c.push("</div>");
     c.push(" <img style='position:relative;top:" + a.img_offsetY + "px;left:" + a.img_offsetX + "px;z-index:" + h + "' src='" + a.imagedata_src + "'' ");
     var j = Msn.VE.Environment.BrowserInfo;
     if (j.Type == Msn.VE.BrowserType.MSIE && parseFloat(j.MajorVersion) < 7 && a.imagedata_src != null && a.imagedata_src.search(/.gif$/) < 0) c.push(' onload=\'this.onload="";if(this.fileSize!=-1){this.style.width=this.width;this.style.height=this.height;this.src="' + Msn.VE.API.Constants.spacerurl + '";this.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\\"' + a.imagedata_src + '\\", sizingMethod=\\"scale\\")";}\' />');
     else c.push("/>");
     c.push("</div>");
     this._customIcon = c.join("")
    } else this._customIcon = a.imagedata_src
   } else if (typeof b == "string") {
    this._customIcon = b;
    if (b.indexOf("<") < 0) {
     var a = this.Primitives[0].symbol;
     if (a.id == MC_PROPERTY_PARK || a.id == MC_PROPERTY_PUSHPIN) a = a.Clone();
     a.imagedata_src = GetImageFullUrl(b);
     a.isOn = true;
     this.Primitives[0].symbol = a
    } 
   } this._IconContent = null;
   this.Redraw(false, false, false, true)
  };

//format lat long such that it can be used in javascript parameter
function LatLongFunctionParam(latitude, longitude)
{
    return "new VELatLong(" + latitude + "," + longitude + ")";            
}

//Add Lat Long xml nodes
function AddXmlLatLongNodes( name, value )
{
    if( !parent.ActionableObject(value) )
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

//Creates virtual earth lat long from strings. We use strings to handle the empty (null) case. 
//For numbers, NULLs appear to be passed back from SF as empty strings
function VELatLongFromStrings(latitude, longitude)
{
    if( latitude == '' || longitude == '' || !parent.ActionableObject(latitude) || !parent.ActionableObject(longitude) )
    {
        return null;
    }
    
    return new VELatLong(parseFloat(latitude), parseFloat(longitude));    
}

</script>
</head>
<body>
	<div id='myMap' style="position:relative; width:100%; height:380px; border=0"></div>
</body>
</html>

