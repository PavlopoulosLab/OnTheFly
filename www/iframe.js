//Transformation of selected entities in R
var formdata = new FormData ();
formdata.append('Chemical compound', '-1');
formdata.append('Organism', '-2');
formdata.append('Protein', '-3');
formdata.append('Biological Process', '-21');
formdata.append('Cellular component', '-22');
formdata.append('Molecular function', '-23');
formdata.append('Tissue', '-25');
formdata.append('Disease', '-26');
formdata.append('ENVO environment', '-27');
formdata.append('APO phenotype', '-28');
formdata.append('FYPO phenotype', '-29');
formdata.append('MPheno phenotype', '-30');
formdata.append('NBO behavior', '-31');
formdata.append('Mammalian phenotype', '-36');
formdata.append('Homo sapiens (Human)', '9606');
formdata.append('Mus musculus (Mouse)', '10090');
formdata.append('Rattus rattus (Rat)', '10116');
formdata.append('Bos taurus (Cow)', '9913');
formdata.append('Drosophila melanogaster', '7227');
formdata.append('Caenorhabditis elegans', '6239');
formdata.append('Saccharomyces cerevisiae', '2528333');
formdata.append('Escherichia coli', '2605620');
formdata.append('Zea mays', '381124');
formdata.append('Arabidopsis thaliana', '3702');

function entitytransform (rselect) {
  if (rselect[0] != null) {
    var str = '';
    if(formdata.has(rselect[0]))
    {
    str += formdata.get(rselect[0]);
    }
    else
    {
      str += rselect[0];
    }
    for (var i = 1; i < rselect.length; i++) {
      if (rselect[i] == null) {
        break;
      }
      if (formdata.has(rselect[i]))
      {
      str += '+' +formdata.get(rselect[i]);
      }
      else
      {
        str += "+" +rselect[i]
      }
    }
    console.log(str);
    return str;
  }
}

// POST REQUEST ENTITIES 
shinyjs.table = function (arg) {
  var xhttp = new XMLHttpRequest();
  var frames = $(".pdf_frame:visible");
  //console.log(frames);
  //var textinput = $("[id*='moreorg']").val();
  //var value = '+'+textinput;
  if (frames.length > 0) {
    
	var inp = frames.contents().find("body");
	
	var inner = frames.contents().find("body").html(); //replaced text() with html()

    //window.alert(inner);


    //inner=inner.replace(/ /gi, ",");

    //inner=inner.replace(/\n\r/gi, ",");
    //inner=inner.replace(/\r\n/gi, ",");
	//inner=inner.replace(/\n/gi, ",");
    //inner=inner.replace(/\r/gi, ",");
    var documentInput = encodeURIComponent(inner);
    //window.alert(inner);
    //window.alert(documentInput);
    var entity_types = entitytransform(arg[0]);
    //entity_types += value;
    var format = "csv";
    var auto_detect = 0;
    var extract_params = "format=" + format + "&entity_types=" + entity_types + "&auto_detect=" + auto_detect + "&document=" + documentInput;
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
        var data = [this.responseText, frames.prop("src")];
		console.log(data);
        Shiny.onInputChange("entities", data);
      }
    };
    xhttp.open('POST', 'http://tagger.jensenlab.org/GetEntities', true);
    xhttp.send(extract_params);
  }
};

//

//RUN EXTRACT BOOKMARKLET INSIDE IFRAME

shinyjs.annotate = function (arg) {
  var frames = $('.pdf_frame:visible');
  frames.attr('src');
  //var textinput = $("[id*='moreorg']").val();
  //var value = '+'+textinput;
  var entity_types = entitytransform(arg[0]);
  //entity_types += value;
  if (frames.length > 0) {
    var scriptag = "<script> \n\
    (function tagger () { \n\
      var extract_timer_delay = 6500; \n\
      var extract_timer_id = setTimeout(function () { \n\
        alert ('EXTRACT is currently not available, please try again in a while'); \n\
        throw new Error('EXTRACT: script injection/connection timed out'); \n\
      }, extract_timer_delay); \n\
      var extract_js = document.createElement('script'); \n\
      extract_js.setAttribute('id', 'extract_js_script'); \n\
      extract_js.onload = function (){ \n\
        clearTimeout(extract_timer_id); \n\
      }; \n\
      extract_js.setAttribute('src', '../extract-ed.js?v='+parseInt(Math.random()*99999999)+'&entity_types="+entity_types+"&auto_detect=0'); \n\
    document.body.appendChild(extract_js);}());<";
      scriptag += '/script>';
      frames.contents().find('body').append(scriptag);
      //console.log(frames.contents().find('body').append(scriptag));
  }
}




//ZOOM IN AND OUT (IFRAME)
shinyjs.ZoomInIframe = function (zoom) {
  $('.pdf_frame:visible').contents().find('body').css({
    'height':'550px',
    'width': '100%',
    'margin': '10px',
    '-ms-zoom': ''+zoom/100,
    '-moz-transform': 'scale('+zoom/100+')',
    '-moz-transform-origin': '0 0',
    '-o-transform': 'scale('+zoom/100+')',
    '-o-transform-origin':' 0 0',
    '-webkit-transform': 'scale('+zoom/100+')',
    '-webkit-transform-origin': '0 0'
  });
}

shinyjs.int_network = function () {
  var image_network = $('#svg_network_image');
  if (image_network != null) {
    $('#shiny-tab-String').css({
      'margin-bottom':'800px'
    });
      $('#shiny-tab-Stitch').css({
      'margin-bottom':'800px'
    });
  }
}

//


// Updates global file names at R, based on javascript global selected renamed files
// @return: true
function updateFileNames(){
  //console.log(newNames);
  Shiny.setInputValue("js_fileNames", newNames);
  newNames = [];
  return true;
}


function shinyAlert(message){
  alert(message);
  return true;
}

// This function updates a global variable (file_names) in R
// @param message: array of selected file names
// @return true
function shinyRenameFiles(message){
  var i;
  if (typeof(message) == "object"){
    for (i=0; i<message.length; i++){
      newNames[i] = prompt("Rename file: ", message[i]);
    }
  } else newNames = prompt("Rename file: ", message);
  updateFileNames(newNames);
  return true;
}

Shiny.addCustomMessageHandler("handler_alert", shinyAlert);
Shiny.addCustomMessageHandler("handler_rename", shinyRenameFiles);
