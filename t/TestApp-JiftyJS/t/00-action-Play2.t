#!/usr/bin/env perl
use warnings;
use strict;

=head1 DESCRIPTION

A (very) basic test harness for the Play2 action.

=cut

use lib 't/lib';
use Jifty::SubTest;
use Jifty::Test tests => 1;

# Make sure we can load the action
use_ok('TestApp::JiftyJS::Action::Play2');
