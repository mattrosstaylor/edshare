package EPrints::Plugin::Screen::EPrint::EdShareEdit;

@ISA = ( 'EPrints::Plugin::Screen::EPrint::Edit' );

use strict;

sub workflow_id
{
	my ( $self ) = @_;

	my $repo = $self->{repository};

	if ( $repo->can_call("edshare_choose_workflow") )
	{
		return $repo->call("edshare_choose_workflow", $self->{processor}->{eprint} );
	}

	return "default";
}
