package EPrints::Plugin::Screen::ResourceManager;

@ISA = ( 'EPrints::Plugin::Screen' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

        $self->{appears} = [
                {
                        place => "key_tools",
                        position => 101,
                }
        ];

	return $self;
}

sub can_be_viewed
{
        my( $self ) = @_;

        return $self->allow( "items" ) 
}

sub render
{
	my( $self ) = @_;
	my $session = $self->{session};

	my $frag = $session->make_doc_fragment;

	$frag->appendChild( $self->render_action_list_bar( "item_tools" ) );
	
	my $container = $session->make_element ( "div", id=>"resource_manager_container" );
	my $controls = $session->make_element ( "div" , id=>"resource_manager_left" );
	my $list = $session->make_element( 'div', id=>"resource_manager_right" );
	$container->appendChild( $controls );
	$container->appendChild( $list );
	$frag->appendChild( $container );
	
	#$controls->appendChild( $self->_render_controls() );

	my $items = $self->_generate_item_list;
	$list->appendChild( $self->_render_item_list( $items ) );

	$container->appendChild( $session->make_element( "div", class=>"clearer" ) );

	return $frag;
}


sub _render_controls
{
	my( $self ) = @_;
	
}

sub _render_item_list
{
	my( $self, $eprint_list ) = @_;
	my $session = $self->{session};

	my $item_list = $session->make_doc_fragment;

	if( !$eprint_list->count )
	{
		$item_list->appendChild( $session->html_phrase( 'Plugin/Screen/ResourceManager:no_resources' ) );
	}
	else
	{
		my %info;
		$info{dom} = $item_list;

		$eprint_list->map( sub{
			my( $session, $dataset, $eprint, $info ) = @_;

			my $owned = ($session->current_user->id == $eprint->value("userid"));
			my $url;
			if( $eprint->get_value( 'eprint_status' ) eq 'archive' )
			{
				$url = $eprint->get_url;
			}
			else
			{
				$url = $session->get_repository->get_conf( 'rel_path' ).'/cgi/users/home?screen=EPrint::Summary&eprintid='.$eprint->get_id;
			}
			my $container;
			if ( $owned )
			{
				$container = $session->make_element( "div", id => "manageable_id_".$eprint->get_id, class => "manageable" );
			}
			else
			{

				$container = $session->make_element( "div", id => "manageable_id_".$eprint->get_id, class => "manageable manageable_shared" );
			}			

			my $flags = {
					can_remove=> $owned,
					can_edit=> $eprint->could_obtain_lock( $session->current_user ),
			};
			$container->appendChild( $eprint->render_citation( 'manageable', url => $url, flags=>$flags ) );
			$info->{dom}->appendChild( $container );
		}, \%info );
	}

	return $item_list;
}

sub _generate_item_list
{
	my( $self ) = @_;
	my $session = $self->{session};

	my $user = $session->current_user;
        my $ds = $session->get_dataset( 'eprint' );

        my $search = EPrints::Search->new(
                dataset => $ds,
                session => $session,
        );

        $search->add_field( $ds->get_field("userid"), $user->id);

	my $all_items = $search->perform_search;


	my @permission_types = qw/ Creators UserLookup/; 
	foreach my $type (@permission_types)
	{
		my $plugin = $session->plugin( "PermissionType::".$type, fieldname=>"edit_permissions" );
		next if (not defined $plugin);
		my $items = $plugin->get_permitted_items_for_user( $user );
		$all_items = $all_items->union( $items );	
	}

	return $all_items->reorder( "-lastmod" );
}

