package EPrints::Plugin::Export::Zip;

@ISA = ('EPrints::Plugin::Export');

use strict;

sub new
{
        my ($class, %opts) = @_;

        my $self = $class->SUPER::new(%opts);

        $self->{name} = 'Zip';
        $self->{accept} = [ 'list/eprint' ];
        $self->{visible} = 'all';
        $self->{suffix} = '.zip';
        $self->{mimetype} = 'application/zip';

        my $rc = EPrints::Utils::require_if_exists('Archive::Zip');
        unless ($rc)
        {
                $self->{visible} = '';
                $self->{error} = 'Unable to load required module Archive::Zip';
        }

        return $self;
}




sub output_list
{
        my ($plugin, %opts) = @_;

        my $archive = '';
        my $FH;

        unless( open ($FH, '>', \$archive) )
        {
                print STDERR "\nCould not create filehandle: $!";
                return ();
        }


        my $zip = Archive::Zip->new;

        my $index = <<END;
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
  <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
      <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
      <title>EPrints Search Results</title>
    </head>
  <body>
END

        my $session = $plugin->{session};

        my @html_array;

        my $info = { zip => $zip, html => \@html_array, count => 1 };
        $opts{list}->map( \&_add_to_zip, $info );

        $index .= join( "\n", @html_array );

        $index .= '</body></html>';

        if (defined $opts{fh})
        {
            $zip->writeToFileHandle($opts{fh},'zip');
            return undef;
        }

        $zip->writeToFileHandle($FH,'zip');

        return $archive;
}
sub _add_to_zip
{
        my ( $session, $dataset, $eprint, $info ) = @_;

        my @docs = $eprint->get_all_documents;

        my $zip = $info->{zip};

        my $user = $session->current_user;
        my $eprintid = $eprint->get_id;

        my $frag = "<div><h2>".$info->{count}++.". ".$eprint->get_value( "title" )."</h2><ul>";
        $frag .= "<li>No documents</li>" unless scalar @docs;

        foreach my $doc ( @docs )
        {
                my $doc_fn = $doc->get_main;
                my $doc_title = $doc_fn;

                # not logged in and doc is not public = BAD
                if ( !defined $user && ($doc->get_value( "security" ) ne 'public' ))
                {
                        $frag .= "<li>$doc_title - restricted (try logging in and exporting again).</li>";
                        next;
                }

                # logged in and cannot view document = BAD
                if ( defined $user && ( !$doc->user_can_view( $user ) ) )
                {
                        $frag .= "<li>$doc_title - restricted.</li>";
                        next;
                }

                # GOOD otherwise

                my $path = $doc->local_path;
                my $docpos = $doc->get_value( "pos" );

        #       $zip->addTree( $path, "export/$eprintid/$docpos" );
                $zip->addTree( $path, "" );

                $frag .= "<li><a href='$eprintid/$docpos/$doc_fn'>$doc_title</a></li>";
        }

        $frag .= "</ul></div>";

        push @{$info->{html}}, $frag;

}

1;

