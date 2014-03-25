package EPrints::Plugin::PermissionType;

use EPrints;

@ISA = ( 'EPrints::Plugin');

$EPrints::Plugin::PermissionType::DISABLE = 1;

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	$self->{name} = 'PermissionType Superclass';
	$self->{visible} = "all";
	$self->{fieldname} = $opts{fieldname};
	$self->{basename} = $opts{basename};
	$self->{js_var_name} = $opts{js_var_name};
	$self->{permission_type} = "unknown";

	return $self;
}

sub requires_list
{
	my ( $self ) = @_;
	return 0;
}

sub _render_list_values
{
	my ( $self, $values ) = @_;
	my $session = $self->{session};

	my $js_var_name = $self->{js_var_name};
	my $add_values_javascript;

	foreach my $value ( @$values )
	{
		$add_values_javascript .= $js_var_name.".addPermittedFromString('".$self->{permission_type}."','".$value."','".$self->_render_value( $value )."');";
	}

	return $session->make_javascript( $add_values_javascript );
}

sub _render_value
{
	my ( $self, $value ) = @_;
	return $self->{permission_type}.": ". $value;
}

sub render
{
	my ( $self, @values ) = @_;

	return $self->html_phrase( "prompt" );
}


sub test
{
	my ( $self, $user, $eprint, $values ) = @_;

	return "DENY";
}

1;
