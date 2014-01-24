$c->{resourcemanager_filter_fields} = [
	'keywords',
	'view_permissions_type',
	'validation_status',
];

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
	'render_value' => 'EPrints::Plugin::EdShareCoreUtils::render_creators_name',

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

# The following are core fields which arent used in EdShare Core but EPrints wont let us remove
{
	'name' => 'date',
	'type' => 'date',
	'min_resolution' => 'year',
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
                        "DEFAULT" ],
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

$c->{plugins}->{"Import::DOI"}->{params}->{pid} = "ourl_eprintsorg:eprintsorg";


$c->{can_request_view_document} = sub
{
	return "ALLOW";
};


$c->{"edshare_choose_workflow"} = sub {
	my ( $eprint ) = @_;

	my $type = $eprint->value("type"); 

	if($type eq "collection")
	{
		return "collection";
	}
	
	return "default";
	
};

$c->{edshare_screen_after_edit} = "Items";

$c->{plugins}->{"Screen::DataSets"}->{appears}->{key_tools} = undef;


#add mimetypes for css and javascript so they are served properly
$c->{mimemap}->{css}  = "text/css";
$c->{mimemap}->{js}  = "text/javascript";



# mrt - this is a serious thing am I sure I want to do this....



# various Permissions stuff...

$c->{can_request_view_document} = sub
{
	my( $doc, $r ) = @_;

	my $eprint = $doc->get_eprint();
	my $status = $eprint->value( "eprint_status" );
	my $user = $eprint->repository->current_user();
	
	if( $status ne "archive" )
	{
		return( "DENY" );
	}

	if( defined $user && ($user->value( "usertype" ) eq 'admin' || $user->value( "usertype" ) eq 'editor' ))
	{
		return "ALLOW";
	}

	foreach my $permission (@{$eprint->value("view_permissions")})
	{
		if($permission->{type} eq 'public'){ return "ALLOW"; }
		if($permission->{type} eq 'restricted' && defined $user){ return "ALLOW"; }  
		if($permission->{type} eq 'user' && defined $user && $user->value("username") eq $permission->{value} ){ return "ALLOW"; } 
		if($permission->{type} eq 'department' && defined $user && $user->value("department") eq $permission->{value} ){ return "ALLOW"; } 
	}

	return "DENY";
};

$c->{can_user_view_document} = sub
{
	my( $doc, $user ) = @_;

	my $eprint = $doc->get_eprint();
	my $status = $eprint->value( "eprint_status" );

	if( $status ne "archive" )
	{
		return( "DENY" );
	}

	if( defined $user && ($user->value( "usertype" ) eq 'admin' || $user->value( "usertype" ) eq 'editor' ))
	{
		return "ALLOW";
	}

	foreach my $permission (@{$eprint->value("view_permissions")})
	{
		if($permission->{type} eq 'public'){ return "ALLOW"; }
		if($permission->{type} eq 'restricted' && defined $user){ return "ALLOW"; }  
		if($permission->{type} eq 'user' && defined $user && $user->value("username") eq $permission->{value} ){ return "ALLOW"; } 
		if($permission->{type} eq 'department' && defined $user && $user->value("department") eq $permission->{value} ){ return "ALLOW"; } 
	}

	return "DENY";

};

$c->{does_user_own_eprint} = sub
{
	my( $session, $user, $eprint ) = @_;

	return 1 if $user->get_value( "userid" ) == $eprint->get_value( "userid" );

	# add code for checking permissions here

	return 0;
};


# plugin activation
$c->{plugins}->{"EdShareToolbox"}->{params}->{disable} = 0;
$c->{plugins}->{"Export::Zip"}->{params}->{disable} = 0;
$c->{plugins}->{"InputForm::Component::Field::TagLite"}->{params}->{disable} = 0;
$c->{plugins}->{"TagLiteSuggestionList::MostPopularUserTags"}->{params}->{disable} = 0;
$c->{plugins}->{"InputForm::Component::Field::Permissions"}->{params}->{disable} = 0;
$c->{plugins}->{"PermissionType::Creators"}->{params}->{disable} = 0;
$c->{plugins}->{"PermissionType::UserLookup"}->{params}->{disable} = 0;
#  $c->{plugins}->{"TagCloud"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::BrowseViews"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::EdShareEdit"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::EdShareChangeOwner"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::EdShareViewRedirect"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::EmailAuthor"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::ExportZip"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::EPrint::RedoThumbnails"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::RedirectingLogin"}->{params}->{disable} = 0;

#plugin removal
$c->{plugins}->{"Screen::Review"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::EPrint::Document::Extract"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::EPrint::Document::Convert"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::EPrint::Document::Files"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::EPrint::UploadMethod::URL"}->{params}->{disable} = 1;

# plugin alias
$c->{plugin_alias_map}->{"Screen::EPrint::Edit"} = "Screen::EPrint::EdShareEdit";
$c->{plugin_alias_map}->{"Screen::EPrint::EdShareEdit"} = undef;

$c->{plugin_alias_map}->{"Screen::EPrint::Staff::ChangeOwner"} = "Screen::EPrint::EdShareChangeOwner";
$c->{plugin_alias_map}->{"Screen::EPrint::EdShareChangeOwner"} = undef;

$c->{plugin_alias_map}->{"Screen::Login"} = "Screen::RedirectingLogin";
$c->{plugin_alias_map}->{"Screen::EPrint::RedirectingLogin"} = undef;

$c->{plugin_alias_map}->{"Screen::EPrint::View"} = "Screen::EPrint::EdShareViewRedirect";

# toolbar stuff
$c->{plugins}->{"Screen::EPrint::ShowLock"}->{appears}->{edshare_toolbox} = 0;
$c->{plugins}->{"Screen::EPrint::Edit"}->{appears}->{edshare_toolbox} = 10;
$c->{plugins}->{"Screen::EPrint::Remove"}->{appears}->{edshare_toolbox} = 20;
$c->{plugins}->{"Screen::EPrint::Staff::ChangeOwner"}->{appears}->{edshare_toolbox} = 40;
$c->{plugins}->{"Screen::EPrint::ExportZip"}->{appears}->{edshare_toolbox} = 50;
$c->{plugins}->{"Screen::EPrint::EmailAuthor"}->{appears}->{edshare_toolbox} = 60;

$c->{plugins}->{"Screen::BrowseViews"}->{appears}->{key_tools} = 400;
