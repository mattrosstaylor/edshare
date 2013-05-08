#$c->{edshare_core_session_init} = $c->{session_init};
#
#$c->{session_init} = sub
#{
#        my( $repository, $offline ) = @_;
#	
#	$repository->{workflows}->{eprint}->{default} = $repository->{workflows}->{eprint}->{edshare};
#	
#	$repository->call("edshare_core_session_init", $repository, $offline);	
#};
$c->{edshare_core_set_eprint_automatic_fields} = $c->{set_eprint_automatic_fields}; 

$c->{set_eprint_automatic_fields} = sub
{
	my ($eprint) = @_;
	my $repo = $eprint->{session};

	$repo->call('edshare_core_set_eprint_automatic_fields', $eprint);

	# normalise the keywords (if any) for the browse views
	my $k = $eprint->get_value( "raw_keywords" ); 
	unless( EPrints::Utils::is_set( $k ) )
	{ 
		$eprint->set_value( "keywords", undef ); 
	} 
	else
	{
		my @nk;
		foreach(@$k)
		{
			push @nk, EPrints::Plugin::EdShareCoreUtils::normalise_keyword( $_ );
		}
		$eprint->set_value( "keywords", \@nk );
	}
};

# mrt - removing this for a second
#$c->{set_document_automatic_fields} = sub
#{
#	my( $doc ) = @_;
#
#        if( $doc->is_link() )
#        {
#                if( $doc->generate_link_frames() )
#                {
#                        my $use_local = $doc->get_value( "use_local_copy" );
#                        if( defined $use_local )
#                        {
#                                if( $use_local eq 'TRUE' )
#                                {
#                                        $doc->set_value( "main", "_edshare_main_local.html" );
#                                }
#                                else
#                                {
#                                        $doc->set_value( "main", "_edshare_main.html" );
#                                }
#                        }
#                }
#        }
#
#};

$c->{fields}->{document} = [
# EdShare - This field adds a description to a document which outlines what it is intended to be used for.
	{
		'name' => 'description',
		'type' => 'text',
		'input_cols' => '45',
#		'render_value' => 'EPrints::Extras::render_document_description'
	},
# EdShare - "Share a link" features
          {
            'name' => 'use_local_copy',
            'type' => 'boolean',
          },
          {
            'name' => 'source_url',
            'type' => 'text',
            'input_cols' => '45',
          }


];


=pod

$c->{validate_document} = sub
{
	my( $document, $session, $for_archive ) = @_;

	my @problems = ();

	# CHECKS IN HERE

	# security can't be "public" if date embargo set
	if( $document->get_value( "security" ) eq "public" &&
		EPrints::Utils::is_set( $document->get_value( "date_embargo" ) ) )
	{
		my $fieldname = $session->make_element( "span", class=>"ep_problem_field:documents" );
		push @problems, $session->html_phrase( 
					"validate:embargo_check_security" ,
					fieldname=>$fieldname );
	}

	# embargo expiry date must be in the future
	if( EPrints::Utils::is_set( $document->get_value( "date_embargo" ) ) )
	{
		my $value = $document->get_value( "date_embargo" );
		my ($thisyear, $thismonth, $thisday) = EPrints::Time::get_date_array();
		my ($year, $month, $day) = split( '-', $value );
		if( $year < $thisyear || ( $year == $thisyear && $month < $thismonth ) ||
			( $year == $thisyear && $month == $thismonth && $day <= $thisday ) )
		{
			my $fieldname = $session->make_element( "span", class=>"ep_problem_field:documents" );
			push @problems,
				$session->html_phrase( "validate:embargo_invalid_date",
				fieldname=>$fieldname );
		}
	}


	return( @problems );
};

=cut

$c->{set_eprint_defaults} = sub
{
	my( $data, $session ) = @_;
# EdShare - Makes the default eprint type a "resource"
	if(!EPrints::Utils::is_set( $data->{type} ))
	{
		$data->{type} = "resource";	
	}

# add the depositor as first creator:

	my $user = $session->current_user;
        if(defined $user)
	{
                my %creator;
                $creator{name} = $user->get_value("name");
                $creator{id} = $user->get_value("email");
                my @creators;
                $creators[0] = \%creator;
                $data->{creators} = \@creators;
        }


#mrt - need to change viewperms to be less stupid
        if(!defined $data->{viewperms})
        {
                $data->{viewperms} = "uni_public";
        }

};


