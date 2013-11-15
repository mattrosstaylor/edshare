$c->{search}->{simple} = 
{
# EdShare - Removed fields which are no longer in EdShare config and added advice
	search_fields => [
		{
			id => "q",
			meta_fields => [
				$EPrints::Utils::FULLTEXT,
				"title",
				"abstract",
				"creators_name",
				"keywords",
				"advice",
			]
		},
	],
	preamble_phrase => "cgi/search:preamble",
	title_phrase => "cgi/search:simple_search",
	citation => "result",
	page_size => 20,
	order_methods => {
		"byyear" 	 => "-datestamp/creators_name/title",
		"byyearoldest"	 => "datestamp/creators_name/title",
		"byname"  	 => "creators_name/-datestamp/title",
		"bytitle" 	 => "title/creators_name/-datestamp"
	},
	default_order => "byyear",
	show_zero_results => 1,
};

$c->{search}->{advanced} = 
{
# EdShare - Made new fields searchable and added some new order methods
	search_fields => [
		{ meta_fields => [ "title" ] },
		{ meta_fields => [ "creators_name" ] },
		{ meta_fields => [ "abstract" ] },
		{ meta_fields => [ "keywords" ] },
		{ meta_fields => [ "advice" ] },
		{ meta_fields => [ "type" ] },
		{ meta_fields => [ "documents.format" ] },
	],
	preamble_phrase => "cgi/advsearch:preamble",
	title_phrase => "cgi/advsearch:adv_search",
	citation => "result",
	page_size => 20,
	order_methods => {
		"byyear" 	 => "-datestamp/creators_name/title",
		"byyearoldest"	 => "datestamp/creators_name/title",
		"byname"  	 => "creators_name/-datestamp/title",
		"bytitle" 	 => "title/creators_name/-datestamp"
	},
	default_order => "byyear",
	show_zero_results => 1,
};

$c->{datasets}->{eprint}->{search}->{staff} =
{
	search_fields => [
		{ meta_fields => [qw( eprintid )] },
		{ meta_fields => [qw( userid.username )] },
		{ meta_fields => [qw( userid.name )] },
		{ meta_fields => [qw( eprint_status )], default=>"archive buffer" },
		{ meta_fields => [qw( dir )] },
		@{$c->{search}{advanced}{search_fields}},
	],
	preamble_phrase => "Plugin/Screen/Staff/EPrintSearch:description",
	title_phrase => "Plugin/Screen/Staff/EPrintSearch:title",
	citation => "result",
	page_size => 20,
	order_methods => {
		"byyear" 	 => "-date/creators_name/title",
		"byyearoldest"	 => "date/creators_name/title",
		"byname"  	 => "creators_name/-date/title",
		"bytitle" 	 => "title/creators_name/-date"
	},
	default_order => "byyear",
	show_zero_results => 1,
};
