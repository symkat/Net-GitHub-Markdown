#!/usr/bin/perl
use warnings;
use strict;
use Test::More;

use_ok($_) for qw/ WWW::Mechanize HTML::TreeBuilder Net::GitHub::Markdown /;

done_testing;
