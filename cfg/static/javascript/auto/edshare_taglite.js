/*javascript for taglite*/

function inputTagLite( varname, prefix, edshare_field )
{
	this.counter = 0;

	// tags would be appended to this DOM element:
	this.values = document.getElementById(prefix +"_values");
	this.placeholder = document.getElementById(prefix +"_placeholder");
	this.tags_ref = new Array();
	this.varname = varname;

	// to know how to call variables
	this.prefix = prefix;
	this.field = edshare_field;
        this.addFromInput = function( el ) {
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

	this.initTag = function( tag )
	{
                if( tag.length == 0 )
                {
                        return false;
                }

                if( this.tags_ref[ tag ] == '1' )
                {
                        return false;           // already have that tag!
                }

		this.values.appendChild( createTagDiv( tag, ''+this.counter, varname, prefix, this.field ) );
		this.tags_ref[ tag ] = '1';
		this.counter++;
		this.checkCount();
		return true;
	}

// old method, when it was called from an 'onclick' event
// could be removed?

	this.addTag = function( tag_el ) {
		// to disable this method:
		return false;

		var tag = tag_el.value;
		if( tag.length == 0 )
		{
			return false;
		}

		if( this.tags_ref[ tag ] == '1' )
		{
			return false;		// already have that tag!
		}

		this.values.appendChild( createTagDiv( tag, ''+this.counter, varname, prefix,this.field ) );
		this.tags_ref[ tag ] = '1';
		this.counter++;
		this.checkCount();
		tag_el.value = "";
		return false;
	};

	this.remTag = function( tagid, tag )
	{
		var tagdiv = document.getElementById( "container_"+tagid );
		tagdiv.parentNode.removeChild( tagdiv );
		delete this.tags_ref[ tag ];
		this.counter--;
		this.checkCount();
		return false;
	};

	this.checkCount = function() {
		if (this.counter == 0) {
			this.placeholder.style.display="block";
		}
		else {
			this.placeholder.style.display="none";
		}
	}

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

	var span = new Element( 'span', { 'class': 'edshare_taglite_tag'} );
	span.update( tag );

	tagdiv.appendChild( span );

	var spaces = document.createTextNode( "     " );
	tagdiv.appendChild( spaces );

	var image_uri = eprints_http_root + '/images/edshare/remove.png';

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

