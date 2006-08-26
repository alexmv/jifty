#!/usr/bin/env perl

use warnings;
use strict;

BEGIN {
    #### XXX: I know this is foolish but right now Jifty on Win32 fails to 
    #### unlink used test databases and the following tests fail saying
    #### 'error creating a table... table already exists'. So, remove the
    #### remnant first. And we should do it before none of the Jifty is there.

    my $testdb = 't/TestApp/testapptest';
    if (-e $testdb) {
        unlink $testdb or die $!;
    }
}

use lib 't/lib';
use Jifty::SubTest;
BEGIN { $ENV{'JIFTY_CONFIG'} = 't/config-Cachable' }

use Jifty::Test tests => 8;
use Jifty::Test::WWW::Mechanize;

# Make sure we can load the model
use_ok('TestApp::Model::User');

# Grab a system use
my $system_user = TestApp::CurrentUser->superuser;
ok($system_user, "Found a system user");

# Create a user
my $o = TestApp::Model::User->new(current_user => $system_user);
my ($id) = $o->create( name => 'edituser', email => 'someone@example.com' );
ok($id, "User create returned success");

my $server  = Jifty::Test->make_server;

isa_ok($server, 'Jifty::Server');

my $URL     = $server->started_ok;
my $mech    = Jifty::Test::WWW::Mechanize->new();

# Test action to update
$mech->get_ok($URL.'/editform?J:A-updateuser=TestApp::Action::UpdateUser&J:A:F:F-id-updateuser=1&J:A:F-name-updateuser=edituser&J:A:F-email-updateuser=newemail@example.com', "Form submitted");
undef $o;
$o = TestApp::Model::User->new(current_user => $system_user);
$o->flush_cache;
$o->load($id);
ok($id, "Load returned success");

is($o->email, 'newemail@example.com', "Email was updated by form");

1;

