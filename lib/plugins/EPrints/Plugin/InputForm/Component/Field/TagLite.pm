package EPrints::Plugin::InputForm::Component::Field::TagLite;

use EPrints::Plugin::InputForm::Component::Field;
@ISA = ( "EPrints::Plugin::InputForm::Component::Field" );

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
		$self->{config}->{suggestions_url} = $fields[0]->getAttribute( 'suggestions_url' );
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
	my $target_name = $prefix."_values";
	my $placeholder_name = $prefix."_placeholder";
	my $suggestions_name = $prefix."_suggestions";

	my $content = $session->make_element( "div", "class" => "edshare_taglite" );
	my $placeholder_div = $session->make_element( "div", "id" => $placeholder_name );
	$placeholder_div->appendChild($session->html_phrase( "Field/TagLite:$fieldname:placeholder") );
	$content->appendChild( $placeholder_div );
	my $target_div = $session->make_element( "div", "id" => $target_name );
	$content->appendChild( $target_div );
	my $script_content = "var ".$js_var_name." = new inputTagLite( '".$js_var_name."', '".$prefix."', '$fieldname' );";

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

	my $js_function_call = $js_var_name.".addFromInput( document.getElementById( '".$input_name."' ) )";

	my $input = $session->make_element( "input",
		"type"=>"text",
		"size"=>"30",
		"name"=> $input_name,
		"id"=> $input_name,
		"class" => "edshare_taglite_input",
		"onKeyPress" => "return EPJS_block_enter(event)",
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

	my $suggestions = $session->make_element( "div", id=> $suggestions_name, class => "edshare_taglite_suggestions" );
	$content->appendChild( $suggestions);

	$link = $session->make_element( "a", href=>"#", onclick => "new Ajax.Updater( '$suggestions_name', '".$self->{config}->{suggestions_url}."?jsvar=$js_var_name&fieldname=".$field->get_name."', { method:'get', onComplete: function(req) { \$('$suggestions_name').innerHTML = req.responseText; } } );return false;" );

	$link->appendChild( $session->html_phrase( "Field/TagLite:$fieldname:show_suggestions"  ) );
	$suggestions->appendChild( $link );

=pod
	my @plugin_list = qw( MostPopularUserTags StaticTags );

	my $number_of_table_columns = 4;
	foreach my $plugin_name (@plugin_list)
	{
		my $plugin = $session->plugin( "TagLiteSuggestionList::".$plugin_name, fieldname=>$fieldname );


		my $header = $session->make_element("h2");
                $header->appendChild( $session->html_phrase( "Plugin/TagLiteSuggestionList/".$plugin_name.":legend" ) );
		$suggestions->appendChild( $header );
		$suggestions->appendChild( $plugin->render_suggestion_table( 4, $js_var_name));
	}
=cut
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

