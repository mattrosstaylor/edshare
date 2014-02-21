package EPrints::Plugin::Convert::OfficePreview;

=pod

=head1 NAME

EPrints::Plugin::Convert::ImageMagick::OfficeToPDF

=cut

use strict;
use warnings;

use Carp;

use EPrints::Plugin::Convert;
our @ISA = qw/ EPrints::Plugin::Convert /;

our (%FORMATS, @ORDERED, %FORMATS_PREF);
@ORDERED = %FORMATS = qw(
doc application/msword
ppt application/vnd.ms-powerpoint
pps application/vnd.ms-powerpoint
xls application/vnd.ms-excel
docx application/msword
pptx application/vnd.ms-powerpoint
xlsx application/vnd.ms-excel
);
# formats pref maps mime type to file suffix. Last suffix
# in the list is used.
for(my $i = 0; $i < @ORDERED; $i+=2)
{
	$FORMATS_PREF{$ORDERED[$i+1]} = $ORDERED[$i];
}
our $EXTENSIONS_RE = join '|', keys %FORMATS;



sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );

	$self->{name} = "OfficePreview document";
	$self->{visible} = "all";

	return $self;
}

sub can_convert
{
	my ($plugin, $doc) = @_;
	
	return unless $plugin->get_repository->get_conf( 'executables', 'convert' );

	my %types;

	# Get the main file name
	my $fn = $doc->get_main() or return ();


	if( $fn =~ /\.($EXTENSIONS_RE)$/oi ) 
	{
                #$types{"thumbnail_small"} = { plugin => $plugin, };
                #$types{"thumbnail_medium"} = { plugin => $plugin, };
                #$types{"thumbnail_preview"} = {	plugin => $plugin, };
                #$types{"thumbnail_lightbox"} = { plugin => $plugin, };
		#$types{"application/pdf"} = { 
                #                plugin => $plugin,
                #                phraseid => "document_typename_application/pdf",
                #                preference => 1,
		#};


                $types{"thumbnail_pdf"} = { plugin => $plugin, };
	}
	return %types;
}

sub export
{
	my ( $plugin, $dir, $doc, $type ) = @_;

	my $soffice = "/usr/lib/libreoffice/program/soffice";
	my $filepath = $doc->stored_file($doc->get_main)->get_local_copy;
	my @args = ("--headless", "--invisible", "--nosplash", "--nofirststartwizard", "--convert-to", "pdf", "--outdir", $dir , $filepath);

	system($soffice, @args);
	my $command = $soffice." ".join(" ", @args);
	print STDERR $command."\n\n";

	my $pdf = $doc->get_main;
	$pdf =~ s/\..{3,4}$/.pdf/;

	unless( defined $pdf && -s $dir.'/'.$pdf )
	{
		$plugin->get_repository()->log("The pdf created for doc ".$doc->get_id()." is a zero byte file an so cannot be converted.");
		return ();
	}

	return $pdf;

	# conversion to PDF (from e.g. the Uploader):
	if( $type eq 'application/pdf' )
	{
		if( $pdf =~ /^\/.*\/(.*)$/ )
		{
			return $1;
		}

		return ();
	}

        $type =~ m/^thumbnail_(.*)$/;
        my $size = $1;
        return () unless defined $size;

        my $geom = { small=>"66x50", medium=>"200x150",preview=>"400x300", lightbox=>"640x480" }->{$1};

        return () unless defined $geom;

        my @converted_files;
	
	my $convert = $plugin->get_repository->get_conf( 'executables', 'convert' ) or return ();

	my $fn = $size.".png";
	system($convert, "-size","$geom>", $pdf.'[0]', '-resize', "$geom>", $dir . '/' . $fn);
	return () unless( -e "$dir/$fn" );
	EPrints::Utils::chown_for_eprints( "$dir/$fn" );
	push @converted_files, $fn;

        return @converted_files;

}

1;
