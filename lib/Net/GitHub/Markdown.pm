package Net::GitHub::Markdown;
use warnings;
use strict;
use WWW::Mechanize;
use HTML::TreeBuilder;
my $mech;
use Data::Dumper;

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
    $html =~ s/^<div id="readme">/\n <div class="wikistyle">/;
    $html .= "\n";

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
        form_number => 1,
        fields      => {
            'gist[files][][content]'  => $content,
            'gist[files][][language]' => 'Markdown',
            'gist[public]'            => 0,
        },
    );

    return $self->mech->content;
}

sub html_from_gist {
    my ( $self, $html ) = @_;
    my $root = HTML::TreeBuilder->new_from_content( $html );
    my $content = $root->look_down( _tag => 'div', "id" => "readme" )->as_HTML(undef, ' ', {});
    $root->delete;
    return $content;
}

1;