=pod
sub render
{
	my( $self ) = @_;
	my $session = $self->{session};

	my $frag = $session->make_doc_fragment;
	$frag->appendChild( $self->render_action_list_bar( 'item_tools' ) );
	
	my $id_prefix = "ed_resourcemanager";
	my $main = $session->make_element( 'div', id=>$id_prefix);
	$frag->appendChild( $main );

	my $filter = $session->plugin( "ResourceManagerFilter" );

	my( $table, $tr, $td );
	$table = $session->make_element( "table", width=>"100%" );
	$main->appendChild( $table );
	$tr = $session->make_element( "tr" );
	$table->appendChild( $tr );
	$td = $session->make_element( "td", valign=>"top" );
	$tr->appendChild( $td );

	my $filter_box = $session->make_element( "div", class => "ed_resourcemanager_filter_box" );
	$td->appendChild( $filter_box );
	my $filter_title = $session->make_element( "div", class=>"ed_resourcemanager_filter_box_title" );
	$filter_title->appendChild( $session->make_text( "Filters" ) );
	$filter_box->appendChild( $filter_title );
	$filter_box->appendChild( $session->make_element("div", id=>"ed_resourcemanager_filter_box_content"));

#	$filter_box->appendChild( $filter->render_filter_control( $eprint_list ) );

	my( $bulk_action_form_frag, $bulk_action_form ) = $self->_render_bulk_action_form();
	
	$td = $session->make_element( "td", valign=>"top", align=>"left", style=>"width:100%;" );
	$tr->appendChild( $td );

	$td->appendChild( $bulk_action_form_frag );
	$bulk_action_form->appendChild($session->make_element( 'div', id => 'manageable_list', class => 'ep_manageable_list' ));

	my $filter_fields = $filter->get_filter_fields;
	my %current_filter_values;
	map {
		my $filter_field = $_;
		my $metafield = $session->get_repository->get_dataset( 'eprint' )->get_field( $filter_field );
		$current_filter_values{$filter_field} = $filter->get_current_filter_values( $filter_field ); 
	} @{$filter_fields};
	my $loader_image_url = $session->get_repository->get_conf( 'rel_path' ).'/images/resource_manager/ajax-loader.gif';
	my $cgi_url = $session->get_repository->get_conf( 'rel_path' ).'/cgi/users/resource_manager';

	my $filterbox_id = 'ed_resourcemanager_filter_box_content';
	my $manageable_list_id = 'manageable_list';
	my %params = ( 't' => time );
	map {
		$params{$_} = EPrints::Utils::url_escape( join( ",", @{$current_filter_values{$_}} ) );
	} keys %current_filter_values;
	my $params_json = join( ", ", map {
		"'$_': '".$params{$_}."'";
	} keys %params );

	$frag->appendChild( $session->make_javascript("
document.observe('dom:loaded', function() {
	\$('$manageable_list_id').update('<img src=\\'$loader_image_url\\'/>');
	new Ajax.Request('$cgi_url', {
		method: 'post',
		parameters: { $params_json },
		onSuccess: function(response) {
			\$('$filterbox_id').update(response.responseJSON[0]);
			\$('$manageable_list_id').update(response.responseJSON[1]);
		}
	});
} );
	") );

	return $frag;
}
=cut

sub _render_bulk_action_form
{
	my( $self ) = @_;

	my $session = $self->{session};

	my $frag = $session->make_doc_fragment;

	my $bulk_action_form = $session->make_element( 'form', method => 'get', action => $session->config( "rel_path" )."/cgi/users/home", class => 'ep_bulkaction_form' );
	$frag->appendChild( $bulk_action_form );	

	# This below should work, but it's complaining that $self->{processor} isn't defined...
	my @bulk_action_list = $self->action_list( 'edshare_bulk_actions' );
	#my @bulk_action_list = $self->_list_items( 'edshare_bulk_actions' );

	if ( scalar @bulk_action_list )
	{
		my $bulk_action_select = $session->make_element( 'select', name => 'screen', id => 'bulk_action_select' );
		my $bulk_action_option = $session->make_element( 'option' );
		$bulk_action_option->appendChild( $self->html_phrase( 'select_bulk_action' ) );
		$bulk_action_select->appendChild( $bulk_action_option );
		foreach my $bulk_screen ( @bulk_action_list )
		{
			my $screen_id = $bulk_screen->{screen_id};
			$screen_id =~ s/Screen::(.*)/$1/;
			$bulk_action_option = $session->make_element( 'option', value => $screen_id );
			$bulk_action_option->appendChild( $bulk_screen->{screen}->render_title );
			$bulk_action_select->appendChild( $bulk_action_option );
		}
# mrt - BULK ACTIONS CURRENTLY DISABLED
=pod
		$bulk_action_form->appendChild( $self->html_phrase( 'with_selected_resources' ) );
		$bulk_action_form->appendChild( $bulk_action_select );
		$bulk_action_form->appendChild( $session->make_javascript(<<INIT_CONTROL
document.observe('dom:loaded', function() {
	\$('bulk_action_select').observe('change',
		window.executeBulkAction.bindAsEventListener({}, 'testtest'));
});
INIT_CONTROL
		) );
=cut
	}


	return( $frag, $bulk_action_form );
}

sub phrase
{
	my( $self, $id, %bits ) = @_;

	my $base = 'Plugin/Screen/ResourceManager';

	return $self->{session}->phrase( $base.':'.$id, %bits );
}

sub html_phrase
{
	my( $self, $id, %bits ) = @_;

	my $base = 'Plugin/Screen/ResourceManager';

	return $self->{session}->html_phrase( $base.':'.$id, %bits );
}
1;
