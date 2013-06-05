# override citations
$c->{edshare_core_session_init} = $c->{session_init};
$c->{session_init} = sub {
	my ( $repo, $offline ) = @_;

	$repo->call("edshare_core_session_init");
#	$repo->{citations}->{eprint}->{default} = $repo->{citations}->{eprint}->{edshare_default};
};





$c->{edshare_core_set_eprint_automatic_fields} = $c->{set_eprint_automatic_fields}; 

$c->{set_eprint_automatic_fields} = sub
{
	my ($eprint) = @_;
	my $repo = $eprint->{session};

	$repo->call('edshare_core_set_eprint_automatic_fields', $eprint);

	# normalise the keywords (if any) for the browse views
	my $k = $eprint->get_value( "raw_keywords" ); 
	unless( EPrints::Utils::is_set( $k ) )
	{ 
		$eprint->set_value( "keywords", undef ); 
	} 
	else
	{
		my @nk;
		foreach(@$k)
		{
			push @nk, EPrints::Plugin::EdShareCoreUtils::normalise_keyword( $_ );
		}
		$eprint->set_value( "keywords", \@nk );
	}
};

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

$c->{set_eprint_defaults} = sub
{
	my( $data, $session ) = @_;
# EdShare - Makes the default eprint type a "resource"
	if(!EPrints::Utils::is_set( $data->{type} ))
	{
		$data->{type} = "resource";	
	}

# add the depositor as first creator:

	my $user = $session->current_user;
        if(defined $user)
	{
                my %creator;
                $creator{name} = $user->get_value("name");
                $creator{id} = $user->get_value("email");
                my @creators;
                $creators[0] = \%creator;
                $data->{creators} = \@creators;
        }


#mrt - need to change viewperms to be less stupid
        if(!defined $data->{viewperms})
        {
                $data->{viewperms} = "uni_public";
        }

};


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
	'render_value' => 'EPrints::Plugin::EdShareCoreUtils::render_creators_name'
},

{
	'name' => 'title',
	'type' => 'longtext',
	# EdShare - Input rows reduced to encourage sensible length titles
	'input_rows' => 1,
	'make_value_orderkey' => sub 
	{
		my( $field, $value ) = @_;
		return $value unless( $value =~ /^Lecture/ );
		$value =~ s/(\d+)/sprintf("%08d",$1)/ge;
		return $value;
		}
	},

# Edshare - Keywords changed to be a multiple field so that browse views can be made.
{
	'name' => 'keywords',
	'type' => 'text',
	'multiple' => 1,
	'text_index' => 1,
	'render_single_value' => 'EPrints::Plugin::EdShareCoreUtils::render_single_keyword',
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
	'name' => 'viewperms',
	'type' => 'set',
	'options' => [
		'private',
		'registered_only',
		'public',
	],
	'input_style' => 'radio',
	'allow_null' => 0,
},

