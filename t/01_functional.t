#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Net::GitHub::Markdown;

my $tests = [
    {
        put => "# Hello World",
        get => "\x0a\x20\x3c\x64\x69\x76\x20\x63\x6c\x61\x73\x73\x3d\x22" .
            "\x77\x69\x6b\x69\x73\x74\x79\x6c\x65\x22\x3e\x0a\x20\x20\x3c".
            "\x68\x31\x3e\x48\x65\x6c\x6c\x6f\x20\x57\x6f\x72\x6c\x64\x3c".
            "\x2f\x68\x31\x3e\x0a\x20\x3c\x2f\x64\x69\x76\x3e\x0a",
        say => "Basic Functionality Works.",
    },
    {
        put => "* Hello\n * World",
        get => "\x0a\x20\x3c\x64\x69\x76\x20\x63\x6c\x61\x73\x73\x3d\x22" .
            "\x77\x69\x6b\x69\x73\x74\x79\x6c\x65\x22\x3e\x0a\x20\x20\x3c".
            "\x75\x6c\x3e\x0a\x20\x20\x20\x3c\x6c\x69\x3e\x48\x65\x6c\x6c".
            "\x6f\x20\x3c\x75\x6c\x3e\x0a\x20\x20\x20\x20\x20\x3c\x6c\x69".
            "\x3e\x57\x6f\x72\x6c\x64\x3c\x2f\x6c\x69\x3e\x0a\x20\x20\x20".
            "\x20\x3c\x2f\x75\x6c\x3e\x0a\x20\x20\x20\x3c\x2f\x6c\x69\x3e".
            "\x0a\x20\x20\x3c\x2f\x75\x6c\x3e\x0a\x20\x3c\x2f\x64\x69\x76".
            "\x3e\x0a",
        say => "End tags close.",
    }

];

ok my $Markdown = Net::GitHub::Markdown->new;

for my $test ( @$tests ) {
    is  $Markdown->markdown( $test->{put} ),
        $test->{get},
        $test->{say};
}

done_testing;
