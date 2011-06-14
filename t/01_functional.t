#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Net::GitHub::Markdown;

my $tests = [
    {
        put => "# Hello World",
        get => '<div id="markdown"><h1>Hello World</h1></div>',
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
