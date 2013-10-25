$c->{user_roles}->{user} = [qw{
	general
	set-password
	change-email
	deposit
	edit-own-record
	+eprint/archive/edit:owner
	+eprint/archive/remove:owner
}];

$c->{user_roles}->{editor} = [qw{
	general
	set-password
	change-email
	deposit
	edit-own-record
	editor
	+redo_thumbnails
}];

$c->{user_roles}->{admin} = [qw{
	general
	edit-own-record
	set-password
	change-email
	deposit
	editor
	view-status
	staff-view
	admin
	edit-config
	+redo_thumbnails
}];

$c->{public_roles} = [qw{
	+eprint/archive/rest/get
	+subject/rest/get
}];
