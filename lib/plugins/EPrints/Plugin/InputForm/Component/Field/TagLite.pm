package EPrints::Plugin::InputForm::Component::Field::TagLite;

use EPrints::Plugin::InputForm::Component::Field;
@ISA = ( "EPrints::Plugin::InputForm::Component::Field" );

use Unicode::String qw(latin1);

use strict;

sub new
{
        my( $class, %opts ) = @_;

        my $self = $class->SUPER::new( %opts );

        $self->{name} = "TagLite Field";
        $self->{visible} = "all";

        return $self;
}

sub parse_config
{
        my( $self, $config_dom ) = @_;

        my @fields = $config_dom->getElementsByTagName( "field" );

        if( scalar @fields != 1 )
        {
                EPrints::abort( "Bad configuration for Field Component\n".$config_dom->toString );
        }
        else
        {
                # we need to have the autocompleter URL ('input_lookup_url') set
                my $field = $fields[0];
                $self->{config}->{field} = $self->xml_to_metafield( $fields[0] );

                my $show_common_user_tags = $fields[0]->getAttribute( 'show_common_user_tags' );
                $self->{config}->{show_common_user_tags} = ($show_common_user_tags == 1);
        }
}

sub update_from_form
{
        my( $self, $processor ) = @_;
        my $field = $self->{config}->{field};

        my $session = $self->{session};

        my $obj = $self->{dataobj};

        if( $field->get_property( "multiple" ) )
        {
                my @values = ();

                my $basename = $self->{prefix}."_".$field->{name};

                my $params = _form_value_regex( $session, $basename );

                foreach my $p (@$params)
                {
                        my $value = $field->form_value_single( $session, $p, $obj );

                        next unless( EPrints::Utils::is_set( $value ) );

                        $value =~ s/^\s+//;
                        $value =~ s/\s+$//;

                        push @values, $value;
                }

                $self->{dataobj}->set_value( $field->{name}, \@values );
        }

}

sub _form_value_regex
{
        my ( $session, $regex ) = @_;

        my @values;

        my @params = $session->param;

        foreach(@params)
        {
                # must still end with a number:
                if( $_ =~ /$regex.*\d+$/ )
                {
                        push @values, $_;
                }
        }

        return \@values;
}

# dont need to override that:
sub validate
{
        my( $self ) = @_;

        my $field = $self->{config}->{field};

        my $for_archive = 0;

        if( $field->{required} eq "for_archive" )
        {
                $for_archive = 1;
        }

        my @problems;

        if( $self->is_required() && !$self->{dataobj}->is_set( $field->{name} ) )
        {
                my $fieldname = $self->{session}->make_element( "span", class=>"ep_problem_field:".$field->{name} );
                $fieldname->appendChild( $field->render_name( $self->{session} ) );
                my $problem = $self->{session}->html_phrase(
                        "lib/eprint:not_done_field" ,
                        fieldname=>$fieldname );
                push @problems, $problem;
        }

        push @problems, $self->{dataobj}->validate_field( $field->{name} );

        $self->{problems} = \@problems;

        return @problems;
}


# havent changed that:
sub render_title
{
        my( $self, $surround ) = @_;

        return $self->{config}->{field}->render_name( $self->{session} );
}

