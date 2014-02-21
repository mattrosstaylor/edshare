package EPrints::Plugin::TagLiteSuggestionList::MostPopularUserTags;

use EPrints;

@ISA = ( 'EPrints::Plugin::TagLiteSuggestionList');

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	$self->{name} = "Provides a list of the user's most common tags";
	$self->{visible} = "all";

	return $self;
}

sub get_tag_suggestion_list
{
	my ( $self ) = @_;

	my $session = $self->{session};
	my $fieldname = $self->{fieldname};
	my $userid = $session->current_user->get_id;

	my $sql = "SELECT DISTINCT $fieldname, count($fieldname) FROM eprint_$fieldname WHERE eprintid IN ( SELECT eprintid FROM eprint WHERE userid='$userid' ) group by $fieldname order by count($fieldname) desc LIMIT 20;";

	my $search = $session->get_database->prepare( $sql );
	$session->get_database->execute( $search , $sql );
	my @list = ();

	while ( my ( $result ) = $search->fetchrow_array )
	{
		push ( @list, $result);
	}

	return \@list;
}

1;
