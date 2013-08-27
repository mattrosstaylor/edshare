$c->{user_roles}->{user} = [qw{
	general
	edit-own-record
	set-password
	deposit
	change-email
	+eprint/archive/edit
	+eprint/archive/remove
}];

$c->{user_roles}->{admin} = [qw{
	general
	edit-own-record
	set-password
	deposit
	change-email
	editor
	view-status
	staff-view
	admin
	edit-config
}];

$c->{public_roles} = [qw{
	+eprint/archive/rest/get
	+subject/rest/get
}];
