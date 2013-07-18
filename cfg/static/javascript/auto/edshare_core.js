/* edshare core javascript */
function edshare_core_render_toolbox(targetId, eprintid, listName, listType) {
	new Ajax.Request( eprints_http_cgiroot +"/edshare_toolbox", {
	  method: "get",
	  parameters:{'eprintid':eprintid, "listtype":listType, "listname":listName},
	  onSuccess: function(response) {
		$(targetId).innerHTML = response.responseText;
	  }
	});	

}

/*javascript for taglite*/

// what if we don't want to have a max || max == 0?

// certainly on EdShare we don't want a max number of tag for an item...
function inputTagLite( el_target, max, varname, prefix, edshare_field )
{
	this.counter = 0;
	this.max = max;

	// tags would be appended to this DOM element:
	this.daddy = el_target;
	this.tags_ref = new Array();
	this.varname = varname;

	// to know how to call variables
	this.prefix = prefix;
	this.field = edshare_field;
        this.initTagLine = function( el ) {
                var tagline = el.value;
                var tags = tagline.split( "," );
                var done = 0;

                for(i=0;i<tags.length;i++) {
                        this.initTag( tags[i] );
                        done++;
                }

                if(done > 0) {
                        el.value = "";
                }

                return false;
        }

	/* This carries out extra checks  */
        this.initTagLine_CoursesCodes = function( el ) {
                var tagline = el.value;
                var tags = tagline.split( "," );
                var done = 0;

		var newline = "";
		var invalid = "";

                for(i=0;i<tags.length;i++)
                {
			if( (! /\w\w\w\w\d\d\d\d/.test(tags[i])) && tags[i] != "" )
			{
				invalid += tags[i] + "\n";
				newline += tags[i] + ",";
			}
			else
			{
	                        if(this.initTag( tags[i] ))
				{
		                        done++;
				}
			}
                }

		if(invalid.length != 0)
		{
			// problematic course codes
			el.value = newline;
			alert( "The following Course Codes are invalid: \n\n"+invalid+"\nCourse codes are made of 4 letters followed by 4 digits, there is no space between the letters and digits. For example: COMP1001, SOCI2008.  Please remove the entry you have made and add the correct version.");
		}
		else
		{
	                if(done > 0)
        	        {
                	        el.value = "";
	                }
		}

                return false;

        }

	this.initTag = function( tag ) 
	{

                if( this.max > 0 && this.counter >= this.max)
                {
                        return false;
                }
	
                if( tag.length == 0 )
                {
                        return false;
                }

                if( this.tags_ref[ tag ] == '1' )
                {
                        return false;           // already have that tag!
                }

		this.daddy.appendChild( createTagDiv( tag, ''+this.counter, varname, prefix, this.field ) );
		this.tags_ref[ tag ] = '1';
		this.counter++;
		return true;
	}

// old method, when it was called from an 'onclick' event
// could be removed?

	this.addTag = function( tag_el ) {
		// to disable this method:
		return false;

		if( this.max > 0 && this.counter >= this.max)
		{
			return false;
		}

		var tag = tag_el.value;
		if( tag.length == 0 )
		{
			return false;
		}

		if( this.tags_ref[ tag ] == '1' )
		{	
			return false;		// already have that tag!
		}

		this.daddy.appendChild( createTagDiv( tag, ''+this.counter, varname, prefix,this.field ) );
		this.tags_ref[ tag ] = '1';
		this.counter++;
		tag_el.value = "";
		return false;
	};

	this.remTag = function( tagid, tag ) 
	{
		var tagdiv = document.getElementById( "container_"+tagid );
		tagdiv.parentNode.removeChild( tagdiv );
		delete this.tags_ref[ tag ];
		this.counter--;
		return false;
	};


	this.clear = function () {
		/* not implemented yet */
		return false;
	};

};