$c->{fields}->{eprint} = [

          {
            'name' => 'creators',
            'type' => 'compound',
            'multiple' => 1,
            'fields' => [
                          {
                            'sub_name' => 'name',
                            'type' => 'name',
                            'hide_honourific' => 1,
                            'hide_lineage' => 1,
# EdShare - Render order changed so given name is rendered before family name to make the respository more personal
                            'family_first' => 0,
			    'render_order' => 'gf',
                          },
                          {
                            'sub_name' => 'id',
                            'type' => 'text',
                            'input_cols' => 20,
                            'allow_null' => 1,
                          }
                        ],
            'input_boxes' => 1,
	    'input_ordered' => 0,
	    'render_value' => 'EPrints::Plugin::EdShareCoreUtils::render_creators_name'
          },
          

          {
            'name' => 'title',
            'type' => 'longtext',
# EdShare - Input rows reduced to encourage sensible length titles
            'input_rows' => 1,
	    'make_value_orderkey' => sub 
				{
					my( $field, $value ) = @_;
					return $value unless( $value =~ /^Lecture/ );
					$value =~ s/(\d+)/sprintf("%08d",$1)/ge;
					return $value;
				}
          },

# mrt - removing divisions from edshare core	
#          {
#            'name' => 'divisions',
#            'type' => 'subject',
#            'multiple' => 1,
#            'top' => 'divisions',
#            'browse_link' => 'divisions',
#	    'input_rows' => 4,
#          },

# mrt - removing full_text_status - this is unused in edshare
#          {
#            'name' => 'full_text_status',
#            'type' => 'set',
#            'options' => [
#                           'public',
#                           'restricted',
#                           'none',
#                         ],
#            'input_style' => 'medium',
#          },

# Edshare - Keywords changed to be a multiple field so that browse views can be made.
          {
            'name' => 'keywords',
            'type' => 'text',
	    'multiple' => 1,
	    'text_index' => 1,
	    'render_single_value' => 'EPrints::Plugin::EdShareCoreUtils::render_single_keyword',
#	    'input_advice_below' => sub { return shift->html_phrase( "Field/TagLite:keywords:advice_below" ); },
          },


# mrt - ain't no courses in basic edshare boyo - yup YUUUP!
#          {
#            'name' => 'courses',
#            'type' => 'text',
#	    'multiple' => 1,
#	    'text_index' => 1,
#	    'render_single_value' => 'EPrints::Plugins::EdShareCoreUtils::render_single_keyword'
#          },

          {
            'name' => 'abstract',
            'type' => 'longtext',
# EdShare - Input rows reduced to make the workflow a bit less menacing.
            'input_rows' => 3,
          },

# EdShare - Added field so users can advise on how they can reuse this resource. 
        {
          'name' => 'advice',
          'type' => 'longtext',
          'input_rows' => 3,
        },

# EdShare - Viewing Permissions ("Sharing with")
          {
            'name' => 'viewperms',
            'type' => 'set',
            'options' => [
                           'private',
                           'registered_only',
                           'public',
                         ],
            'input_style' => 'radio',
            'allow_null' => 0,
          },

	 # The following are core fields which arent used in EdShare Core but EPrints wont let us remove
          {
            'name' => 'date',
            'type' => 'date',
            'min_resolution' => 'year',
          },



# mrt - no-one publishes ANYTHING in EdShare
#          {
#            'name' => 'publisher',
#            'type' => 'text',
#          },


# mrt - subjects are overrated anyway - who needs them?
#          {
#            'name' => 'subjects',
#            'type' => 'subject',
#            'multiple' => 1,
#            'top' => 'subjects',
#            'browse_link' => 'subjects',
#          },



# mrt - anaother useless field
#          {
#            'name' => 'ispublished',
#            'type' => 'set',
#            'options' => [
#                           'pub',
#                           'inpress',
#                           'submitted',
#                           'unpub',
#                         ],
#            'input_style' => 'medium',
#          },

        {
            'name' => 'raw_keywords',
            'type' => 'text',
            'multiple' => 1,
            'text_index' => 1,
        },

];


