/* javascript for  permissions render */


function permissionsCoarseSelect(basename,type) {
	$(basename+"_coarse_options").childElements().each(function(node) { node.removeClassName("selected");});
	$$('input[name="'+basename+'_coarse_type"]')[0].value = type;
	$(basename+"_"+type).addClassName("selected");

	if (type == "custom") {
		$(basename+"_advanced_options").show();
	}
	else {
		$(basename+"_advanced_options").hide();
	}
}

/*
function viewPermissionsRadioSelected(basename, type) {
	if (type == "restricted") {
		$(basename+'_advanced').show();
		toggleAdvancedOptions(basename);
	}
	else {
		$(basename+'_advanced').hide();
		$(basename+'_advanced_options').hide();
	}
}

function toggleAdvancedOptions(basename) {
	if($(basename+'_advanced_checkbox').checked)
	{
		$(basename+'_advanced_options').show();
	}
	else
	{
		$(basename+'_advanced_options').hide();
	}
}

function addPermissionType(basename) {
	$('submit-values').innerHTML += "<div id='"+basename+"_"+document[basename+"_count"]+"_container'>"+
		$(basename+'_type').value + ": " + $(basename+'_type_value').value + "<a href='#' onclick='deletePermissionType(\""+basename+"_"+document[basename+"_count"]+"_container\"); return false'>X</a>" +
		"<input type='hidden' name='"+basename+"_"+document[basename+"_count"]+"_type' value='"+$(basename+'_type').value+"' />" +


		"<input type='hidden' name='"+basename+"_"+document[basename+"_count"]+"_value' value='"+$(basename+'_type_value').value+"' />" +
		"</div>";
	$(basename+'_type_value').value = "";
	$(basename+"_spaces").writeAttribute('value', document[basename+"_count"]);
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
*/


function ep_autocompleter_selected_users( element, target, url, basenames, width_of_these, fields_to_send, extra_params, object_back_ref )
{
	new Ajax.Autocompleter( element, target, url, {
		paramName: 'q',
		callback: function( el, entry ) {
			var params = fields_to_send.inject( entry, function( acc, rel_id, index ) {
				return acc + '&' + rel_id + '=' + $F(basenames.relative + rel_id);
			} );

			return params + extra_params;
		},

		onShow: function(element, update) {
			var w = width_of_these.inject( 0, function( acc, cell, index ) {
				return acc + Element.getDimensions(cell).width;
			} );

			// seb - this is a dirty hack
			if( target.match("visible") ) {
				w = w * 2;
			}

			update.style.position = 'absolute';
			Position.clone(element, update, {
				setWidth: false,
				setHeight: false,
				setLeft: element.offsetLeft,
				offsetTop: element.offsetHeight
			});

			update.style.width  = w + 'px';
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

			object_back_ref.add_user(values, object_back_ref);

		}
	});
}
