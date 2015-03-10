        // show div as dialog
        function showAsDialog(divId){
            if(jQuery('#'+divId).length == 0){
                return false;
            }
            var messageBox = jQuery('#'+divId);

            if(!messageBox.hasClass('hidden')){
                return true;
            }

            jQuery('#overlay-disable').css('opacity', 0.3);
            jQuery('#overlay-disable').css('height', jQuery(document).height());        
            jQuery('#overlay-disable').css('width', jQuery(document).width()); 

            var actualWindowWidth = jQuery(window).width();
            var actualWindowHeight = jQuery(window).height();
            var verticalScrollPosition = jQuery(document).scrollTop();
            var horizontalScrollPosition = jQuery(document).scrollLeft();
            
            var left = horizontalScrollPosition + (actualWindowWidth/2) - ((messageBox.width()) / 2);
            var top = verticalScrollPosition + (actualWindowHeight/2) - ((messageBox.height()) / 2);

			if(top<0){
				top = 0;
			}

			if(left<0){
				left = 0;
			}
			
            messageBox.css('top', top);
            messageBox.css('left', left);            
  
            messageBox.removeClass('hidden');            
            return true;
        }

        // hide dialog div
        function hideDivDialog(divId){
            if(jQuery('#'+divId).length == 0){
                return false;
            }        
            var messageBox = jQuery('#'+divId);
           
            if(messageBox.hasClass('hidden')){
                return true;
            }
                        
            messageBox.addClass('hidden');
            if(jQuery('.dialog:not(.hidden)').length == 0){
              	jQuery('#overlay-disable').css('opacity', 0.3);
               	jQuery('#overlay-disable').css('height',0);
           	}        
            return true;
        }        
        
        function showError(errorMsg, errorNotify){
            if(typeof errorMsg != 'undefined'){
                jQuery('#error-msg').text(errorMsg);
            } else {
                jQuery('#error-msg').text('');          
            }
            if(typeof errorNotify != 'undefined'){
                jQuery('#error-msg-nofity').text('More information: '+errorNotify);
            } else {
                jQuery('#error-msg-nofity').text('');           
            }
            showAsDialog('promptError');                
        }
        
        // update text color (for all buttons)
        function updateTextButtons(){
            jQuery('.custom-button').each(function(i, elem){
                jQuery(elem).css('color', '#'+jQuery('.buttonTextColorInput').val() );
                if( !isNaN(parseInt(jQuery('.alphaButtonText').val())) ){
                	opacityValue = parseInt(jQuery('.alphaButtonText').val());
                } else {
                	opacityValue = 100;
                }
                jQuery(elem).find('.button-text-wrapper').css('opacity', (opacityValue/100) );
            });        
        }
                
        // add colorPicker to given selector
        function bindColorPicker(selector){
            selector.jPicker({
                window: 
                {
                    title: "Select color",
                    effects:
                    {
                        type: 'fade',
                        speed:
                        {
                            show: 'fast',
                            hide: 'fast'
                        }
                    },
                    position:
                    {
                        x: 4,
                        y: -2
                    },
                    expandable: true,
                    liveUpdate: false,
                    updateInputColor: false
                },
                color:{
                    active:new jQuery.jPicker.Color({ahex:'993300ff'})
                }
            },
            function(){
                updateTextButtons();        // callback function: update buttons 
            },
            function(){
                updateTextButtons();        // callback function: update buttons     
            },
            function(){
                updateTextButtons();       // callback function: update buttons      
            }            
            );
            selector.attr('readonly', true);
            selector.attr('maxlength',6);
            selector.attr('size',6);            
        }