$c->{browse_views} = [
        {
                id => "year",
                menus => [
                        {
                                fields => [ "datestamp;res=year" ],
                                reverse_order => 1,
                                allow_null => 1,
                                new_column_at => [10,10],
                        }
                ],
                order => "creators_name/title",
                variations => [
                        "creators_name;first_letter",
                        "type",
                        "DEFAULT" ],
        },
        {
                id => "creators",
                allow_null => 0,
                hideempty => 1,
                menus => [
                        {
#EdShare - order=fg added so that the browse view still orders family name first even though the names are rendered given first.
                                fields => [ "creators_name;order=fg" ],
                                new_column_at => [1, 1],
                                mode => "sections",
                                open_first_section => 1,
                                group_range_function => "EPrints::Update::Views::cluster_ranges_30",
                                grouping_function => "EPrints::Update::Views::group_by_a_to_z",
                        },
                ],
                order => "-datestamp/title",
                variations => [
                        "type",
                        "DEFAULT",
                ],
        },


        {
                id => "keywords",
                allow_null => 0,
                hideempty => 1,
                menus => [
                        {
                                fields => [ "keywords" ],
                                new_column_at => [1, 1],
                                mode => "sections",
                                open_first_section => 1,
                                group_range_function => "EPrints::Update::Views::cluster_ranges_30",
                                grouping_function => "EPrints::Update::Views::group_by_a_to_z",
                        },
                ],
                order => "-datestamp/title",
                citation => "result",
        },
];


=pod

mrt - I have wanted to kill this function my entire time working on EdShare - it is megashit

