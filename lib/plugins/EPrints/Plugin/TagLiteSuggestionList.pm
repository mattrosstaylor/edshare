package EPrints::Plugin::TagLiteSuggestionList;

use EPrints;
use POSIX qw/floor/;

@ISA = ( 'EPrints::Plugin');
$EPrints::Plugin::TagLiteSuggestionList::DISABLE = 1;

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	$self->{name} = 'TagLiteSuggestionList Superclass';
	$self->{visible} = "all";
	$self->{fieldname} = $opts{fieldname};

	return $self;
}

sub get_tag_suggestion_list
{
	my ( $self ) = @_;
	my @list = ();
	return \@list;
}

sub render_suggestion_table
{
	my ( $self, $number_of_table_columns, $js_var_name ) = @_;
	my $session = $self->{session};
	my $frag = $session->make_doc_fragment();
	my $suggestion_list = $self->get_tag_suggestion_list();
	my $count = scalar(@{ $suggestion_list }); 

	if ( $count )
	{
		my $suggestions_per_column = floor($count / $number_of_table_columns);
		my $overflow_columns = $count % $number_of_table_columns;

		my $table = $session->make_element( "table" );
		$frag->appendChild( $table );

		my $column_no = $number_of_table_columns;
		my $row_no = -1; # set to -1 so that the first increment makes it zero, son
		my $tr;
		for my $i ( 0 .. $count-1 )
		{
			if ( $column_no < $number_of_table_columns-1 )
			{
				$column_no++;
			}
			else
			{
				$tr = $session->make_element( "tr" );
				$table->appendChild( $tr );
				$column_no = 0;
				$row_no++;
			}

			# calculate index for this cell
			my $index;

			if ($column_no < $overflow_columns)
			{
				$index = $column_no*($suggestions_per_column+1) +$row_no;
			}
			else
			{
				$index = ($column_no-$overflow_columns)*($suggestions_per_column) +($overflow_columns*($suggestions_per_column+1)) +$row_no;
			}	
			my $tag = $suggestion_list->[$index];
			my $tag_single_quote_escaped = $tag;
			$tag_single_quote_escaped =~ s/'/\\'/g;
			my $td = $session->make_element( "td" );
			my $tag_anchor = $session->make_element( "a", "href" => "#", "onclick" => "$js_var_name.initTag( '$tag_single_quote_escaped' );return false;" );
			$tag_anchor->appendChild( $session->make_text( $tag ) );
			$td->appendChild( $tag_anchor );
			$tr->appendChild( $td );
		}
	}
	else
	{
		$frag->appendChild( $session->html_phrase( "Plugin/TagLiteSuggestionList:none_found" ) );
	}
	return $frag;
}

1;
