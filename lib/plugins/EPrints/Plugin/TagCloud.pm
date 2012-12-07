package EPrints::Plugin::TagCloud;

# Original work by Patrick McSweeney/OneShare project
#
# Generalised by EPrints Services/sf2: now works with any field, and provides a non-rendering method

@ISA = ( 'EPrints::Plugin' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{min_percent} = 80 unless( defined $self->{min_percent} );
	$self->{max_percent} = 120 unless( defined $self->{max_percent} );
	$self->{tags} = {} unless( defined $self->{tags} );
	$self->{done_processing} = 0;
	$self->{fieldname} = 'keywords' unless( defined $self->{fieldname} );
	$self->{max_display} = 50 unless( defined $self->{max_display} );
	$self->{randomise} = 1 unless( defined $self->{randomise} );

	return $self;
}

sub render
{
	my( $self, $data ) = @_;

	my $session = $self->{session};
	
	$self->_calculate_sizes();
	my $sizes = $self->{sizes};

	my $frag = $session->make_doc_fragment;
	my $tagcloud = $session->make_element( 'div', class=>'ep_tag_cloud' );

	while( my( $key, $size ) = each( %$sizes ) )
	{
		my $tag = $session->make_element( 'span', style=>'font-size:'.$size.'%' );
		if( defined $self->{link_url_begin} && defined $self->{link_url_end} )
		{
			my $escape_key = $key;
			$escape_key = $self->escape_path( $escape_key );
			my $link = $session->make_element("a", href=>$self->{link_url_begin}.$escape_key.$self->{link_url_end});
			$tag->appendChild($link);
			$link->appendChild( $session->make_text( $key ) );
		}
		else
		{
			$tag->appendChild( $session->make_text( $key ) );
		}
		$tagcloud->appendChild( $tag );
		$tagcloud->appendChild($session->make_text(" "));
	}

	$frag->appendChild( $tagcloud );

	return $frag;
}

# sf2 - from perl_lib/EPrints/Utils.pm::escape_filename (minus the bit that replaces spaces with underscores)
sub escape_path
{
	my( $self, $value ) = @_;

        return "NULL" if( $value eq "" );

        $value = "$value";
        utf8::decode($value);
        # now we're working with a utf-8 tagged string, temporarily.

        # Valid chars: 0-9, a-z, A-Z, ",", "-", " "

        # Escape to either '=XX' (8bit) or '==XXXX' (16bit)
        $value =~ s/([^0-9a-zA-Z,\- ])/
                ord($1) < 256 ?
                        sprintf("=%02X",ord($1)) :
                        sprintf("==%04X",ord($1))
        /exg;

        utf8::encode($value);

        return $value;
}

sub get_raw_tags
{
	my( $self ) = @_;

	$self->_calculate_sizes();
	return $self->{sizes};
}

sub _calculate_sizes
{
	my( $self ) = @_;

	return if( $self->{done_processing} );

	$self->_get_tags();

	my $data = $self->{tags};
	my $sizes = ();
	
	my $min_occurrence = undef; 
	my $max_occurrence  = 0;
	while( my( $key, $value ) = each( %$data ) )
	{
		$min_occurrence = $value if $min_occurrence > $value or !defined $min_occurrence;
		$max_occurrence = $value if $max_occurrence < $value;
	}

	while( my( $key, $value ) = each( %$data ) )
	{
		my $weight = ( log( $value ) - log( $min_occurrence ) ) / ( log( $max_occurrence+1 ) - log( $min_occurrence ) );
		$sizes->{$key} = $self->{min_percent} + int( ( ( ( $self->{max_percent} - $self->{min_percent} ) * $weight ) + 0.5 ) * ( $weight <=> 0 ) );
	}

	$self->{sizes} = $sizes;
	$self->{done_processing} = 1;

	return;
}

sub _get_tags
{
	my( $self ) = @_;

	return if( EPrints::Utils::is_set( $self->{tags} ) );

	my $session = $self->{session};
	my $dbh = $session->get_database;

	my $Q_table = $dbh->quote_identifier( 'eprint_'.$self->{fieldname} );
	my $Q_fieldname = $dbh->quote_identifier( $self->{fieldname} );
	my $Q_epid = $dbh->quote_identifier( 'eprintid' );
	my $Q_eptable = $dbh->quote_identifier( 'eprint' );
	my $Q_epstatus = $dbh->quote_identifier( 'eprint_status' );
	my $Q_archive = $dbh->quote_value( 'archive' );
	
	my $sql = "SELECT count( $Q_table.$Q_fieldname  ), $Q_table.$Q_fieldname FROM $Q_table 
			INNER JOIN $Q_eptable 
			ON $Q_table.$Q_epid = $Q_eptable.$Q_epid
			AND $Q_eptable.$Q_epstatus = $Q_archive
			GROUP BY $Q_table.$Q_fieldname";

	my $order_by = $self->{randomise} ? " ORDER BY RAND() DESC" : " ORDER BY count( $Q_table.$Q_fieldname ) DESC";

	$sql .= $order_by;

	my $sth = $dbh->prepare_select( $sql, limit => $self->{max_display } );
	$session->get_database->execute( $sth, $sql );
	
	while( my( $count, $tag ) = $sth->fetchrow_array )
	{
		$self->{tags}->{$tag} = $count;
	}

	return;
}


1;
