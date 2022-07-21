/*

Modified EXTRACT script

This is a modified version of the EXTRACT script used for Tagging in the On the Fly Service.

It is based on the original extract.js script.  Modifications have been made to tailor it for our service,
in accordance with the original code's license.

*/




//Original declaration and copyright
/*
 * (c) Hellenic Center for Marine Research, 2015
 *
 * Licensed under the The BSD 2-Clause License; you may not
 * use this file except in compliance with the License.
 * You may obtain a copy of the license at
 *
 * http://opensource.org/licenses/BSD-2-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
/*
<!--                                            -->
<!--    Script created by Evangelos Pafilis     -->
<!--     as part of the EXTRACT project         -->
<!--              June 2015                     -->
<!--                                            -->
<!--            pafilis@hcmr.gr                 -->
<!--                                            -->

<!------------------------------------------------>
<!--                 History                    -->
<!------------------------------------------------>

<!-- v001: 06.06.15: finalized Jquery libraries and css injecton and communication to the HCMR proxy and th CPR tagger
                     enabled draggability, implement proper log/debug messages -->
<!-- v002: 13.06.15: increased  selected_text_character_limit to 1024 (~170 words)-->
<!-- v003: 16.06.15: added the funtionality to tag the whole document.body.innerHTML when EXTRACT has been
                     clicked with no text selected (via the HTTPS HCMR proxy)-->
<!-- v004: 17.06.15: fixed the spinner look-and-feel when the  tagging of the whole document.body.innerHTML is in progress
                     fixed the zIndex definition of the spinner so that is arranged in front of other page elements-->
<!-- v005: 20.06.15: timeout mechanism installed to abort if the tagger does not respond within
                     'tagger_response_waiting_period' (set to 20 seconds) for full page tagging-->
<!-- v006: 29.06.15: 'tagger_response_waiting_period' (set to 25 seconds) for full page tagging
                     The "Close Popup" character has been set to "&#10005;"; //unicode for MULTIPLICATION X
                     replacing  \ "Mathematical Sans-Serif Bold Capital X" Unicode Decimal Code &#120299;-->
<!-- v007: 29.06.15: Right after injecting the popup in the <body> of the user page
                     a key listener is attached to the DOM "document" of the user page
                     that closes the popup on ESC key up-->
<!-- v008: 30.06.15: the 'processing_page_message' has been added to the full page tagging loading div/spinner-->
<!-- v009: 16.07.15: Reflect funtions are now being silenced.
                     Close Popoup (X) now works also on Opera, Internet Explorer-->
<!-- v010: 11.08.15: Major Refactoring: added extract_show_popup( custom_text )
                         this way upon clicking a tag an EXTRACT popup can be invoked
                         now all code besides configuration and main operation exist
                         within methods
                    added: extract_add_full_page_tagged_div(): adds a hidden div called
                           "extract_full_page_tagged", invoked by extract_tag_all_html()
                           upon successful full page tagging
                    added: extract_show_entity_type_legend(): adds an entity legend type div,
                           invoked by extract_tag_all_html() upon successful full page tagging
                    implemented start/stopReflectPopupTimer(), showReflectPopup() (related
                    global variables: 'extract_popup_mouseover_waiting_period',
                    'extract_popup_mouseover_timer' added)
                         -->
<!-- v011: 17.10.15: Major Refactoring: extract-2.0.js DEV
                        prerelease supports also: gene, protein, Gene Ontology term, and small chemical molecule identification
                        auto_detect is enabled, and human genes/protein identification is forced
                        dropped all HCMR server full funtionality on the CPR server
                        extract-2.0.js used for development/confict avoidance purposes
                         -->

<!-- v012: 07.11.16: Major Refactoring: extract-2.0.js DEV
                        prerelease supports also: Phenotype (-36: Mammalian Phenotype Ontology)
                        auto_detect is enabled, and human genes/protein identification is forced
                        extract-2.0.js used for development/confict avoidance purposes
                        entity legend in full text tagging updated
                        In total entities supported at present are:
                        "<div id='entity_legend_gene_protein_div'         >Protein</div>"    +
                        "<div id='entity_legend_chemical_compound_div'    >Compound</div>"    +
                        "<div id='entity_legend_organism_div'             >Organism</div>"    +
                        "<div id='entity_legend_cellular_component_div'   >Cellular Component</div>"    +
                        "<div id='entity_legend_biological_process_div'   >Biological Process</div>"    +
                        "<div id='entity_legend_molecular_function_div'   >Molecular Function</div>"    +
                        "<div id='entity_legend_environment_div'          >Environment</div>" +
                        "<div id='entity_legend_tissue_div'               >Tissue</div>"      +
                        "<div id='entity_legend_disease_div'              >Disease</div>"     +
                        "<div id='entity_legend_phenotype_div'            >Phenotype</div>"
                        -->

 --- -24 not tagged anymore
 ---         "<div id='entity_legend_gene_protein_div'    >Protein</div>"               +
        "<div id='entity_legend_chemical_compound_div'    >Chemical compound</div>"     +
        "<div id='entity_legend_organism_div'             >Organism</div>"              +
        "<div id='entity_legend_cellular_component_div'   >Gene Ontology term</div>"    +
        "<div id='entity_legend_tissue_div'               >Tissue</div>"                +
        "<div id='entity_legend_disease_div'              >Disease/phenotype</div>"     +
        "<div id='entity_legend_environment_div'          >Environment</div>"           ;


*/