# The following are core fields which arent used in EdShare Core but EPrints wont let us remove
{
	'name' => 'date',
	'type' => 'date',
	'min_resolution' => 'year',
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
];

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
	variations => [
		"creators_name;first_letter",
		"type",
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
	variations => [
		"type",
		"DEFAULT",
	],
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

$c->{search}->{advanced} = 
{
# EdShare - Made new fields searchable and added some new order methods
	search_fields => [
		{ meta_fields => [ $EPrints::Utils::FULLTEXT ] },
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
				"datestamp", 
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
		


######################################################################
#
# Advanced Options
#
# Don't mess with these unless you really know what you are doing.
#
######################################################################

# Example page hooks to mess around with the metadata
# submission page.

# my $doc = EPrints::XML::make_document();
# my $link = $doc->createElement( "link" );
# $link->setAttribute( "rel", "copyright" );
# $link->setAttribute( "href", "http://totl.net/" );
# $c->{pagehooks}->{submission_meta}->{head} = $link;
# $c->{pagehooks}->{submission_meta}->{bodyattr}->{bgcolor} = '#ff0000';


# 404 override. This is handy if you want to catch some urls from an
# old system, or want to make some kind of weird dynamic urls work.
# It should be handled before it becomes a 404, but hey.
# If the function returns a string then the browser is redirected to
# that url. If it returns undef then then the normal error page is shown.
# $c->{catch404} = sub {
#	my( $session, $url ) = @_;
#	
#	if( $url =~ m#/subject-(\d+).html$# )
#	{
#		return "/views/subjects/$1.html";
#	}
#	
#	return undef;
# };

# If you use the Latex render function and want to use the mimetex
# package rather than the latex->dvi->ps->png route then enable this
# option and put the location of the executable "mimetex.cgi" into 
# SystemSettings.pm
$c->{use_mimetex} = 0;

# This is a list of fields which the user is asked for when registering
# If true then use cookie based authentication.
# Don't use basic login unless you are coming from EPrints 2.
$c->{cookie_auth} = 1;

# If you are setting up a very simple system or 
# are starting with lots of data entry you can
# make user submissions bypass the editorial buffer
# by setting this option:
# EdShare - Disabled buffer because it allows content to be added more easily.
$c->{skip_buffer} = 1;

# Supress the public user information page. Useful if you have
# data protection concerns.
$c->{disable_userinfo} = 0;

# If 1, users can request the removal of their submissions from the repository
$c->{allow_user_removal_request} = 1;

# domain for the login and lang. cookies to be set in.
$c->{cookie_domain} = $c->{host};

######################################################################
#
# Timeouts
#
######################################################################

# Time (in hours) to allow a email/password change "pin" to be active.
# Set a time of zero ("0") to make pins never time out.
$c->{pin_timeout} = 24*7; # a week

# Search cache.
#
#   Number of minutes of unuse to timeout a search cache
$c->{cache_timeout} = 10;

#   Maximum lifespan of a cache, in use or not. In hours.
#   ( This will be the length of time an OAI resumptionToken is 
#   valid for ).
$c->{cache_maxlife} = 12;


# Generic Plugin Options

# To disable the plugin "Export::BibTeX":
# $c->{plugins}->{"Export::BibTeX"}->{params}->{disable} = 1;

# To enable the plugin "Export::LocalThing":
# $c->{plugins}->{"Export::LocalThing"}->{params}->{disable} = 0;

# Screen Plugin Configuration
# (Disabling a screen will also remove it and it's actions from all lists)

# To add the screen Screen::Items to the key_tools list at postion 200:
# $c->{plugins}->{"Screen::Items"}->{appears}->{key_tools} = 200;

# To remove the screen Screen::Items from the key_tools list:
# $c->{plugins}->{"Screen::Items"}->{appears}->{key_tools} = undef;
#$c->{plugins}->{"Screen::EPrint::UseAsTemplate"}->{icon} = "action_edit.png";

# Screen Actions Configuration

# To disable action "blah" of Screen::Items 
# (Disabling an action will also remove it from all lists)
# $c->{plugins}->{"Screen::Items"}->{actions}->{blah}->{disable} = 1;

# To add action "blah" of Screen::Items to the key_tools list at postion 200: 
# $c->{plugins}->{"Screen::Items"}->{actions}->{blah}->{appears}->{key_tools} = 200;

# To remove action "blah" of Screen::Items from the key_tools list
# $c->{plugins}->{"Screen::Items"}->{actions}->{blah}->{appears}->{key_tools} = undef;


# Import/export plugins

# to make a plugin only available to staff
# $c->{plugins}->{"Export::Text"}->{params}->{visible} = "staff";

# to only command line tools
# $c->{plugins}->{"Export::Text"}->{params}->{visible} = "api";

# to prevent a import/export plugin from being shown as an option, but
# not actually disable it.
# $c->{plugins}->{"Export::BibTeX"}->{params}->{advertise} = 0;


# Plugin Mapping

# The following would make the repository use the LocalDC export plugin
# anytime anything asks for the DC plugin - this is a handy way to override
# the behaviour without hacking the existing plugin. 
# $c->{plugin_alias_map}->{"Export::DC"} = "Export::LocalDC";
# This line just means that the LocalDC plugin doesn't appear in addition
# as that would be confusing. 
# $c->{plugin_alias_map}->{"Export::LocalDC"} = undef;
       
#$c->{plugin_alias_map}->{"Screen::View::Owner"} = undef;
# CrossRef registration

# You should replace this with your own CrossRef account username and password.

$c->{plugins}->{"Import::DOI"}->{params}->{pid} = "ourl_eprintsorg:eprintsorg";

$c->{plugins}->{"Issues"}->{params}->{disable} = 1;
$c->{plugins}->{"Issues::ExactTitleDups"}->{params}->{disable} = 1;
$c->{plugins}->{"Issues::SimilarTitles"}->{params}->{disable} = 1;
$c->{plugins}->{"Issues::XMLConfig"}->{params}->{disable} = 1;

# EdShare - Plugin config
# EdShare - Disable the Review screen.
$c->{plugins}->{"Screen::Review"}->{params}->{disable} = 1;
# EdShare mask the View plugin with a custom plugin that redirects users to their item page.
$c->{plugin_alias_map}->{"Screen::EPrint::View::Owner"} = "Screen::RedirectToItems";
$c->{plugin_alias_map}->{"Screen::EPrint::View::Editor"} = "Screen::RedirectToItems";
# EdShare - Adds use as template to the manage deposits screen.

# mrt - this plugin doesn't even exist yet
#$c->{plugins}->{"Screen::EPrint::UseAsTemplate"}->{actions}->{use_as_template}->{appears}->{eprint_item_actions} = 20;

# Assemble EdShare Toolbox
$c->{plugins}->{"Screen::EPrint::Edit"}->{appears}->{edshare_toolbox} = 10;

$c->{can_request_view_document} = sub
{
	return "ALLOW";
};

# Return "ALLOW" if the given user can view the given document,
# otherwise return "DENY".
$c->{can_user_view_document} = sub
{
	my( $doc, $user ) = @_;

	my $eprint = $doc->get_eprint();

	# TODO
	# probably something like:
	return "ALLOW" if( $eprint->can_be_viewed( $user ) );
	return "DENY";

};

$c->{"edshare_choose_workflow"} = sub {
	my ( $eprint ) = @_;

	my $type = $eprint->value("type"); 

	if($type eq "collection")
	{
		return "collection";
	}
	
	if($type eq "resource")
	{
		return "edshare";
	}
	
	return "default";
	
};

$c->{edshare_screen_after_edit} = "Items";

$c->{plugin_alias_map}->{"Screen::EPrint::Edit"} = "Screen::EPrint::EdShareEdit";
$c->{plugin_alias_map}->{"Screen::EPrint::CollectionEdit"} = "Screen::EPrint::EdShareEdit";
$c->{plugin_alias_map}->{"Screen::EPrint::EdShareEdit"} = undef;
$c->{plugins}->{"Screen::EPrint::EdShareEdit"}->{params}->{disable} = 0;

# Custom summary screen
#$c->{plugin_alias_map}->{"Screen::EPrint::Summary"} = "Screen::EPrint::LocalSummary";
#$c->{plugin_alias_map}->{"Screen::EPrint::LocalSummary"} = undef;

# UseAsTemplate -> redirects to edit page after cloning
#$c->{plugin_alias_map}->{"Screen::EPrint::UseAsTemplate"} = "Screen::EPrint::LocalUseAsTemplate";
#$c->{plugin_alias_map}->{"Screen::EPrint::LocalUseAsTemplate"} = undef;

# The 'Manage Records' screen:
$c->{plugins}->{"Screen::DataSets"}->{appears}->{admin_actions_system} = 1600;
$c->{plugins}->{"Screen::DataSets"}->{appears}->{key_tools} = undef;

$c->{plugins}->{"Screen::EPrint::Box::BookmarkTools"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::EPrint::Box::CollectionMembership"}->{params}->{disable} = 1;

$c->{plugins}->{"Screen::EPrint::Edit"}->{appears}->{edshare_toolbox} = 20;
$c->{plugins}->{"Screen::EPrint::ExportZip"}->{appears}->{edshare_toolbox} = 29;
$c->{plugins}->{"Screen::EPrint::Public::RequestCopy"}->{action}->{request}->{appears}->{edshare_toolbox} = 40;
$c->{plugins}->{"MePrints::Widget::EPrintsIssues"}->{params}->{disable} = 1;
#$c->{plugins}->{"MePrints::Widget::Repostats::Downloads"}->{params}->{disable} = 1;
#$c->{plugins}->{"MePrints::Widget::Repostats::TopTen"}->{params}->{disable} = 1;
# Use RepoStats' one
$c->{plugins}->{"MePrints::Widget::TopTen"}->{params}->{disable} = 1;

$c->{plugins}->{"InputForm::Component::Field::TagLite"}->{params}->{disable} = 0;
$c->{plugins}->{"TagCloud"}->{params}->{disable} = 0;
#add mimetypes for css and javascript so they are served properly
$c->{mimemap}->{css}  = "text/css";
$c->{mimemap}->{js}  = "text/javascript";


