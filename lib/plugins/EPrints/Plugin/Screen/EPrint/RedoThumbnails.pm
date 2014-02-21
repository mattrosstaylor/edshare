package EPrints::Plugin::Screen::EPrint::RedoThumbnails;

@ISA = ( 'EPrints::Plugin::Screen::EPrint' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	# submit is a null action
	$self->{actions} = [qw/ redo_thumbnails cancel /];
	$self->{appears} = [
	{ place => "edshare_toolbox", position => 700, },
	];

	return $self;
}

sub can_be_viewed
{
        my( $self ) = @_;

	my $eprint = $self->{processor}->{eprint};
	if( $eprint->get_value( "eprint_status" ) eq "inbox" )
	{
		return 0;
	}

        return $self->allow( "redo_thumbnails" );
}

sub allow_cancel
{
        my( $self ) = @_;

	return $self->can_be_viewed;
}

sub action_cancel
{
	my( $self ) = @_;
	$self->{processor}->{redirect} = $self->{session}->get_repository->get_conf( "base_url" )."/".$self->{processor}->{eprintid};
}

sub allow_redo_thumbnails
{
        my( $self ) = @_;

	return $self->can_be_viewed;
}

sub action_redo_thumbnails
{
	my( $self ) = @_;

	my $session = $self->{session};
	my $eprint = $self->{processor}->{eprint};

	foreach my $doc ($eprint->get_all_documents)
	{
		$doc->remove_thumbnails;
		$doc->make_thumbnails;
	}

	$self->{processor}->{redirect} = $self->{session}->get_repository->get_conf( "base_url" )."/".$self->{processor}->{eprintid};
}


sub render
{
	my( $self ) = @_;

	my $div = $self->{session}->make_element( "div", class=>"ep_block" );

	$div->appendChild( $self->html_phrase("confirm"));

	my %buttons = (
		cancel => $self->{session}->phrase(
				"lib/submissionform:action_cancel" ),
		redo_thumbnails => $self->{session}->phrase(
				"lib/submissionform:action_redo_thumbnails" ),
		_order => [ "redo_thumbnails", "cancel" ]
	);

	my $form= $self->render_form;
	$form->appendChild( 
		$self->{session}->render_action_buttons( 
			%buttons ) );
	$div->appendChild( $form );

	return( $div );

}


1;
