package EPrints::Plugin::Screen::EPrint::EdShareEdit;

@ISA = ( 'EPrints::Plugin::Screen::EPrint::Edit' );

use strict;

sub new
{
	my( $class, %params ) = @_;
	
	my $self = $class->SUPER::new(%params);

	$self->{actions} = [qw/ save stop /];

	return $self;
}

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

sub render_buttons
{
	my( $self ) = @_;

	my $session = $self->{session};

	my %buttons = ( _order=>[], _class=>"ep_form_button_bar" );

# mrt - nice coding guys!
#	if( defined $self->workflow->get_prev_stage_id )
#	{
#		push @{$buttons{_order}}, "prev";
#		$buttons{prev} = $session->phrase( "lib/submissionform:action_prev" );
#	}

	my $eprint = $self->{processor}->{eprint};
	if( $eprint->value( "eprint_status" ) eq "inbox" )
	{
		push @{$buttons{_order}}, "save";
		$buttons{save} = $session->phrase( "lib/submissionform:action_save" );
	}
	else
	{
		push @{$buttons{_order}}, "save";
		$buttons{save} = $session->phrase( "lib/submissionform:action_staff_save" );
	}

 
	push @{$buttons{_order}}, "stop";
	$buttons{stop} = $session->phrase( "lib/submissionform:action_stop" );

# mrt - NEXT TIIIIIME
#	push @{$buttons{_order}}, "next";
#	$buttons{next} = $session->phrase( "lib/submissionform:action_next" );

	return $session->render_action_buttons( %buttons );
}