//NOW FOLLOWS THE SCRIPT



//Here we set some environment variables that will be applied throughout the script

//Production server for EXTRACT/TAGGER as of 2016 November
//NB: the unix slash at the end is compulsory
var cpr_tagger_url = "https://tagger.jensenlab.org/"  //the web server powering tagger and its tools
var cpr_extract_base_url = "https://extract.jensenlab.org/"; // the web server of the extract front-end, this contains all CSS and JS scripts required for formatting and styling results

//The Extract Tools
var popup_webapp = "ExtractPopup"; // Tool that creates the pop-up window contents
var get_tagged_html_webapp = "GetHTML"; //the main tool that tags HTML documents
var entities_webapp="GetEntities"; // Tool that returns a json or tsv table file with all tagged entities in a text

//timeout options (times in milliseconds)
var tagger_response_waiting_period = 60000; //abort if the tagger does not respond within 60 seconds
// NOTE: this increase to 60 seconds was done because Chromium-based browsers (Chromium itself, Google Chrome and the new Microsoft Edge) would produce
//CORS policy errors with the original timeout (30 seconds), when dealing with medium to large documents.  I don't know why, probably something to do with the tagger.jensenlab.org server
var extract_popup_mouseover_waiting_period = 1000;  //wait time on mouse over a full page tag before launching the EXTRACT Popup with that tag
var extract_popup_mouseover_timer; // timer to handle EXTRACT popup delay;


//debugging
var debug = false;






// get document's body and head
var extract_body = document.getElementsByTagName('body')[0];
var extract_head = document.getElementsByTagName('head')[0];




var selected_text_character_limit = 1024;

//var entity_types = "-1+-2+-21+-22+-23+-25+-26+-27+-36+9606&auto_detect=1";
var search_terms=get_search_terms("extract_js_script");

var entities=search_terms["entity_types"];
var auto_detect=search_terms["auto_detect"];

var entity_types=entities+"&"+auto_detect;









extract_tag_all_html(extract_body, extract_head, entity_types);
extract_clean_up();



//NOW FOLLOW THE METHODS


//the EXTRACT functions that run the tagger tools, handle processing popups and style results; these are based on the original extract.js script, but with some changes
//essentially, what I did was cleanup the code, remove clutter (old code that was commented out, some scripting mishaps etc) and disable all features not needed by On the Fly.


//add a hidden div called "extract_full_page_tagged" to the current page; this will help the main EXTRACT/TAGGER function (see below)
/*function extract_add_full_page_tagged_div () {
    var extract_full_page_tagged_div = document.createElement('div');
    extract_full_page_tagged_div.setAttribute ( "id", "extract_full_page_tagged");
    extract_full_page_tagged_div.style.setProperty("display" , "none", "important");
    document.body.appendChild ( extract_full_page_tagged_div );
}*/

