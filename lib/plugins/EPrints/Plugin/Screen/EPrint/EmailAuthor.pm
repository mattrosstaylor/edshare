package EPrints::Plugin::Screen::EPrint::EmailAuthor;

@ISA = ( 'EPrints::Plugin::Screen::EPrint' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	# submit is a null action
	$self->{actions} = [qw/ email /];

	return $self;
}

sub can_be_viewed
{
	my( $self ) = @_;

	my $eprint = $self->{processor}->{eprint};
	if( $eprint->value( "eprint_status" ) eq "inbox" )
	{
		return 0;
	}

	if ( $self->{session}->current_user->get_id == $eprint->value( "userid") )
	{
		return 0;
	}

	return 1;
}

sub allow_email
{
	my( $self ) = @_;
	return $self->can_be_viewed;
}

sub action_email
{
	my( $self ) = @_;

	my $session = $self->{session};
	my $eprint = $self->{processor}->{eprint};

	my $owner = $eprint->get_user;
	my $owner_email = $owner->get_value("email");
	my $requester = $session->current_user;
	my $requester_email = $requester->get_value("email");

	my $reason = $session->make_text($session->param( "reason" ));
	my $title = $session->make_doc_fragment();
	$title->appendChild( $eprint->render_value("title") );
	$title->appendChild( $session->make_text(" (".$eprint->get_url().")") );
##grab the url of the page


##Check for a logged in user and attach that to the email?

	# Send request email
	my $subject = $session->param( "subject"   ); #include page url?
	my $mail = $session->make_element( "mail" );
	$mail->appendChild( $self->html_phrase(
		"body",
		title => $title, 
		requester => $requester->render_value("name"),
		reason =>$reason ));

	my $result = EPrints::Email::send_mail(
		session => $session,
		langid => $session->get_langid,
		to_name => "",
		to_email => $owner_email,
		subject => $subject,
		message => $mail,
	#	sig => $session->html_phrase( "mail_sig" ),
		replyto_email => $requester_email,
	);

	my $base_url = $session->get_repository->get_conf("base_url");

	if( $result )
	{
		$self->{processor}->add_message( "message", $self->html_phrase( "sent" ) );	
	}
	else	
	{
		$self->{processor}->add_message( "error", $self->html_phrase( "not_sent" ) );	
	}
	$self->{processor}->{screenid} = "EPrint::View";
}


sub render
{
	my( $self ) = @_;

	my $session = $self->{session};
	
	my $frag = $session->make_doc_fragment();
		
	my $page = $session->make_element("div", class=>"ep_top_controlbox");
	$frag->appendChild($page);
	return $page if $self->{processor}->{request_sent};

	my $p = $session->make_element('p');
	$p->appendChild($self->html_phrase("intro"));
	$page->appendChild($p);

	my $to = $session->make_element("p");
	$page->appendChild($to);
	$to->appendChild($session->make_text("To: "));
	
	$to->appendChild($self->{processor}->{eprint}->get_user()->render_value("name"));

	my $form = $session->make_element("form", "action"=>$session->get_repository()->get_conf("userhome"));
	$form->appendChild($self->html_phrase("subject"));
	$form->appendChild($session->make_element("br"));
	$form->appendChild($session->make_element("input", type=>"text", name=>"subject", size=>"60", class=>"ep_email_subject"));
	$form->appendChild($session->make_element("br"));
	$form->appendChild($session->make_element("br"));
	$form->appendChild($self->html_phrase("body_text"));
	$form->appendChild($session->make_element("br"));
	$form->appendChild($session->make_element("textarea", name=>"reason", cols=>100, rows=>10, class=>"ep_email_body"));
	$form->appendChild($session->make_element("br"));
	$form->appendChild($session->make_element("br"));
	$form->appendChild( $session->make_element("input", type=>"submit", name=>"_action_email", value=>$self->phrase( "button" )) );

	$page->appendChild( $form );

	$form->appendChild( $session->render_hidden_field( "eprintid", $self->{processor}->{eprint}->get_id ) );
	$form->appendChild( $session->render_hidden_field( "screen", $self->{processor}->{screenid} ) );

	return $frag;
}


1;
