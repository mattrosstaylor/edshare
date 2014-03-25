package EPrints::Plugin::EdShareToolbox;

@ISA = ( 'EPrints::Plugin' );

use strict;

sub render
{
	my( $self, %opts ) = @_;

	my $session = $self->{session};

	my $eprint;
	if( defined $opts{eprint} )
	{
		$eprint = $opts{eprint};
	}
	else
	{
		$eprint = $self->{processor}->{eprint};
	}

	return $session->make_doc_fragment unless( defined $eprint );

	$self->{eprint} = $eprint;
	$self->{processor}->{eprintid} = $eprint->get_id;

	my $frag = $session->make_doc_fragment;
	$frag->appendChild( $self->render_actions );
	return $frag;
}

sub render_actions
{
	my( $self, $hidden ) = @_;

	my $session = $self->{session};
	my $chunk = $session->make_doc_fragment;

	return $chunk unless( defined $self->{eprint} );

	push @{$hidden}, "eprintid";
	$chunk->appendChild( $self->render_action_link_list("edshare_toolbox", $hidden) );
	
	if ( not $self->{eprint}->value( "eprint_status" ) eq "inbox" )
	{
		$chunk->appendChild( _render_addthis_button( $session ) );
	}
	return $chunk;
}

sub _render_addthis_button
{
	my ( $session ) = @_;

	my $addthis = $session->make_element( "div", "style" => "text-align: left;margin:5px 0px;" );

	my $a = $session->make_element( "a",
		"href" => "http://www.addthis.com/bookmark.php",
		"onmouseover" => "return addthis_open(this, '', '[URL]', '[TITLE]')",
		"onmouseout" => "addthis_close()",
		"onclick" => "return addthis_sendto()"
	);

	my $img = $session->make_element( "img",
		src => "http://s9.addthis.com/button1-bm.gif",
		width => "125",
		height => "16",
		border => "0",
		alt => "Bookmark and Share" 
	);

	$a->appendChild( $img );
	$addthis->appendChild( $a );

	my $script = $session->make_element( "script", type => "text/javascript" );

	# should have an edshare account!
	$script->appendChild( $session->make_text( "addthis_pub = 'sebastfr';addthis_options='digg,delicious,facebook';" ) );
	$addthis->appendChild( $script );

	$script = $session->make_element( "script",
		type => "text/javascript",
		src => "http://s7.addthis.com/js/152/addthis_widget.js"
	);

	$addthis->appendChild( $script );
	return $addthis;
}

sub render_action_link
{
	my( $self, $params, $asicon ) = @_;

	my $session = $self->{session};

	my $parameters = "?";

	$parameters .="screen=".substr( $params->{screen_id}, 8 );

	foreach my $id ( @{$params->{hidden}} )
	{
		$parameters .= "&".$id."=".$self->{processor}->{$id};
	}
	my( $action, $img_action, $title );
	if( defined $params->{action} )
	{
		$action = $params->{action};
		$img_action = "_".$action;
		$title = $params->{screen}->phrase( "action:$action:title" );
	}
	else
	{
		$action = "null";
		$img_action = "";
		$title = $params->{screen}->phrase( "title" );
	}

	$parameters .= "&_action_".$action."=1";

	# will redirect to https
	my $url_base = $session->config( "http_cgiroot" )."/users/home";
	my $img_screen_name = $params->{screen_id};
	$img_screen_name =~ s/Screen\:\://;
	$img_screen_name =~ s/\:\:/_/g;
	my $link = $session->make_element( "a", "href"=>$url_base.$parameters );
	$link->appendChild( $session->make_element( "img", src=>"/images/edshare/toolbox/".$img_screen_name.$img_action.".png" ) );
	$link->appendChild( $session->make_text( $title ) );

	return $link;
}

sub render_action_link_list
{
	my( $self, $list_id, $hidden ) = @_;

	my $session = $self->{session};

	my $list = $session->make_element( 'ul' );

	foreach my $params ( $self->action_list( $list_id ) )
	{
		my $li = $session->make_element( 'li' );
		$list->appendChild( $li );
		$li->appendChild( $self->render_action_link( { %$params, hidden => $hidden } ) );
	}

	return $list;
}

sub list_items
{
	my( $self, $list_id, %opts ) = @_;

	my $filter = $opts{filter};
	$filter = 1 if !defined $filter;
	my $processor = EPrints::ScreenProcessor->new(
		session => $self->{session},
		eprint => $self->{eprint},
		eprintid => $self->{eprint}->get_id
	);

	my $params = {};

	my @action_list = $processor->list_items( $list_id, %{$params} );
	return @action_list;
}

sub action_list
{
	my( $self, $list_id ) = @_;
	my @list = ();
	foreach my $item ( $self->list_items( $list_id ) )
	{
		next unless $self->action_allowed( $item );
		push @list, $item;
	}

	return @list;
}

sub action_allowed
{
	my( $self, $item ) = @_;
	my $who_allowed;
	if( defined $item->{action} )
	{
		$who_allowed = $item->{screen}->allow_action( $item->{action} );
	}
	else
	{
		$who_allowed = $item->{screen}->can_be_viewed;
	}

	return 0 unless( $who_allowed & $self->who_filter );
	return 1;
}

sub who_filter { return 255; }

1;
