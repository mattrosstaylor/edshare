package EPrints::Plugin::TagLiteSuggestionList::StaticTags;

use EPrints;

@ISA = ( 'EPrints::Plugin::TagLiteSuggestionList');

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	$self->{name} = "A static list of tags";
	$self->{visible} = "all";
	$self->{list} = $opts{list};
	return $self;
}

sub get_tag_suggestion_list
{
	my ( $self ) = @_;
	return $self->{list};
}

1;