$c->{eprint_render} = sub
{
	my( $eprint, $session, $preview ) = @_;

	my( $page, $p, $a );

	$page = $session->make_doc_fragment;

	# Put in a message describing how this document has other versions
	# in the repository if appropriate

	# Contact email address
	my $has_contact_email = 0;
	if( $session->get_repository->can_call( "email_for_doc_request" ) )
	{
		if( defined( $session->get_repository->call( "email_for_doc_request", $session, $eprint ) ) )
		{
			$has_contact_email = 1;
		}
	}


	my $rightbar = $session->make_element("div", class=>"ed_abs_rightbar");
	# Then the abstract
	if( $eprint->is_set( "abstract" ) )
	{
		my $div = $session->make_element( "div", class=>"ep_block" );
		$rightbar->appendChild( $div );
		my $h2 = $session->make_element( "h2", class => "ep_abstractpage_header" );
		$h2->appendChild( 
			$session->html_phrase( "eprint_fieldname_abstract" ) );
		$div->appendChild( $h2 );

		$p = $session->make_element( "p", style => "text-align: justify;" );
		$p->appendChild( $eprint->render_value( "abstract" ) );
		$div->appendChild( $p );
	}
# EdShare - Adds the advice field to the abstract page if it is set.
	if( $eprint->is_set( "advice" ) )
	{
		my $div = $session->make_element( "div", class=>"ep_block" );
		$rightbar->appendChild( $div );
		my $h2 = $session->make_element( "h2", class => "ep_abstractpage_header" );
		$h2->appendChild( 
			$session->html_phrase( "eprint_fieldname_advice" ) );
		$div->appendChild( $h2 );

		$p = $session->make_element( "p", style => "text-align: justify;" );
		$p->appendChild( $eprint->render_value( "advice" ) );
		$div->appendChild( $p );
	}

	my $metadata_div = $session->make_element("div", class=>"ep_block");	
	$rightbar->appendChild( $metadata_div );
	my $metatitle = $session->make_element("h2", class => "ep_abstractpage_header");
	$metadata_div->appendChild( $metatitle );
	$metatitle->appendChild($eprint->render_value("type"));
	$metatitle->appendChild($session->make_text(" details"));
	my( $table, $tr, $td, $th );	# this table needs more class cjg
	$table = $session->make_element( "table", class=>"ep_metadata_table", cellpadding=>"3" );
	$metadata_div->appendChild( $table );

	my $toolbox = $session->plugin( "EdShareToolbox" );

	if( defined $toolbox )
	{
		my $toolbox_box = $session->make_element("div", class=>"ep_block toolbox_".$eprint->get_value("type"));
		$rightbar->appendChild($toolbox_box);

		my $toolbox_title = $session->make_element("h2", class => "ep_abstractpage_header");
		$toolbox_box->appendChild($toolbox_title);
		$toolbox_title->appendChild($session->make_text("Toolbox"));
		
		$toolbox_box->appendChild($toolbox->render( eprint => $eprint ) );
	}
	else
	{
		print STDERR "\nWoops toolbox not defined..!";
	}

	$page->appendChild($rightbar);
	# Commentary

	my $frag = $session->make_doc_fragment;
	$frag->appendChild( $eprint->render_value( "type"  ) );
	my $type = $eprint->get_value( "type" );
	my $user = new EPrints::DataObj::User( 
			$eprint->{session},
 			$eprint->get_value( "userid" ) );
	my $usersname;
	if( defined $user )
	{
		$usersname = $user->render_citation_link();
	}
	else
	{
		$usersname = $session->html_phrase( "page:invalid_user" );
	}

	$table->appendChild( $session->render_row(
		$session->html_phrase( "page:deposited_by" ),
		$usersname ) );

	if( $eprint->is_set( "datestamp" ) )
	{
		$table->appendChild( $session->render_row(
			$session->html_phrase( "page:deposited_on" ),
			$eprint->render_value( "datestamp" ) ) );
	}

	if( $eprint->is_set( "creators" ) )
	{
		$table->appendChild( $session->render_row(
			$session->html_phrase( "eprint_fieldname_creators" ),
			$eprint->render_value( "creators" ) ) );
	}

	# Additional Info

	my $eprint_ds = $session->get_dataset( "eprint" );
	
	# Keywords
	if( $eprint->is_set( "keywords" ) )
	{
		$table->appendChild( $session->render_row(
			$session->html_phrase( "eprint_fieldname_keywords" ),
			$eprint->render_value( "keywords" ) ) );
	}

	if( $eprint_ds->has_field( "courses" ) && $eprint->is_set( "courses" ) )
	{
		$table->appendChild( $session->render_row(
			$session->html_phrase( "eprint_fieldname_courses" ),
			$eprint->render_value( "courses" ) ) );
	}

	if( $eprint->is_set( "viewperms" ) )
	{
		$table->appendChild( $session->render_row(
#			$session->html_phrase( "eprint_fieldname_viewperms" ),
			$session->make_text( "Permissions" ),
			$eprint->render_value( "viewperms" ) ) );
	}

	$table->appendChild( $session->render_row(
		$session->make_text("Link"),
		$session->make_text($eprint->get_url() ) ) );


	# sf2/stats
	if ($session->plugin("Stats::RepoStats"))
	{
		$table->appendChild( $session->render_row( 
			$session->make_text( "Downloads" ),
			$session->make_javascript( "new RepoStats_SparkLine( {datasetid: 'eprint_downloads', objectid: '".$eprint->get_id."', tooltip: 'Download activity, click for more stats', link_to_dashboard: 'eprint' } );" ) ) );
	}

	my $leftbar = $session->make_element("div", style=>"float:left;width: 625px;");
	$page->appendChild( $leftbar );

	if($eprint->get_value("type") ne "collection")
	{
		if ($session->can_call("make_preview_plus"))
		{
			$leftbar->appendChild($session->get_repository()->call("make_preview_plus", $session, $eprint, "horizontal"));
		}
		else
		{
			$leftbar->appendChild($session->make_text( 'hoooooo YEAAAAH'));
		}
	}
	else
	{
	  	my @relation_list = @{ $eprint->get_relation };
		if( @relation_list )
		{
			my $items = $session->make_doc_fragment;
			my $items_header = $session->make_element( 'h2' );
			$items_header->appendChild( $session->html_phrase( 'collection_items_header' ) );
			$items->appendChild( $items_header );
			my $items_list = $session->make_element( 'ul', class=>"ep_abs_collection_render" );
			foreach my $relation ( @relation_list )
			{
				my $id = $relation->{uri};
				my $eprint = new EPrints::DataObj::EPrint( $session, $id );
				if( defined $eprint )
				{
					my $items_list_item = $session->make_element( 'li' );
					my $eprint_item = $session->make_element( 'a', href=>$eprint->get_url );
					$eprint_item->appendChild( $eprint->render_citation( 'result' ) );
					$items_list_item->appendChild( $eprint_item );
					$items_list->appendChild( $items_list_item );
				}
			}
			$items->appendChild( $items_list );
			$leftbar->appendChild( $items );
			$leftbar->appendChild( $session->make_element( "br" ) );
		}
	
	}

	# Comments and Notes
	if( !$preview and $session->plugin('Screen::EPMC::Sneep'))
	{
		my $sneep_container = $session->make_element( "div", style => "width: 625px;" );
		$leftbar->appendChild( $sneep_container );

		my $sneep_title = $session->make_element( "h2", class => "ep_abstractpage_header" );
		$sneep_container->appendChild( $sneep_title );
		$sneep_title->appendChild( $session->make_text( "Comments & Notes" ) );

		my $sneep_types = [ 'comment', 'note' ];

		my $labels = {};
		my $sneep_links = {};
		my $panels = $session->make_element( 'div', id=>'sneep_item_panels', class=>'ep_tab_panel' );
		my $current = $sneep_types->[0];

		my $rel_path = $session->get_repository->get_conf( "rel_path" );

		foreach my $sneep_type ( @$sneep_types )
		{
			$labels->{$sneep_type} = $session->html_phrase( 'Plugin/Screen/EPrint/Box/Sneep:tab_'.$sneep_type );
			$sneep_links->{$sneep_type} = '';

			my $new_panel = $session->make_element( 'div', class=>($sneep_type eq $current ? '' : 'ep_no_js' ), id=>'sneep_item_panel_'.$sneep_type );

			my $link = $session->make_element( "a", href=>$rel_path."/cgi/sneep/sneep_page?eprintid=".$eprint->get_id."&type=$sneep_type", class=>"ep_sneep_type_$sneep_type" );
			$link->appendChild( $session->html_phrase( "sneep_".$sneep_type."_link" ) );
			$new_panel->appendChild( $link );

			$panels->appendChild( $new_panel );
		}

		my $tab_block = $session->make_element( 'div', class=>'ep_only_js', style=>"width: 625px;" );
		my $tab_set = $session->render_tabs( id_prefix=>'sneep_item', current=>$current, tabs=>$sneep_types, labels=>$labels, links=>$sneep_links );
		$tab_block->appendChild( $tab_set );
		$sneep_container->appendChild( $tab_block );
		$sneep_container->appendChild( $panels );
	}


	if ($session->plugin('Collection'))
	{
		#generate parent collections
		my $contained_ids = $eprint->get_parent_collections( $session );
		my $parents = $session->make_element( "div", class=>"ep_block" );
		my $h2 = $session->make_element( "h2", class=>"ep_abstractpage_header");
		$h2->appendChild( $session->make_text( "Collection(s)" ) );
		$parents->appendChild( $h2 );

		my($parents_ul,$parents_li);
		$parents_ul = $session->make_element( "ul", style=>"padding-left:5px;list-style-image:none;list-style-type:none;" );
		$parents->appendChild( $parents_ul );

		my $collections_count = 0;
		if(defined $contained_ids && scalar @$contained_ids)
		{
			my $contained_eprint;
			foreach my $id (@$contained_ids)
			{
				$contained_eprint = EPrints::DataObj::EPrint->new($session, $id);
				if(!defined $contained_eprint)
				{
					next;
				}
				if( $contained_eprint->get_value( "eprint_status" ) ne 'archive' )
				{
					next;
				}
				if($contained_eprint->get_value("type") eq "collection")
				{
					$parents_li = $session->make_element( "li" );
					$parents_ul->appendChild( $parents_li );

					my $parent_link = $session->make_element( "a", href=>$contained_eprint->get_url );
					$parent_link->appendChild( $contained_eprint->render_value( "title" ) );
					$parents_li->appendChild( $parent_link );
					$collections_count++;
				}
			}
		}

		if( $collections_count )
		{
			$rightbar->appendChild( $parents );
		}
	}

#	my $access = $session->make_element( "p" );
#	$access->appendChild( $session->make_text( "This page has been visited " ) );
##	$access->appendChild( $session->make_javascript( "new RepoStats_Counter( {datasetid: 'eprint_views', objectid: '".$eprint->get_id."',human_display:'1' } );" ) );
#	$access->appendChild( $session->make_text( " time(s)" ) );
#	$page->appendChild( $access );

	$page->appendChild($session->make_element("div", class=>"clearer"));

	my $title = $eprint->render_description();

	my $links = $session->make_doc_fragment();
	$links->appendChild( $session->plugin( "Export::Simple" )->dataobj_to_html_header( $eprint ) );
	$links->appendChild( $session->plugin( "Export::DC" )->dataobj_to_html_header( $eprint ) );

	return( $page, $title, $links );
};
=cut

