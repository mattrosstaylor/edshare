package EPrints::Plugin::EdShareUtils;

@ISA = ( "EPrints::Plugin" );

use strict;
use warnings;

sub render_name_list
{
        my ( $session , $field , $value, $alllangs, $nolink, $object ) = @_;

        if( scalar(@$value) == 0)
        {
                return $session->make_doc_fragment;
        }

        # let's not rendered a list for only a single name
        if(scalar(@$value) == 1)
        {
                my $first = $$value[0];
                if(!defined $first || (!defined $first->{given} && !defined $first->{family}))
                {
                        print STDERR "\nFound name with no given_name or no family_name, eprintid is ".$object->get_id;
                        return $session->make_doc_fragment;
                }

                return _render_single_name( $session, $first, $field->name );
        }

        my $ul = $session->make_element( "ul", "class" => "ed_creatorsname" );

        foreach my $name ( @$value )
        {
                if(!defined $name || (!defined $name->{given} && !defined $name->{family}))
                {
                        if(defined $object){
                                print STDERR "\nFound name with no given_name or no family_name, eprintid is ".$object->get_id;
                        }
                        next;
                }

                my $li = $session->make_element( "li" );
                $ul->appendChild( $li );
                $li->appendChild( _render_single_name( $session, $name, $field->name ) );
        }

        return $ul;
}




sub render_creators_name
{
        my ( $session , $field , $value, $alllangs, $nolink, $object ) = @_;

        if( scalar(@$value) == 0)
        {
                return $session->make_doc_fragment;
        }

        # let's not rendered a list for only a single name
        if(scalar(@$value) == 1)
        {
                my $creator = $$value[0];
                if(!defined $creator->{name} || (!defined $creator->{name}->{given} && !defined $creator->{name}->{family}))
                {
                        print STDERR "\nFound name with no given_name or no family_name, eprintid is ".$object->get_id;
                        return $session->make_doc_fragment;
                }

                return _render_single_name( $session, $creator->{name}, "creators_name" );
        }

        my $ul = $session->make_element( "ul", "class" => "ed_creatorsname" );

        foreach my $creator ( @$value )
        {
                if(!defined $creator->{name} || (!defined $creator->{name}->{given} && !defined $creator->{name}->{family}))
                {
                        if(defined $object){
                                print STDERR "\nFound name with no given_name or no family_name, eprintid is ".$object->get_id;
                        }
                        next;
                }

                my $li = $session->make_element( "li" );
                $ul->appendChild( $li );
                $li->appendChild( _render_single_name( $session, $creator->{name}, "creators_name" ) );
        }

        return $ul;
}

sub _render_single_name
{
	my ( $session, $name, $fieldname ) = @_;

	my $given = $name->{given};
	my $family = $name->{family};
	my $honourific = $name->{honourific};
	my $rendered = "";

	#might need extra sanity test
	$rendered .= $honourific." " if( defined $honourific && $honourific ne "" );
	$rendered .= $given." " if(defined $given && $given ne "");
	$rendered .= $family if(defined $family && $family ne "");

	my $span = $session->make_element( "span", "class" => "person_name" );

	my $perl_url = $session->get_repository->get_conf( "perl_url" );

	if ( defined( $fieldname ) )
	{
		my $link = $session->make_element( "a", "target" => "_blank",
"href" => $perl_url."/search/advanced?screen=Public%3A%3AEPrintSearch&_action_search=Search&title_merge=ALL&title=&".$fieldname."_merge=ALL&".$fieldname."=".$family."&satisfyall=ALL&order=-date%2F".$fieldname."%2Ftitle" );

		$span->appendChild( $link );
		$link->appendChild( $session->make_text( $rendered ) );
	}
	else
	{
		$span->appendChild( $session->make_text( $rendered) );
	}


#if( defined $email && $email ne "" )
#{
#        $span->appendChild( $session->make_text( " ($email) " ) );
#}

	return $span;
}

sub render_name
{
        my ( $session , $field , $value, $alllangs, $nolink, $object ) = @_;

	return _render_single_name( $session, $value, $field->name );
}

sub render_name_no_link
{
        my ( $session , $field , $value, $alllangs, $nolink, $object ) = @_;

	return _render_single_name( $session, $value );
}



sub render_single_keyword                                                                           
{                                                                                                   
        my( $session , $field , $value, $alllangs, $nolink, $object ) = @_;                         
                                                                                                    
        return $session->make_doc_fragment unless(EPrints::Utils::is_set( $value ) );               
                                                                                                    
        my $base_url = $session->get_repository->get_conf( "base_url" );                            
                                                                                                    
        my $norm_value = normalise_keyword( $value );                              
                                                                                                    
        my $target = "$norm_value.html";                                                            

        if( $field->get_name eq 'courses' )                                                         
        {                                                                                           
                $target = $value."/";                                                               
        }                                                                                           
                                                                                                    
        my $link = $session->make_element( "a", href=>"$base_url/view/".$field->get_name."/$target" );
        $link->appendChild( $session->make_text( "$value" ) );                                      
                                                                                                    
        return $link;                                                                               
}                 

sub normalise_keyword
{
        my( $k ) = @_;

        my $nk = lc( $k );

        # e-learning => elearning
        $nk =~ s/^(e|on)-/$1/g;
        # evidence-based => evidence based
        $nk =~ s/-/ /g;
        # one two => one_two
        #$nk =~ s/ /_/g;
        # "blaf" => blaf
        $nk =~ s/"//g;
        $nk =~ s/^\s+//g;
        $nk =~ s/\s+$//g;

        return $nk;
}



1;
