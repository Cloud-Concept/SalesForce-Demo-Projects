var routeLegNames;

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
    var timeDisplay = SecondsToHourAndMinutesString(route.Time);
    accordianEntry += timeDisplay;
    //routeResultsAccordion.append(accordianEntry);	        
    
    parent.AppendToRouteAccordion( accordianEntry, false );
                     
    parent.ShowTripSummary( routeDistanceDisplay + ' miles, ' + timeDisplay );
                   
    for( var index=0; index<route.RouteLegs.length; index++ )
    {
        routeDistanceDisplay = Math.round(route.RouteLegs[index].Distance * 10)/10;
        var timeDisplay = SecondsToHourAndMinutesString(route.RouteLegs[index].Time);
        
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