$c->{search}->{advanced} = 
{
# EdShare - Made new fields searchable and added some new order methods
	search_fields => [
		{ meta_fields => [ $EPrints::Utils::FULLTEXT ] },
		{ meta_fields => [ "title" ] },
		{ meta_fields => [ "creators_name" ] },
		{ meta_fields => [ "abstract" ] },
		{ meta_fields => [ "keywords" ] },
		{ meta_fields => [ "advice" ] },
		{ meta_fields => [ "type" ] },
		{ meta_fields => [ "documents.format" ] },
	],
	preamble_phrase => "cgi/advsearch:preamble",
	title_phrase => "cgi/advsearch:adv_search",
	citation => "result",
	page_size => 20,
	order_methods => {
		"byyear" 	 => "-datestamp/creators_name/title",
		"byyearoldest"	 => "datestamp/creators_name/title",
		"byname"  	 => "creators_name/-datestamp/title",
		"bytitle" 	 => "title/creators_name/-datestamp"
	},
	default_order => "byyear",
	show_zero_results => 1,
};


$c->{search}->{simple} = 
{
# EdShare - Removed fields which are no longer in EdShare config and added advice
	search_fields => [
		{
			id => "q",
			meta_fields => [
				$EPrints::Utils::FULLTEXT,
				"title",
				"abstract",
				"creators_name",
				"datestamp", 
				"keywords",
				"advice",
			]
		},
	],
	preamble_phrase => "cgi/search:preamble",
	title_phrase => "cgi/search:simple_search",
	citation => "result",
	page_size => 20,
	order_methods => {
		"byyear" 	 => "-datestamp/creators_name/title",
		"byyearoldest"	 => "datestamp/creators_name/title",
		"byname"  	 => "creators_name/-datestamp/title",
		"bytitle" 	 => "title/creators_name/-datestamp"
	},
	default_order => "byyear",
	show_zero_results => 1,
};
		


