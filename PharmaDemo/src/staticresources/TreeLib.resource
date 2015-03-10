
        function HideAll2(num) {
        	
        	var node;
        	var img;
        	
        	for(var i = 1; i <=num; i++){
        		node = document.getElementById('divad' + i);
        		img = document.getElementById('imgAd' + i);
        		
        		if (node != null) {
        			node.style.display = 'none';
        			img.src = "/resource/1299775374000/plus";
        		}
        		
        	}
        	
        }
        
        function ShowAll2(num) {
        	
        	var node;
        	var img;
        	
        	for(var i = 1; i <=num; i++){
        		node = document.getElementById('divad' + i);
        		img = document.getElementById('imgAd' + i);
        		
        		if (node != null) {
        			node.style.display = '';
        			img.src = "/resource/1299775299000/minus";
        		}
        		
        	}
        	
        }
        
        
        function HideAll() {

            var tableObj = document.getElementById('treeTable');
            var cellObj;
            var cell2Obj;
        
            if (tableObj != null) {
            
                for(var i = 0; i < tableObj.rows.length; i++){
                    for(var k = 0; k < tableObj.rows[i].cells.length; k++) {
                        if (tableObj.rows[i].cells[k].children.length > 0) {
                            for(var j = 0; j < tableObj.rows[i].cells[k].children.length; j++){
                                cellObj = tableObj.rows[i].cells[k].children.item(j);
                                
                                for(var m = 0; m < cellObj.rows.length; m++){
                                    for(var n = 0; n < cellObj.rows[m].cells.length; n++) {
                                        cell2Obj = cellObj.rows[m].cells[n];
                                        if (cell2Obj.children.length > 0) {
                                            for(var p = 0; p < cell2Obj.children.length; p++) {
                                                if (cell2Obj.children.item(p).tagName == 'A'){
                                                    if (cell2Obj.children.item(p).children.item(0).tagName == 'IMG') {
                                                        cell2Obj.children.item(p).children.item(0).src = "/resource/1299775374000/plus";
                                                    }
                                                }
                                                if (cell2Obj.children.item(p).tagName == 'DIV') {
                                                    cell2Obj.children.item(p).style.display = 'none';
                                                }
                                            }
                                        }
                                    }   
                                }
                            }
                        }
                    }
                }
                
            }
        
        }

        function ShowAll() {
        
            var tableObj = document.getElementById('treeTable');
            var cellObj;
            var cell2Obj;
        
            if (tableObj != null) {
            
                for(var i = 0; i < tableObj.rows.length; i++){
                    for(var k = 0; k < tableObj.rows[i].cells.length; k++) {
                        if (tableObj.rows[i].cells[k].children.length > 0) {
                            for(var j = 0; j < tableObj.rows[i].cells[k].children.length; j++){
                                cellObj = tableObj.rows[i].cells[k].children.item(j);
                                for(var m = 0; m < cellObj.rows.length; m++){
                                    for(var n = 0; n < cellObj.rows[m].cells.length; n++) {
                                        cell2Obj = cellObj.rows[m].cells[n];
                                        if (cell2Obj.children.length > 0) {
                                            for(var p = 0; p < cell2Obj.children.length; p++) {
                                                if (cell2Obj.children.item(p).tagName == 'A'){
                                                    if (cell2Obj.children.item(p).children.item(0).tagName == 'IMG') {
                                                        cell2Obj.children.item(p).children.item(0).src = "/resource/1299775299000/minus";
                                                    }
                                                }
                                                if (cell2Obj.children.item(p).tagName == 'DIV') {
                                                    cell2Obj.children.item(p).style.display = '';
                                                }
                                            }
                                        }
                                    }   
                                }
                            }
                        }
                    }
                }   
            }
        }
        
        function Toggle(ahref, nodeId){
			
            // Unfold the branch if it isnt visible
            var nd = document.getElementById('div' + nodeId);
            var node = document.getElementById(nodeId);
            
            if (nd != null) {
	            if (nd.style.display == 'none'){
	        
	                // Change the image (if there is an image)
	                if (ahref.children.length > 0){
                		if (ahref.children.item(0).tagName == "IMG"){
	                        ahref.children.item(0).src = "/resource/1299775299000/minus";
	                    }
	                }
	                
	                nd.style.display = '';
	            }
	        
	            // Collapse the branch if it IS visible
	            else{
	                // Change the image (if there is an image)
	                if (ahref.children.length > 0){
                		if (ahref.children.item(0).tagName == "IMG"){
	                        ahref.children.item(0).src = "/resource/1299775374000/plus";
	                    }
	                }
	                
	                nd.style.display = 'none';
	            }
            }
        
        }

