package EPrints::Plugin::Screen::EPMC::EdShareCore;

@ISA = ( 'EPrints::Plugin::Screen::EPMC' );

use EPrints::Plugin::Screen::EPMC;
use File::Copy;

use strict;

our @replaced_files = (
	"/citations/eprint/default.xml",
	"/citations/eprint/result.xml",
	"/lang/en/static/index.xpage",
	"/namedsets/eprint",
	"/namedsets/licenses",
	"/namedsets/user",
	"/workflows/eprint/default.xml",
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

	if ( not EPrints::DataObj::EPM->can('check_epm_dataset_update_supression_activated' )) { $self->{processor}->add_message( "error", $repo->make_text( "Aborted: dataset update supression has not been activated in EPrints::DataObj::EPM" ) ); return; }

	print STDERR "\nENABLING ".$self->{package_name}."\n";

	my $cfg_dir = $repo->config( "config_path" );
	print STDERR "  moving";
	foreach (@replaced_files)
	{
		print STDERR " $_";
		move( $cfg_dir.$_, $cfg_dir.$_.$self->{replace_suffix} );		
	}
	print STDERR "\n";

	$self->SUPER::action_enable( $skip_reload );
}

sub action_disable
{
	my( $self, $skip_reload ) = @_;
	my $repo = $self->{repository};

	if ( not EPrints::DataObj::EPM->can('check_epm_dataset_update_supression_activated' )) { $self->{processor}->add_message( "error", $repo->make_text( "Aborted: dataset update supression has not been activated in EPrints::DataObj::EPM" ) ); return; }

	print STDERR "\nDISABLING ".$self->{package_name}."\n";

	$self->SUPER::action_disable( $skip_reload );

	my $cfg_dir = $repo->config( "config_path" );
	print STDERR "  restoring";
	foreach (@replaced_files)
	{
		print STDERR " $_";
		move( $cfg_dir.$_.$self->{replace_suffix}, $cfg_dir.$_ );		
	}
	print STDERR "\n";

	$self->reload_config if !$skip_reload;
}

1;