######################################################################
#
# Advanced Options
#
# Don't mess with these unless you really know what you are doing.
#
######################################################################

# Example page hooks to mess around with the metadata
# submission page.

# my $doc = EPrints::XML::make_document();
# my $link = $doc->createElement( "link" );
# $link->setAttribute( "rel", "copyright" );
# $link->setAttribute( "href", "http://totl.net/" );
# $c->{pagehooks}->{submission_meta}->{head} = $link;
# $c->{pagehooks}->{submission_meta}->{bodyattr}->{bgcolor} = '#ff0000';


# 404 override. This is handy if you want to catch some urls from an
# old system, or want to make some kind of weird dynamic urls work.
# It should be handled before it becomes a 404, but hey.
# If the function returns a string then the browser is redirected to
# that url. If it returns undef then then the normal error page is shown.
# $c->{catch404} = sub {
#	my( $session, $url ) = @_;
#	
#	if( $url =~ m#/subject-(\d+).html$# )
#	{
#		return "/views/subjects/$1.html";
#	}
#	
#	return undef;
# };

# If you use the Latex render function and want to use the mimetex
# package rather than the latex->dvi->ps->png route then enable this
# option and put the location of the executable "mimetex.cgi" into 
# SystemSettings.pm
$c->{use_mimetex} = 0;

# This is a list of fields which the user is asked for when registering
# If true then use cookie based authentication.
# Don't use basic login unless you are coming from EPrints 2.
$c->{cookie_auth} = 1;

