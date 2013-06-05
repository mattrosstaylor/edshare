package EPrints::Plugin::Screen::EPMC::EdShareCore;

@ISA = ( 'EPrints::Plugin::Screen::EPMC' );

use EPrints::Plugin::Screen::EPMC;
use File::Copy;

use strict;

our @replaced_files = (
	"/namedsets/eprint",
	"/citations/eprint/default.xml",
);

sub new
{
	my ( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{actions} = [qw( enable disable )];
	$self->{disable} = 0;
	$self->{package_name} = "edshare_core";
	$self->{replace_suffix} = ".edshare_core_replaced";

	return $self;
}

sub action_enable
{
	my ($self, $skip_reload ) = @_;
	my $repo = $self->{repository};

	print STDERR "\nENABLING ".$self->{package_name}."\n";

	my $cfg_dir = $repo->config( "config_path" );
	foreach (@replaced_files)
	{
		print STDERR "  moving $_\n";
		move( $cfg_dir.$_, $cfg_dir.$_.$self->{replace_suffix} );		
	}

	$self->SUPER::action_enable( $skip_reload );
}

sub action_disable
{
	my( $self, $skip_reload ) = @_;

	print STDERR "\nDISABLING ".$self->{package_name}."\n";

	$self->SUPER::action_disable( $skip_reload );
	my $repo = $self->{repository};

	my $cfg_dir = $repo->config( "config_path" );
	foreach (@replaced_files)
	{
	
		print STDERR "  restoring $_\n";	
		move( $cfg_dir.$_.$self->{replace_suffix}, $cfg_dir.$_ );		
	}

	$self->reload_config if !$skip_reload;
}

1;
