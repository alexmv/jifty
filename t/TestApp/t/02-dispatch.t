#!/usr/bin/perl
use warnings;
use strict;

BEGIN {chdir "t/TestApp"}
use lib '../../lib';
use Jifty::Test tests => 24;
use Jifty::Test::WWW::Mechanize;

my $server  = Jifty::Test->make_server;

isa_ok($server, 'Jifty::Server');

my $URL     = $server->started_ok;
my $mech    = Jifty::Test::WWW::Mechanize->new();

$mech->get_ok("$URL/dispatch/basic", "Got /dispatch/basic");
$mech->content_contains("Basic test.");
$mech->content_contains("Count 0");
$mech->content_contains("before 0");
$mech->content_contains("after 0");

$mech->get_ok("$URL/dispatch/basic-show", "Got /dispatch/basic-show");
$mech->content_contains("Basic test with forced show.");
$mech->content_contains("Count 1");
$mech->content_contains("before 1");
$mech->content_contains("after 1");

$mech->get_ok("$URL/dispatch/show/", "Got /dispatch/show");
$mech->content_contains("Basic test with forced show.");
$mech->content_contains("Count 2");
$mech->content_lacks("Count 3");
$mech->content_contains("before 3");
$mech->content_contains("after 2");

$mech->get_ok("$URL/dispatch/", "Got /dispatch/");
$mech->content_contains("Basic test.");
$mech->content_contains("Count 3");
$mech->content_lacks("Count 4");
$mech->content_contains("before 4");
$mech->content_contains("after 3");



