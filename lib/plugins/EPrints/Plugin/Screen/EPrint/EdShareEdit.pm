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
		$buttons{save} = $session->phrase( "lib/submissionform:action_deposit" );
	}
	else
	{
		# mrt - this might need to be changed to give admin functionality
		push @{$buttons{_order}}, "deposit";
		$buttons{save} = $session->phrase( "lib/submissionform:action_deposit" );
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

	print STDERR "\niamdepositing\n";
	# save eprint data
	my $from_ok = $self->workflow->update_from_form( $self->{processor} );
	$self->uncache_workflow;

	print STDERR "\nfrom_ok=$from_ok\n";
	
	$self->{processor}->{screenid} = "EPrint::View";	

	if (not $from_ok)
	{
		if(exists $self->{processor}->{eprint}->{viewperms})
		{
			$self->{processor}->{eprint}->value("viewperms", "private");
			$self->{processor}->{eprint}->commit;
		}
		$self->{processor}->{eprint}->move_to_inbox;
		$self->{processor}->add_message( "error", $self->html_phrase( "validation_errors" ) ); 
		return;
	}

	my $problems = $self->{processor}->{eprint}->validate( $self->{processor}->{for_archive} );
	if( scalar @{$problems} > 0)
	{
		print STDERR "\niamproblems\n";
		if(exists $self->{processor}->{eprint}->{viewperms})
		{
			$self->{processor}->{eprint}->value("viewperms", "private");
			$self->{processor}->{eprint}->commit;
		}
		$self->{processor}->{eprint}->move_to_inbox;
	
		$self->{processor}->add_message( "error", $self->html_phrase( "validation_errors" ) ); 
		my $warnings = $self->{session}->make_element( "ul" );
		foreach my $problem_xhtml ( @{$problems} )
		{
			my $li = $self->{session}->make_element( "li" );
			$li->appendChild( $problem_xhtml );
			$warnings->appendChild( $li );
		}
		$self->workflow->link_problem_xhtml( $warnings, "EPrint::Edit" );
		$self->{processor}->add_message( "warning", $warnings );
		return;
	}

	$self->{processor}->{eprint}->set_value( "edit_lock_until", 0 );
	$self->{processor}->{eprint}->commit;


	# OK, no problems, submit it to the archive

	$self->{processor}->{eprint}->set_value( "edit_lock_until", 0 );
	my $ok = 0;

	if ($self->{processor}->{eprint}->exists_and_set("viewperms") && $self->{processor}->{eprint}->value("viewperms") eq "private")
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