# If you are setting up a very simple system or 
# are starting with lots of data entry you can
# make user submissions bypass the editorial buffer
# by setting this option:
# EdShare - Disabled buffer because it allows content to be added more easily.
$c->{skip_buffer} = 1;

# Supress the public user information page. Useful if you have
# data protection concerns.
$c->{disable_userinfo} = 0;

# If 1, users can request the removal of their submissions from the repository
$c->{allow_user_removal_request} = 1;

# domain for the login and lang. cookies to be set in.
$c->{cookie_domain} = $c->{host};

######################################################################
#
# Timeouts
#
######################################################################

# Time (in hours) to allow a email/password change "pin" to be active.
# Set a time of zero ("0") to make pins never time out.
$c->{pin_timeout} = 24*7; # a week

# Search cache.
#
#   Number of minutes of unuse to timeout a search cache
$c->{cache_timeout} = 10;

#   Maximum lifespan of a cache, in use or not. In hours.
#   ( This will be the length of time an OAI resumptionToken is 
#   valid for ).
$c->{cache_maxlife} = 12;


# Generic Plugin Options

# To disable the plugin "Export::BibTeX":
# $c->{plugins}->{"Export::BibTeX"}->{params}->{disable} = 1;

# To enable the plugin "Export::LocalThing":
# $c->{plugins}->{"Export::LocalThing"}->{params}->{disable} = 0;

# Screen Plugin Configuration
# (Disabling a screen will also remove it and it's actions from all lists)

# To add the screen Screen::Items to the key_tools list at postion 200:
# $c->{plugins}->{"Screen::Items"}->{appears}->{key_tools} = 200;

# To remove the screen Screen::Items from the key_tools list:
# $c->{plugins}->{"Screen::Items"}->{appears}->{key_tools} = undef;
#$c->{plugins}->{"Screen::EPrint::UseAsTemplate"}->{icon} = "action_edit.png";

# Screen Actions Configuration

# To disable action "blah" of Screen::Items 
# (Disabling an action will also remove it from all lists)
# $c->{plugins}->{"Screen::Items"}->{actions}->{blah}->{disable} = 1;

# To add action "blah" of Screen::Items to the key_tools list at postion 200: 
# $c->{plugins}->{"Screen::Items"}->{actions}->{blah}->{appears}->{key_tools} = 200;

# To remove action "blah" of Screen::Items from the key_tools list
# $c->{plugins}->{"Screen::Items"}->{actions}->{blah}->{appears}->{key_tools} = undef;


# Import/export plugins

# to make a plugin only available to staff
# $c->{plugins}->{"Export::Text"}->{params}->{visible} = "staff";

# to only command line tools
# $c->{plugins}->{"Export::Text"}->{params}->{visible} = "api";

# to prevent a import/export plugin from being shown as an option, but
# not actually disable it.
# $c->{plugins}->{"Export::BibTeX"}->{params}->{advertise} = 0;


# Plugin Mapping

# The following would make the repository use the LocalDC export plugin
# anytime anything asks for the DC plugin - this is a handy way to override
# the behaviour without hacking the existing plugin. 
# $c->{plugin_alias_map}->{"Export::DC"} = "Export::LocalDC";
# This line just means that the LocalDC plugin doesn't appear in addition
# as that would be confusing. 
# $c->{plugin_alias_map}->{"Export::LocalDC"} = undef;
       
#$c->{plugin_alias_map}->{"Screen::View::Owner"} = undef;
# CrossRef registration

# You should replace this with your own CrossRef account username and password.

$c->{plugins}->{"Import::DOI"}->{params}->{pid} = "ourl_eprintsorg:eprintsorg";

$c->{plugins}->{"Issues"}->{params}->{disable} = 1;
$c->{plugins}->{"Issues::ExactTitleDups"}->{params}->{disable} = 1;
$c->{plugins}->{"Issues::SimilarTitles"}->{params}->{disable} = 1;
$c->{plugins}->{"Issues::XMLConfig"}->{params}->{disable} = 1;

