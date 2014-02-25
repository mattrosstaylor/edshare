$c->{fields}->{document} = [
# EdShare - This field adds a description to a document which outlines what it is intended to be used for.
	{
		'name' => 'description',
		'type' => 'text',
		'input_cols' => '45',
#		'render_value' => 'EPrints::Extras::render_document_description'
	},
# EdShare - "Share a link" features
          {
            'name' => 'use_local_copy',
            'type' => 'boolean',
          },
          {
            'name' => 'source_url',
            'type' => 'text',
            'input_cols' => '45',
          }


];

$c->{fields}->{eprint} = [
{
	'name' => 'creators',
	'type' => 'compound',
	'multiple' => 1,
	'fields' => [
	{
		'sub_name' => 'name',
		'type' => 'name',
		'hide_honourific' => 1,
		'hide_lineage' => 1,
		# EdShare - Render order changed so given name is rendered before family name to make the respository more personal
		'family_first' => 0,
		'render_order' => 'gf',
	},
	{
		'sub_name' => 'id',
		'type' => 'text',
		'input_cols' => 20,
		'allow_null' => 1,
	}],
	'input_boxes' => 1,
	'input_ordered' => 0,
	'render_value' => 'EPrints::Plugin::EdShareUtils::render_creators_name',

	'allow_null' => 1,
},

{
	'name' => 'title',
	'type' => 'longtext',
	# EdShare - Input rows reduced to encourage sensible length titles
	'input_rows' => 1,
},

# Edshare - Keywords changed to be a multiple field so that browse views can be made.
{
	'name' => 'keywords',
	'type' => 'text',
	'multiple' => 1,
	'text_index' => 1,
	'render_single_value' => 'EPrints::Plugin::EdShareUtils::render_single_keyword',
#	    'input_advice_below' => sub { return shift->html_phrase( "Field/TagLite:keywords:advice_below" ); },
},

{
	'name' => 'abstract',
	'type' => 'longtext',
	# EdShare - Input rows reduced to make the workflow a bit less menacing.
	'input_rows' => 3,
},

# EdShare - Added field so users can advise on how they can reuse this resource. 
{
	'name' => 'advice',
	'type' => 'longtext',
	'input_rows' => 3,
},

# EdShare - Viewing Permissions ("Sharing with")

{
	'name' => 'view_permissions',
	'type' => 'compound',
	'multiple' => 1,
	'fields' => [
		{
			'sub_name' => 'type',
			'type' => 'namedset',
			'set_name' => 'view_permissions',
		},
 		{
			'sub_name' => 'value',
			'type' => 'text',
			'input_cols' => 20,
		}
	],
},

{
	'name' => 'edit_permissions',
	'type' => 'compound',
	'multiple' => 1,
	'fields' => [
		{
			'sub_name' => 'type',
			'type' => 'namedset',
			'set_name' => 'edit_permissions',
		},
 		{
			'sub_name' => 'value',
			'type' => 'text',
			'input_cols' => 20,
		}
	],
},


{
	'name' => 'raw_keywords',
	'type' => 'text',
	'multiple' => 1,
	'text_index' => 1,
},

{
	'name' => 'license',
	'type' => 'namedset',
	'set_name' => 'licenses',
},

{
	'name' => 'validation_status',
	'type' => 'set',
	'options' => [
		'ok',
		'error',
	],	
},

# The following are core fields which arent used in EdShare but EPrints wont let us remove
{
	'name' => 'date',
	'type' => 'date',
	'min_resolution' => 'year',
},

];

