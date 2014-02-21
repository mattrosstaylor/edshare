/* javascript for  permissions render */

function permissionsCoarseSelect(basename, type) {
	$(basename+"_coarse_options").childElements().each(function(node) { node.removeClassName("selected");});
	$$('input[name="'+basename+'_coarse_type"]')[0].value = type;
	$(basename+"_"+type).addClassName("selected");

	if (type == "custom") {
		Effect.Appear($(basename+"_advanced_options"), {duration:0.5});
	}
	else {
		Effect.Fade($(basename+"_advanced_options"), {duration:0.5});
	}
}

function permissionsAddPermittedFromString(type, value, html, basename) {
	var dummyDom = new Element('div');
	dummyDom.innerHTML = html;
	permissionsAddPermitted(type, value, dummyDom.firstChild, basename);
}

function permissionsAddPermitted(type, value, html, basename) {
	var itemId = basename+"_"+type+"_"+value;


	// mrt - this is currently hard coded but i am sure i will fix that later ;)
	var list = $(basename+"_advanced_values");

	// check whether or not this item is already in the list - hahahah we can just search the entire DOM!!!
	if ($(itemId)) {
		new Effect.Highlight($(itemId));
		return;
	}

	var newItem = new Element("li", { 
		id: itemId,
		"class": "edshare_permissions_advanced_value" 
	} );
	newItem.appendChild(new Element("input", {
		"type": "hidden",
		"name": basename+"_type",
		"value": type
	}));
	newItem.appendChild(new Element("input", {
		"type": "hidden",
		"name": basename+"_value",
		"value": value
	}));
	newItem.hide();
	newItem.appendChild(html);
	permissionsAddRemoveButton(newItem);
	list.appendChild(newItem);
	Effect.Appear(newItem);
}

function permissionsInitialiseRemoveButtons(basename) {
	$(basename+"_advanced_values").childElements().each( function(element) {
		permissionsAddRemoveButton(element);
	});
}

function permissionsAddRemoveButton(element) {
	var image_uri = '/images/edshare/remove.png';

	var removeButton = new Element( 'button' );
	removeButton.setStyle( {
		'background': 'url('+image_uri+') 0 0',
		'cursor': 'pointer',
		'height': '10px',
		'width': '10px',
		'outline-style': 'none',
		'outline-color': 'invert',
		'outline-width': '0px',
		'border': '0px',
		'padding': '0px',
		'margin': '0px 0px 0px 20px',
		'font-size': '100%'
	} );

	removeButton.style.verticalAlign = 'middle';

	removeButton.observe( 'click', function() {
		this.up().remove();
		return false;
	} );
	removeButton.observe( 'mouseover', function() {
		this.setStyle( { 'background':  'url('+image_uri+') -10px 0' } );
	} );
	removeButton.observe( 'mouseout', function() {
		this.setStyle( { 'background':  'url('+image_uri+') 0 0' } );
	} );

	element.appendChild(removeButton);
}

function ep_autocompleter_user_lookup( element, target, url, searchType, basename ) {
	new Ajax.Autocompleter( element, target, url, {
		paramName: 'q',
		callback: function( el, entry ) {
			return entry + "&type=" +searchType;
		},

		onShow: function(element, update) {
			update.style.position = 'absolute';
			Position.clone(element, update, {
				setWidth: false,
				setHeight: false,
				setLeft: element.offsetLeft,
				offsetTop: element.offsetHeight
			});

			Effect.Appear(update,{duration:0.15});
		},

		updateElement: function( selected ) {
			// should do something more custom :)

			var values=new Array();
			var done = false;

			var ul = $A(selected.getElementsByTagName( 'ul' )).first();
			var lis = $A(ul.getElementsByTagName( 'li' ));

			for(var x=0; x<6; x++) {
				var li = lis[x];
				if( li != null ) {
					var myid = li.getAttribute( 'id' );
					var attr = myid.split( /:/ );
					if (attr[0] != 'for') {
						alert( "Autocomplete id reference did not start with 'for': "+myid);
						return;
					}
					if( attr[1] != 'value' ) {
						alert("Autocomplete id reference did not contain 'value': "+myid);
						return;
					}
					var id = attr[3];
					if( id == null) {
						id = '';
					}
					if( attr[1] == 'value' ) {
						var newvalue = li.innerHTML;
						rExp = /&gt;/gi;
						newvalue = newvalue.replace(rExp, ">" );
						rExp = /&lt;/gi;
						newvalue = newvalue.replace(rExp, "<" );
						rExp = /&amp;/gi;
						newvalue = newvalue.replace(rExp, "&" );

						// so id is either family, given, id, userid etc
						values[id] = newvalue;
					}
				}
			}
			var node = document.createTextNode( values["_name_honourific"] +" " +values["_name_given"] +" " +values["_name_family"] +" (" +values["_id"] +")" );
			permissionsAddPermitted("UserLookup", values["_userid"], node, basename); 

			$(element).value="";
			return false;
		}
	});
}