//load a script.  Used for loading jQuery and bootstrap scripts, if needed
function extract_getScript(url,success){

   var head = document.getElementsByTagName("head")[0], done = false;
   var script = document.createElement("script");
   script.src = url;

   // Attach handlers for all browsers
   script.onload = script.onreadystatechange = function(){
      if ( !done && (!this.readyState ||
                     this.readyState == "loaded" || this.readyState == "complete") ) {
                  done = true;
                  success();
      }
   };
   head.appendChild(script);
}

function extract_show_entity_type_legend(extract_head) {

    //house keeping: add scripts and styles (1 of 2)
    extract_addStyle(extract_head, "", cpr_extract_base_url + "styles/extract.css")

    // create legend popup elements
    ////////////////////////

    // legend popup outermost container
    var extract_legend_div = document.createElement('div');
    extract_legend_div.setAttribute ( "id","extract_legend");

    //legend popup header container
    var extract_legend_header_div = document.createElement('div');
    extract_legend_header_div.setAttribute ( "id", "extract_legend_header");

    //legend popup header action links/buttons

    // Close legend popup
    var legend_close_anchor = document.createElement('a');
    legend_close_anchor.setAttribute ( "id", "legend_close_anchor");
    legend_close_anchor.setAttribute ( "onclick", "var extract_legend_elem = document.getElementById('extract_legend'); extract_legend_elem.parentNode.removeChild(extract_legend_elem);" );
    legend_close_anchor.setAttribute ( "title", "Close Popup");
    legend_close_anchor.innerHTML =  "&#10005;"; //unicode for MULTIPLICATION X

    //Legend popup header title
    var extract_legend_header_title_div = document.createElement('div');
    extract_legend_header_title_div.setAttribute ( "id","extract_legend_header_title");
    extract_legend_header_title_div.innerHTML = "EXTRACT";

    //Legend popup content
    var extract_legend_content        = document.createElement('div');
    extract_legend_content.setAttribute ( "id", "extract_legend_content");
    extract_legend_content.innerHTML = "" +
        "<div id='entity_legend_gene_protein_div'         >Protein</div>"               +
        "<div id='entity_legend_chemical_compound_div'    >Chemical compound</div>"     +
        "<div id='entity_legend_organism_div'             >Organism</div>"              +
        "<div id='entity_legend_environment_div'          >Environment</div>"           +
        "<div id='entity_legend_tissue_div'               >Tissue</div>"                +
        "<div id='entity_legend_disease_div'              >Disease/phenotype</div>"     +
        "<div id='entity_legend_cellular_component_div'   >Gene Ontology term</div>"    ;

    // Build the popup element hierarchy
    ///////////////////////////////////

    //legend popup header coomponents in popup header
    extract_legend_header_div.appendChild( extract_legend_header_title_div );
    extract_legend_header_div.appendChild( legend_close_anchor );

    // legend popup header and content in legend popup
    extract_legend_div.appendChild( extract_legend_header_div );
    extract_legend_div.appendChild( extract_legend_content );

    // legend popup in the page (enable draggability tool)
    extract_body.appendChild ( extract_legend_div );


    //house keeping: add scripts and styles (2 of 2)
    //NB: the order is important!
    // jQuery-ui draggability is enabled after both jQuery and jQuery-ui have been successfully loaded
    extract_getScript('https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js',function(){
       if ( debug ) { console.log( 'jQuery loaded' ) };
    });
    extract_getScript('https://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.js',function(){
       $('#extract_legend').draggable() ;
       if (debug ) { console.log( 'jQuery-ui loaded, draggable enabled' ) };
    });

}


