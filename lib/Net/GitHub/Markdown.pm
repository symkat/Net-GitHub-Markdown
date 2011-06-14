package Net::GitHub::Markdown;
use warnings;
use strict;
use WWW::Mechanize;
use HTML::TreeBuilder;
my $mech;

our $VERSION = '0.001000'; # 0.1.0
$VERSION = eval $VERSION;

sub new {
    return bless {}, shift;
}


sub markdown {
    my ( $self, $content ) = @_;
    my $html_document = $self->create_gist( $content );
    return $self->html_from_gist( $html_document );
}

sub mech {
    $mech ||= WWW::Mechanize->new( 
        user_agent => 'WWW::GitHub::Markdown/0.01',
        timeout    => 60,
        cookie_jar => {},
    );
    $mech->add_header( accept_encoding => "" );
    return $mech;
}

sub create_gist {
    my ( $self, $content ) = @_;
    $self->mech->get( "http://gist.github.com/" );
    $self->mech->submit_form(
        form_number => 2,
        fields      => {
            'file_contents[gistfile1]' => $content,
            'file_ext[gistfile1]'      => '.md',
        },
    );

    $content = $self->mech->content;
    
    if ( $self->mech->title =~ /gist:\s+([a-f0-9]+)\s+/ ) {
        my $id = $1;
        $self->mech->post( "https://gist.github.com/delete/$id", 
            {
                '_method' => 'delete',
                'authenticity_token' => $self->_get_auth_token($content);
            }
        );
        my $status = $self->mech->status;
        warn "Expected 200, but got $status while deleting the gist." 
            unless $status == 200;
    } else {
        warn "Expected an ID, but couldn't find one.  Please report this.";
    }

    return $content;
}

sub html_from_gist {
    my ( $self, $html ) = @_;
    my $root = HTML::TreeBuilder->new_from_content( $html );
    my ($content) = $root->look_down(
        sub {
            $_[0]->tag and $_[0]->tag eq 'div' and
            $_[0]->attr('id') and $_[0]->attr( 'id' ) eq 'readme'
        }
    );
    return $content->as_HTML;
}

# Deleting gists is ugly and NOT cheap.  This is
# due to GitHub using JS to automagically create
# the HTML form and force me to look through HTML
# to find it.

sub _get_auth_token {
    my ( $self, $html ) = @_;
    my $root = HTML::TreeBuilder->new_from_content($html);
    my ($content) = $root->look_down(
        sub {
            $_[0]->tag and $_[0]->tag eq 'div' and
            $_[0]->attr('id') and $_[0]->attr('id') eq 'delete_link'
        }
    );

    if ( $content->as_HTML =~ /([a-f0-9]{40})/ ) {
        return $1;
    }
    warn "Deleting Gists is not functioning correctly. Please report this.";
}

1;