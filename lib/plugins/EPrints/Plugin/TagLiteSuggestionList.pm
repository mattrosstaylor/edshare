package EPrints::Plugin::TagLiteSuggestionList;

use EPrints;

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
	return @list;
}

1;
