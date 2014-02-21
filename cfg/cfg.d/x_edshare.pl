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
