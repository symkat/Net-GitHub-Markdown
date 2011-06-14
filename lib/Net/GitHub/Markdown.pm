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
    my $html = $self->html_from_gist(
        $self->create_gist($content)
    );
    $html =~ s/^<div class="blob instapaper_body" id="readme">//;
    $html =~ s/<\/div>$//;
    $html =~ s/^ <div class="wikistyle">/<div id="markdown">/;
    return $html;
}

sub mech {
    return $mech if $mech;

    $mech = WWW::Mechanize->new( 
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
                'authenticity_token' => $self->_get_auth_token($content),
            }
        );
        my $status = $self->mech->status;
        warn "Expected 200, but got $status while deleting the gist." 
            unless $status == 200;
    } else {
        warn "Expected an ID, but couldn't find one. Please report this.";
    }

    return $content;
}

sub html_from_gist {
    my ( $self, $html ) = @_;
    my $root = HTML::TreeBuilder->new_from_content( $html );
    my $content = $root->look_down( _tag => 'div', "id" => "readme" )->as_HTML(undef, ' ', {});
    $root->delete;
    return $content;
}

# Deleting gists is ugly and NOT cheap.  This is
# due to GitHub using JS to automagically create
# the HTML form and force me to look through HTML
# to find it.

sub _get_auth_token {
    my ( $self, $html ) = @_;
    my $root = HTML::TreeBuilder->new_from_content($html);
    my $content = $root->look_down( _tag => 'div', 'id' => 'delete_link' )->as_HTML;

    if ( $content =~ /([a-f0-9]{40})/ ) {
        return $1;
    }
    warn "Deleting Gists is not functioning correctly. Please report this.";
}

1;