sub render_content
{
	my ( $self, $surround )  = @_;

	my $session = $self->{session};

	my $field = $self->{config}->{field};
	my $fieldname = $field->get_name;
	my $prefix = $self->{prefix}."_".$fieldname;
	my $js_var_name = $prefix."_object";

	# the target DIV element, which will get the newly enterred subjects
	my $target_name = $prefix."_actualvalues";

	my $content = $session->make_element( "div", "class" => "edshare_taglite" );
	my $target_div = $session->make_element( "div", "id" => $target_name );
	$content->appendChild( $target_div );
	my $script_content = "var ".$js_var_name." = new inputTagLite( document.getElementById( '".$target_name."' ),0,'".$js_var_name."', '".$prefix."', '$fieldname' );";

	my $eprint = $self->{workflow}->{item};
	my $values = $field->get_value( $eprint );

	if(defined $values)
	{
		foreach my $tag ( @{$values} )
		{
			$tag =~ s/\'/\\\'/g;
			$script_content .= "\n".$js_var_name.".initTag( '$tag' );";
		}
	}

	my $script = $session->make_javascript( "$script_content" );
	$content->appendChild( $script );

#	$content->appendChild( $session->html_phrase( "Field/TagLite:$fieldname:blurb") );

	my $input_name = $prefix."_inputer";

	my $js_function_call;
	if( $fieldname eq "courses" )
	{
		$js_function_call = $js_var_name.".initTagLine_CoursesCodes( document.getElementById( '".$input_name."' ) )";
	}
	else
	{
		$js_function_call = $js_var_name.".initTagLine( document.getElementById( '".$input_name."' ) )";
	}

	my $input = $session->make_element( "input",
		"type"=>"text",
		"size"=>"30",
		"name"=> $input_name,
		"id"=> $input_name,
		"class" => "edshare_taglite_input",
		"onKeyPress" => "return EPJS_block_enter(event)",
		"onblur" => "return $js_function_call;"
	);

	$content->appendChild( $input );

	# the name of the javascript object which holds the subjects

	my $enter_script = $session->make_javascript(<<ENTER_SCRIPT
\$('$input_name').observe('keypress', function(event) {
	var keycode;
	if (Object.isUndefined(event.which)) {
		keycode = event.keyCode;
	}
	else {
		keycode = event.which;
	}
	if (keycode == Event.KEY_RETURN) {
		return $js_function_call;
	}
});
ENTER_SCRIPT
);

	$content->appendChild( $enter_script );
	my $link = $session->make_element( "input", "type"=>"button", "value" => "Add", "onclick" => "return $js_function_call;", "class" => "ep_form_internal_button" );
	$content->appendChild( $link );

	if( defined $field->{input_advice_below} )
	{
		my $advice = $field->call_property( "input_advice_below", $session, $field, $values );
		my $advice_container = $session->make_element( "div", class=>"ep_taglite_advice_below" );
		$content->appendChild( $advice_container );
		$advice_container->appendChild( $advice );
	}

	# not sure of the condition to enable that feature:
	if( $self->{config}->{show_common_user_tags} )
	{
		my $suggestions_table = $session->make_element( "table", class => "edshare_taglite_suggestions_table" );
		$content->appendChild( $suggestions_table );

		my @plugin_list = qw( MostPopularUserTags );

		foreach my $plugin_name (@plugin_list)
		{
			my $tr = $session->make_element( "tr" );
			my $th = $session->make_element( "th" );
			$th->appendChild( $session->html_phrase( "Plugin/TagLiteSuggestionList/".$plugin_name.":legend" ) );
			$tr->appendChild( $th );
			my $td = $session->make_element( "td" );
			my $ul = $session->make_element( "ul" );
			$tr->appendChild( $td );
			$td->appendChild( $ul );

			my $plugin = $session->plugin( "TagLiteSuggestionList::".$plugin_name, fieldname=>$fieldname );
			my @suggestion_list = $plugin->get_tag_suggestion_list();

			if ( scalar( @suggestion_list ) )
			{
				foreach my $tag ( @suggestion_list )
				{
					my $tag_single_quote_escaped = $tag;
					$tag_single_quote_escaped =~ s/'/\\'/g;
					my $li = $session->make_element( "li" );
					my $tag_anchor = $session->make_element( "a", "href" => "#", "onclick" => "$js_var_name.initTag( '$tag_single_quote_escaped' );return false;" );
					$tag_anchor->appendChild( $session->make_text( $tag ) );
					$li->appendChild( $tag_anchor );
					$ul->appendChild( $li );
				}
				$suggestions_table->appendChild( $tr );
			}
			else
			{
				print "<p>No tag found</p>";
			}
		}
	}

	return $content;
}

sub could_collapse
{
        my( $self ) = @_;

# seb: forcing fields/components to be collapseable even though they are set!
#       return !$self->{dataobj}->is_set( $self->{config}->{field}->{name} );
        return 1;
}

sub get_field
{
        my( $self ) = @_;

        return $self->{config}->{field};
}

######################################################################
1;

