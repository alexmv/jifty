use warnings;
use strict;

package Jifty::Plugin::Login::Notification::ConfirmAddress;
use base qw/Jifty::Notification Jifty::Plugin::Login/;

=head1 NAME

Jifty::Plugin::Login::Notification::ConfirmAddress

=head1 ARGUMENTS

C<to>, a L<Jifty::Plugin::Login::Model::User> whose address we are confirming.

=cut

=head2 setup

Sets up the fields of the message.

=cut

sub setup {
    my $self = shift;

    unless ( UNIVERSAL::isa($self->to, $self->LoginUserClass) ){
	$self->log->error((ref $self) . " called with invalid user argument");
	return;
    } 
   

    my $letme = Jifty::LetMe->new();
    $letme->email($self->to->email);
    $letme->path('confirm_email'); 
    my $confirm_url = $letme->as_url;
    my $appname = Jifty->config->framework('ApplicationName');

    $self->subject( _("Welcome to ")."$appname!" );
    $self->from( Jifty->config->framework('AdminEmail') );

    $self->body(_("
You're getting this message because you (or somebody claiming to be you)
signed up for %1.

Before you can use %1, we need to make sure that we got your email
address right.  Click on the link below to get started:

%2
",$appname,$confirm_url));

}

1;