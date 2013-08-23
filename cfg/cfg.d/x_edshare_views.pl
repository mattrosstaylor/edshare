$c->{browse_views} = [
{
	id => "year",
	menus => [
	{
		fields => [ "datestamp;res=year" ],
		reverse_order => 1,
		allow_null => 1,
		new_column_at => [10,10],
	}
	],
	order => "creators_name/title",
	citation => "result",
	variations => [
		"creators_name;first_letter",
#		"type",
		"DEFAULT"
	],
},
{
	id => "creators",
	allow_null => 0,
	hideempty => 1,
	menus => [
	{
		#EdShare - order=fg added so that the browse view still orders family name first even though the names are rendered given first.
		fields => [ "creators_name;order=fg" ],
		new_column_at => [1, 1],
		mode => "sections",
		open_first_section => 1,
		group_range_function => "EPrints::Update::Views::cluster_ranges_30",
		grouping_function => "EPrints::Update::Views::group_by_a_to_z",
	},
	],
	order => "-datestamp/title",
	citation => "result",
#	variations => [
#		"type",
#		"DEFAULT",
#	],
},


{
	id => "keywords",
	allow_null => 0,
	hideempty => 1,
	menus => [
	{
		fields => [ "keywords" ],
		new_column_at => [1, 1],
		mode => "sections",
		open_first_section => 1,
		group_range_function => "EPrints::Update::Views::cluster_ranges_30",
		grouping_function => "EPrints::Update::Views::group_by_a_to_z",
	},
	],
	order => "-datestamp/title",
	citation => "result",
},
];
