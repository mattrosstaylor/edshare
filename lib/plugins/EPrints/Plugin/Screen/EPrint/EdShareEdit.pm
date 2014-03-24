package EPrints::Plugin::Screen::EPrint::EdShareEdit;

@ISA = ( 'EPrints::Plugin::Screen::EPrint::Edit' );

use strict;

sub new
{
	my( $class, %params ) = @_;
	
	my $self = $class->SUPER::new(%params);

	$self->{actions} = [qw/ deposit stop /];

	$self->{processor}->{skip_buffer} = $self->{session}->config( "skip_buffer" ) || 0;	

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

sub render_blister 
{
	my ( $self ) = @_;
	return $self->{repository}->xml->create_document_fragment;
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
		push @{$buttons{_order}}, "deposit";
		$buttons{deposit} = $session->phrase( "lib/submissionform:action_deposit" );
	}
	else
	{
		# mrt - this might need to be changed to give admin functionality
		push @{$buttons{_order}}, "deposit";
		$buttons{deposit} = $session->phrase( "lib/submissionform:action_deposit" );
	}

 
	push @{$buttons{_order}}, "stop";
	$buttons{stop} = $session->phrase( "lib/submissionform:action_stop" );

# mrt - NEXT TIIIIIME
#	push @{$buttons{_order}}, "next";
#	$buttons{next} = $session->phrase( "lib/submissionform:action_next" );

	return $session->render_action_buttons( %buttons );
}


# mrt - at the moment this will just return true
sub allow_deposit
{
	return 1;

}

sub action_deposit
{
	my( $self ) = @_;

	# save eprint data - QUIETLY
	$self->workflow->update_from_form( $self->{processor}, "shhhh, be quiet", 1 );
	$self->uncache_workflow;

	$self->{processor}->{screenid} = $self->{repository}->config("edshare_screen_after_edit") || "EPrint::View";	

	# always release the edit lock
	$self->{processor}->{eprint}->set_value( "edit_lock_until", 0 );

	my $problems = $self->{processor}->{eprint}->validate( $self->{processor}->{for_archive}, $self->workflow_id );
	if( scalar @{$problems} > 0 )
	{
		$self->{processor}->{eprint}->set_value( "validation_status", "error" );
		$self->{processor}->{eprint}->commit;
		$self->{processor}->{eprint}->move_to_inbox;
	
		my $warnings = $self->{session}->make_element( "ul" );
		foreach my $problem_xhtml ( @{$problems} )
		{
			my $li = $self->{session}->make_element( "li" );
			$li->appendChild( $problem_xhtml );
			$warnings->appendChild( $li );
		}
		$self->workflow->link_problem_xhtml( $warnings, "EPrint::Edit" );
		$self->{processor}->add_message( "warning", $warnings );
		$self->{processor}->add_message( "error", $self->html_phrase( "validation_errors" ) ); 
		return;
	}

	# passed validation checks
	$self->{processor}->{eprint}->set_value( "validation_status", "ok" );
	$self->{processor}->{eprint}->commit;


	# OK, no problems, submit it to the archive
	my $ok = 0;

	if ($self->{processor}->{eprint}->exists_and_set("view_permissions") && @{$self->{processor}->{eprint}->value("view_permissions")}[0]->{type} eq "private")
	{
		$ok = $self->{processor}->{eprint}->move_to_inbox;
	}
	else
	{
		if( $self->{processor}->{skip_buffer} )
		{
			$ok = $self->{processor}->{eprint}->move_to_archive;
		}
		else
		{
			$ok = $self->{processor}->{eprint}->move_to_buffer;
		}
	}

	if( $ok )
	{
		$self->{processor}->add_message( "message", $self->html_phrase( "item_deposited" ) );
		if( !$self->{processor}->{skip_buffer} ) 
		{
			$self->{processor}->add_message( "warning", $self->html_phrase( "in_buffer" ) );
		}
	}
	else
	{
		$self->{processor}->add_message( "error", $self->html_phrase( "item_not_deposited" ) );
	}
}

sub action_stop
{
	my( $self ) = @_;

	# reload to discard changes
	$self->{processor}->{eprint} = new EPrints::DataObj::EPrint( $self->{session}, $self->{processor}->{eprintid} );
	$self->{processor}->{eprint}->set_value( "edit_lock_until", 0 );
	$self->{processor}->{eprint}->commit;

	$self->{processor}->{screenid} = "ResourceManager";
}
