//See thread;
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