# EdShare - Plugin config
# EdShare - Disable the Review screen.
$c->{plugins}->{"Screen::Review"}->{params}->{disable} = 1;
# EdShare mask the View plugin with a custom plugin that redirects users to their item page.
$c->{plugin_alias_map}->{"Screen::EPrint::View::Owner"} = "Screen::RedirectToItems";
$c->{plugin_alias_map}->{"Screen::EPrint::View::Editor"} = "Screen::RedirectToItems";
# EdShare - Adds use as template to the manage deposits screen.

# mrt - this plugin doesn't even exist yet
#$c->{plugins}->{"Screen::EPrint::UseAsTemplate"}->{actions}->{use_as_template}->{appears}->{eprint_item_actions} = 20;

# Assemble EdShare Toolbox
$c->{plugins}->{"Screen::EPrint::Edit"}->{appears}->{edshare_toolbox} = 10;

$c->{can_request_view_document} = sub
{
	return "ALLOW";
};

# Return "ALLOW" if the given user can view the given document,
# otherwise return "DENY".
$c->{can_user_view_document} = sub
{
	my( $doc, $user ) = @_;

	my $eprint = $doc->get_eprint();

	# TODO
	# probably something like:
	return "ALLOW" if( $eprint->can_be_viewed( $user ) );
	return "DENY";

};

$c->{"edshare_choose_workflow"} = sub {
	my ( $eprint ) = @_;

	my $type = $eprint->value("type"); 

	if($type eq "collection")
	{
		return "collection";
	}
	
	if($type eq "resource")
	{
		return "edshare";
	}
	
	return "default";
	
};

$c->{edshare_screen_after_edit} = "Items";

$c->{plugin_alias_map}->{"Screen::EPrint::Edit"} = "Screen::EPrint::EdShareEdit";
$c->{plugin_alias_map}->{"Screen::EPrint::CollectionEdit"} = "Screen::EPrint::EdShareEdit";
$c->{plugin_alias_map}->{"Screen::EPrint::EdShareEdit"} = undef;
$c->{plugins}->{"Screen::EPrint::EdShareEdit"}->{params}->{disable} = 0;

# Custom summary screen
#$c->{plugin_alias_map}->{"Screen::EPrint::Summary"} = "Screen::EPrint::LocalSummary";
#$c->{plugin_alias_map}->{"Screen::EPrint::LocalSummary"} = undef;

# UseAsTemplate -> redirects to edit page after cloning
#$c->{plugin_alias_map}->{"Screen::EPrint::UseAsTemplate"} = "Screen::EPrint::LocalUseAsTemplate";
#$c->{plugin_alias_map}->{"Screen::EPrint::LocalUseAsTemplate"} = undef;

# The 'Manage Records' screen:
$c->{plugins}->{"Screen::DataSets"}->{appears}->{admin_actions_system} = 1600;
$c->{plugins}->{"Screen::DataSets"}->{appears}->{key_tools} = undef;

$c->{plugins}->{"Screen::EPrint::Box::BookmarkTools"}->{params}->{disable} = 1;
$c->{plugins}->{"Screen::EPrint::Box::CollectionMembership"}->{params}->{disable} = 1;

$c->{plugins}->{"Screen::EPrint::Edit"}->{appears}->{edshare_toolbox} = 20;
$c->{plugins}->{"Screen::EPrint::ExportZip"}->{appears}->{edshare_toolbox} = 29;
$c->{plugins}->{"Screen::EPrint::Public::RequestCopy"}->{action}->{request}->{appears}->{edshare_toolbox} = 40;
$c->{plugins}->{"MePrints::Widget::EPrintsIssues"}->{params}->{disable} = 1;
#$c->{plugins}->{"MePrints::Widget::Repostats::Downloads"}->{params}->{disable} = 1;
#$c->{plugins}->{"MePrints::Widget::Repostats::TopTen"}->{params}->{disable} = 1;
# Use RepoStats' one
$c->{plugins}->{"MePrints::Widget::TopTen"}->{params}->{disable} = 1;

$c->{plugins}->{"InputForm::Component::Field::TagLite"}->{params}->{disable} = 0;
$c->{plugins}->{"TagCloud"}->{params}->{disable} = 0;
#add mimetypes for css and javascript so they are served properly
$c->{mimemap}->{css}  = "text/css";
$c->{mimemap}->{js}  = "text/javascript";


