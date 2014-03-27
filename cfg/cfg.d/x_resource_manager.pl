# resourcemanager_filter_fields
#
# These are the fields that you want to use with the resourcemanager filter.
# The fields must be multiple value text fields in order to be used. If they
# aren't then they will be ignored.
$c->{resourcemanager_filter_fields} = [
	'keywords',
	'view_permissions',
	'validation_status',
];