// method that styles the loading indicator.  This has been altered to accommodate the styling of On the Fly
function extract_show_loading_indicator (extract_body)
{
   // prepare the loading spinner image and message HTML
   var extract_loading_image=  "../images/loading.gif";
   var processing_page_message = "Performing Entity Search.  Please Wait";
   var loading_html = "<img id='extract_loading_indicator' src='"+extract_loading_image+"' style='width:150px;height:150px' /><br>"+processing_page_message;

   // prepare the loading spinner container div
   var extract_loading_indicator_div = document.createElement("div");

   extract_loading_indicator_div.id = "extract_loading_indicator_div";

   extract_loading_indicator_div.innerHTML = loading_html;


   extract_loading_indicator_div.style.setProperty("display"    , "block"     , "important");
   extract_loading_indicator_div.style.setProperty("background-color" , "#fff", "important");
   extract_loading_indicator_div.style.setProperty("opacity"    , "1"         , "important");
   extract_loading_indicator_div.style.setProperty("border"     , "solid 2px #bbb"  , "important");

   extract_loading_indicator_div.style.setProperty("position"   , "fixed"  , "important");
   extract_loading_indicator_div.style.setProperty("left"       , "50%"  , "important");
   extract_loading_indicator_div.style.setProperty("top"        , "20%"  , "important");
   extract_loading_indicator_div.style.setProperty("transform"  , "translate(-50%, -50%)"  , "important");

   //NB: the final width is 350px + 50px + 50px = 450px (due to left, right padding)
   extract_loading_indicator_div.style.setProperty("width"      , "200px"  , "important");
   //NB: the final height is 165px + 300px = 450px (due to padding-top)
   extract_loading_indicator_div.style.setProperty("height"     , "200px"  , "important");
   extract_loading_indicator_div.style.setProperty("z-index"    , "999998" , "important");
   //NB: final width, height is affected by the padding properties
   extract_loading_indicator_div.style.setProperty("padding-top"     , "100px"   , "important");
   extract_loading_indicator_div.style.setProperty("padding-top"     , "10px"   , "important");
   extract_loading_indicator_div.style.setProperty("padding-left"    , "80px"    , "important");
   extract_loading_indicator_div.style.setProperty("padding-right"   , "80px"    , "important");
   extract_loading_indicator_div.style.setProperty("font-size"       , "18px"    , "important");
   extract_loading_indicator_div.style.setProperty("font-family"       , "Arial"    , "important");
   extract_loading_indicator_div.style.setProperty("text-align"      , "center"  , "important");


   //add the container div to the page body
   extract_body.appendChild(extract_loading_indicator_div);

}

function extract_close_loading_indicator() {
   var ld = document.getElementById("extract_loading_indicator");
   var ld_div = document.getElementById("extract_loading_indicator_div");
   if (ld !== null) { ld.remove(); }
   if (ld_div !== null) { ld_div.remove(); }
}



/////////////////////////////////////////////////////////////////////////////////////////////
// Main Operation (invoked upon button click, ie injection of this script)
/////////////////////////////////////////////////////////////////////////////////////////////
function extract_tag_all_html (extract_body, extract_head, entity_types) {

   //if div "extract_full_page_tagged" already exists, then the page
   //has already been fully tagged. Returns and does not retag the page
   /*if ( document.getElementById("extract_full_page_tagged") ) {
       return;
   }*/
   //this is the first time this page is being fully tagged, proceed
   /////////////////////////////////////////////////////////////////


   function throw_alert (arg){
      if ( document.getElementById("extract_loading_indicator") ) {  extract_close_loading_indicator();  }
      if (arg === undefined) { alert ('EXTRACT is currently not available, please try again in a while'); }
      throw new Error('EXTRACT: connection timed out');
   }

   var extract_body_text = extract_body.innerHTML;


   var extract_params = "entity_types=" + entity_types + "&document=";
   extract_params += encodeURIComponent ( extract_body_text );

   //start the work in progress spinner and the tagger_response_timer
   //abort if the tagger does not respond within 'tagger_response_waiting_period' seconds
   extract_show_loading_indicator(extract_body);
   var tagger_response_timer_id = setTimeout( throw_alert, tagger_response_waiting_period );



   // cross-browser XML HTTP request generation
   var extract_xmlhttp = false;
   if (window.XMLHttpRequest) {
       extract_xmlhttp = new XMLHttpRequest();
   }
   else {
       extract_xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
   }
   extract_xmlhttp.onload = function ( progressEvent ) {

      if (extract_xmlhttp.readyState == 4) {

         if (extract_xmlhttp.status == 200) {
            //console.log(extract_body_text);
            //NB: by resetting the body.innerHTML the loading img and container div are automatically removed
            //    as they were not components of the page when the initial body.innerHTML was defined!
            clearTimeout(tagger_response_timer_id);
            /*var tagged_text = document.body.innerHTML;
            tagged_text = extract_xmlhttp.responseText;
            console.log(tagged_text);*/
            document.body.innerHTML= extract_xmlhttp.responseText;
            //console.log(document.body.innerHTML);
            throw_alert(1);
            //extract_add_full_page_tagged_div();
			//the line below creates a floating pop-up with a color index for EXTRACT entities; this has been shown to cause trouble
			//for some browsers due to ad-blocking and pop-up block options and extensions.  Remove comments to re-enable
            //extract_show_entity_type_legend(extract_head);
         }
      }
   };



   //send request after all data, url and progress events have beed defined
   var url=cpr_tagger_url + get_tagged_html_webapp;
   extract_xmlhttp.open("POST", url, true);
   extract_xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");//the connection needs to be open first
   extract_xmlhttp.send( extract_params );


}










