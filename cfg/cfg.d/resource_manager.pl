#############################################
# ResourceManager Settings File
#############################################

# resourcemanager_items_screen_enabled
#
# When set to 1 the items screen will still be displayed alongside the resourcemanager
# set this to 0 to disable the items screen and only have the resourcemanager.
$c->{resourcemanager_items_screen_enabled} = 0;

# resourcemanager_display_types
#
# This is the list of eprint types that you want to manage in the resource manager.
# If this list is empty or undefined then the plugin will fallback to the list of
# eprint types specified in archives/ARCHIVEID/cfg/namedsets/eprint

#$c->{resourcemanager_display_types} = [
#	'article',
#	'resource',
#	'collection'
#];

# resourcemanager_filter_fields
#
# These are the fields that you want to use with the resourcemanager filter.
# The fields must be multiple value text fields in order to be used. If they
# aren't then they will be ignored.
$c->{resourcemanager_filter_fields} = [
	'normalised_keywords'
];

if( $c->{resourcemanager_items_screen_enabled} == 0 )
{
	$c->{plugins}->{"Screen::Items"}->{appears}->{key_tools} = undef;
	$c->{plugin_alias_map}->{"Screen::Items"} = "Screen::ResourceManager";
	$c->{plugins}->{"Screen::ResourceManager"}->{appears}->{key_tools} = 100;
}

$c->{plugins}->{"ResourceManagerFilter"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::BulkAction"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::BulkAction::Collection"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::BulkAction::Remove"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::ResourceManager"}->{params}->{disable} = 0;
