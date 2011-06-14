#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Net::GitHub::Markdown;

my $tests = [
    {
        put => "# Hello World",
        get => '<div class="blob instapaper_body" id="readme"><div class="wikistyle"><h1>Hello World</h1></div></div>',
        say => "Basic Functionality Works.",
    },

];

ok my $Markdown = Net::GitHub::Markdown->new;

for my $test ( @$tests ) {
    is  $Markdown->markdown( $test->{put} ),
        $test->{get},
        $test->{say};
}

done_testing;