// Show Popup Method by processing the supplied text
/////////////////////////////////////////////////////////////////////////////////////////////
function extract_show_popup( user_selected_text ) {

    var selected_text = arguments[0];

    //check and apply length limit if necessary
    if (selected_text.length > selected_text_character_limit)
    {
       selected_text = selected_text.substring(0, selected_text_character_limit);
       selected_text = selected_text.replace(/\s(\w+)$/, ""); //removes the last word, i.e. removes partial word truncations
       selected_text = selected_text + " [...]";
    }

    //get the source page url
    var source_page_uri = encodeURIComponent ( window.location.href );


    if ( debug ) {   console.log( "Selected text for curation: " + selected_text ); }
    if ( debug ) {   console.log( "Source page is: " + decodeURIComponent ( source_page_uri )); }
    if ( debug ) {   console.log( "Entity types are: " + entity_types ); }


    // house keeping: close any previous instances of the popup
    if ( document.getElementById("extract_popup") != null) {
       document.getElementById("extract_popup").remove();
    }

    // house keeping: add scripts and styles
    // NB: the order is important!
    // jQuery-ui draggability is enabled after both jQuery and jQuery-ui have been successfully loaded
    extract_getScript('https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js',function(){
       if ( debug ) { console.log( 'jQuery loaded' ) };
    });
    extract_getScript('https://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.js',function(){
       $('#extract_popup').draggable() ;
       if (debug ) { console.log( 'jQuery-ui loaded, draggable enabled' ) };
    });
    extract_addStyle(extract_head, "", cpr_extract_base_url + "styles/extract.css")

    // create popup elements
    ////////////////////////

    // popup outermost container
    var extract_popup_div = document.createElement('div');
    extract_popup_div.setAttribute ( "id","extract_popup");
    extract_popup_div.setAttribute ( "class","extract_popup");

    //popup header container
    var extract_popup_header_div = document.createElement('div');
    extract_popup_header_div.setAttribute ( "id", "extract_popup_header");
    extract_popup_header_div.setAttribute ( "class", "extract_popup_header");

    //popup header action links/buttons

    // Open help page
    var help_anchor  = document.createElement('a');
    help_anchor.setAttribute ( "id", "help_anchor");
    help_anchor.setAttribute ( "onclick","extract_openInNewTab( cpr_extract_base_url + '#extract_help');");
    help_anchor.setAttribute ( "title", "Open Help Page");
    help_anchor.innerHTML = "?";

    // Open popup in a new page
    var pop_out_anchor = document.createElement('a');
    pop_out_anchor.setAttribute ( "id", "pop_out_anchor");
    var new_tab_url = cpr_tagger_url + "Extract?document=" + encodeURIComponent( selected_text ) + "&entity_types=" + entity_types + "&uri=" + source_page_uri ;
    pop_out_anchor.setAttribute ( "onclick", "extract_openInNewTab( '"+new_tab_url+"');" );
    pop_out_anchor.setAttribute ( "title", "Open Popup in New Tab");
    pop_out_anchor.innerHTML = "&#8679;"; //unicode for the UP pointing arrow like the shift button

    // Close popup
    var close_anchor = document.createElement('a');
    close_anchor.setAttribute ( "id", "close_anchor");
    close_anchor.setAttribute ( "onclick", "var extract_popup_elem = document.getElementById('extract_popup'); extract_popup_elem.parentNode.removeChild(extract_popup_elem);" );
    close_anchor.setAttribute ( "title", "Close Popup");
    close_anchor.innerHTML =  "&#10005;"; //unicode for MULTIPLICATION X



    //popup header title
    var extract_header_title_div = document.createElement('div');
    extract_header_title_div.setAttribute ( "id","extract_header_title");
    extract_header_title_div.innerHTML = "EXTRACT";

    //popup iframe
    var extract_iframe = document.createElement('iframe');
    extract_iframe.setAttribute ( "id", "extract_iframe");
    extract_iframe.setAttribute ( "class", "extract_iframe");
    var iframe_url = cpr_tagger_url + popup_webapp +"?document=" + encodeURIComponent( selected_text ) + "&entity_types=" + entity_types + "&uri=" + source_page_uri ;
    extract_iframe.setAttribute ( "src", iframe_url);


    // Build the popup element hierarchy
    ///////////////////////////////////

    //popup header coomponents in popup header
    extract_popup_header_div.appendChild( extract_header_title_div );
    extract_popup_header_div.appendChild( help_anchor );
    extract_popup_header_div.appendChild( pop_out_anchor );
    extract_popup_header_div.appendChild( close_anchor );

    // popup header and iframe in popup
    extract_popup_div.appendChild( extract_popup_header_div );
    extract_popup_div.appendChild( extract_iframe );

    // popup in the page (enable draggability too)
    extract_body.appendChild ( extract_popup_div );
    //add the ESC key pressed event hanlder to close the popup
    document.addEventListener ("keyup", function ( event ) { extract_handle_key_up ( event ) }, true);



    //House keeping: clean up javascripts
    extract_clean_up();
}//end of extract_show_popup