function createTagDiv( tag, id, varname, prefix, field )
{
	var tagid = prefix+"_"+id;
	var tagdiv = new Element( 'div', { 'id': "container_"+tagid } );
	if( field != 'raw_keywords' )
	{
		tag = tag.toUpperCase();
	}
	
	// replaces white spaces with "" for searches => no longer true for /view/ ?
	var ntag = tag;		//.replace( / /gi, "" );
	var searchlink = new Element( 'a', {
		"target": "_blank",
		"href": "/view/"+field+"/"+ntag+"/"
	} );
	searchlink.update( tag );

	tagdiv.appendChild( searchlink );
	
	var spaces = document.createTextNode( "     " );
	tagdiv.appendChild( spaces );

	var image_uri = eprints_http_root + '/style/images/xit.gif';

	var remtag = new Element( 'button' );
	remtag.setStyle( {
		'background': 'url('+image_uri+') 0 0',
		'cursor': 'pointer',
		'height': '10px',
		'width': '10px',
		'outline-style': 'none',
		'outline-color': 'invert',
		'outline-width': '0px',
		'border': '0px',
		'padding': '0px',
		'margin': '0px 0px 0px 10px',
		'font-size': '100%'
	} );

	remtag.style.verticalAlign = 'middle';

	remtag.observe( 'click', function() {
		eval( varname + '.remTag( "'+tagid+'","'+tag+'");' );
		return false;
	} );
	remtag.observe( 'mouseover', function() {
		this.setStyle( { 'background':  'url('+image_uri+') -10px 0' } );
	} );
	remtag.observe( 'mouseout', function() {
		this.setStyle( { 'background':  'url('+image_uri+') 0 0' } );
	} );

	var form_input = new Element( 'input', {
		'type': 'hidden',
		'name': tagid,
		'value': tag
	} );

	tagdiv.appendChild( remtag );
	tagdiv.appendChild( form_input );

	return tagdiv;
};

function addInlineTag( inputid, tag )
{
	var el = $( inputid );
	if( el != null )
	{
		el.value = tag+","+el.value;
	}
	return false;
} 


/* javascript for view permissions render */

function showAdvancedCheckbox(basename) {
		$('submit-values').innerHTML = "<input type='hidden' value='restricted' />";
		$(basename+'_advanced').show();
}
function hideAdvancedCheckbox(basename,value) {

		$(basename+'_advanced').hide();
		$(basename+'_advanced_options').hide();
		$(basename+'_advanced_checkbox').checked = false;
		if(value == 'public')
		{
			$('submit-values').innerHTML = "<input type='hidden' value='public' />";
		}
		if(value == 'private')
		{
			$('submit-values').innerHTML = "<input type='hidden' value='private' />";
		}

}
function showAdvancedOptions(basename) {
	if($(basename+'_advanced_checkbox').checked)
	{
		$('submit-values').innerHTML = "";
		$(basename+'_advanced_options').show();
	}
	else
	{
		$('submit-values').innerHTML = "<input type='hidden' value='restricted' />";
		$(basename+'_advanced_options').hide();
	}			
}
function addPermissionType(basename) {
	document[basename+"_count"]++;
	$('submit-values').innerHTML += "<div id='"+basename+"_"+document[basename+"_count"]+"_container'>"+
		$(basename+'_type').value + ": " + $(basename+'_type_value').value + "<a href='#' onclick='deletePermissionType(\""+basename+"_"+document[basename+"_count"]+"_container\"); return false'>X</a>" + 
		"<input type='hidden' name='"+basename+"_"+document[basename+"_count"]+"_type' value='"+$(basename+'_type').value+"' />" + 


		"<input type='hidden' name='"+basename+"_"+document[basename+"_count"]+"_value' value='"+$(basename+'_type_value').value+"' />" +
		"</div>";
	$(basename+'_type_value').value = "";
	$(basename+"_spaces").writeAttribute('value', document[basename+"_count"]);
}
function deletePermissionType(container){
	$(container).remove();
}

function initPermsField(basename)
{
	if($(basename+"_restricted").checked)
	{
		$(basename+"_advanced").show();
		if($(basename+"_advanced_checkbox").checked)
		{
			$(basename+"_advanced_options").show();
		}

	}
}

function doAutoComplete(basename)
{

	new Ajax.Autocompleter(basename+"_type_value", basename+"_autocomplete_choices", eprints_http_cgiroot +"/users/lookup/view_permissions", {
	  paramName: "query", 
	  minChars: 2, 
	  parameters: "type="+$(basename+"_type").value+"&basename="+basename
//	  indicator: 'indicator1'
	});

}