// helper methods
//////////////////////////////////////////////////////////////////////////////////////////

//helper method to get the search terms from the url
function get_search_terms(id) {
	var script_tag=document.getElementById(id);
	var query=script_tag.src.replace(/^[^\?]+\??/,'');
	//parse the querystring into arguments and parameters
	var vars = query.split("&");
	var args={};
	for (var i=0; i<vars.length;i+=1)
	{
		var pair=vars[i].split("=");
		args[pair[0]]=pair[1];
	}
	return args;
}




function extract_handle_key_up (event) {
   if (event.which == "27" ){//27 => "ESC key"
      if (document.getElementById('extract_popup') != null) {//close popup (if it exists)
         document.getElementById('extract_popup').remove();
      }
   }
}



function extract_addStyle(parent_node, id, href) {
  var new_style = document.createElement( 'link' );
  if ( id != "") {
       new_style.setAttribute( 'id', id );
   }
  new_style.setAttribute( 'type', "text/css" );
  new_style.setAttribute( 'rel', "stylesheet" );
  new_style.setAttribute( 'href', href );
  parent_node.appendChild( new_style );
}

function extract_openInNewTab( url ) {
   var win = window.open(url, '_blank');
   win.focus();
}

/* last step: remove the script injected by the bookmarklet */
function extract_clean_up() {
    if (document.getElementById("extract_js_script") ) { document.getElementById("extract_js_script").remove() };
}

/*
 * method taken from: http://stackoverflow.com/questions/5379120/get-the-highlighted-selected-text
 */
function extract_getSelectionText() {
    var text = "";
    if (window.getSelection) {
        text = window.getSelection().toString();
    } else if (document.selection && document.selection.type != "Control") {
        text = document.selection.createRange().text;
    }
    return text;
}


/*
 * Reflect tag inherited methods:  upon clicking,
 * mousing over/out of tags in fully tagged pages
 * show EXTRACT popup with that term
 */
function stopReflectPopupTimer(){
    clearTimeout( extract_popup_mouseover_timer  );
}

function startReflectPopupTimer(){
    var tag_matched_text = arguments[1];
	console.log(arguments);
    extract_popup_mouseover_timer = setTimeout( function (){
            extract_show_popup ( tag_matched_text );
        },  extract_popup_mouseover_waiting_period );
}

function showReflectPopup() {
    var tag_matched_text = arguments[1];
    extract_show_popup ( tag_matched_text );
}


