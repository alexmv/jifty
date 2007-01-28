use warnings;
use strict;

=head1 NAME

Jifty::Model::ModelClass - Tracks Jifty-related metadata

=head1 SYNOPSIS


=head1 DESCRIPTION

Every Jifty application automatically inherits this table, which
describes information about Jifty models which are stored only in the
database.  It uses this information to construct new model classes on
the fly as they're required by the application.

=cut

package Jifty::Model::ModelClass;
use Jifty::Model::ModelClassColumnCollection; # we can drop this when we switch to Jifty::DBI's od branch
use base qw( Jifty::Record );
use Jifty::DBI::Schema;
use Jifty::Record schema {
    column name => type is 'text';
    column description => type is 'text'; 
    column since_version => type is 'text';
    column included_columns => refers_to Jifty::Model::ModelClassColumnCollection by 'model_class';
};

=head2 table

Database-backed models are stored in the table C<_jifty_models>.

=cut

sub table {'_jifty_models'}

=head2 since

The metadata table first appeared in Jifty version 0.70127

=cut

sub since {'0.70127'}


=head2 qualified_class

Returns the fully qualified class name of the model class described the current ModelClass object.

=cut

sub qualified_class {
    my $self = shift;
    my $fully_qualified_class = Jifty->config->framework('ApplicationClass')."::Model::".$self->name;
    return $fully_qualified_class; 
}

=head2 instantiate 

For the currently loaded ModelClass object, loads up all its columns and
creates a model class definition and evals it into existence. Basically,
you call this method to create a live model class. It should probably
only be called by the Jifty classloader.

=cut

sub instantiate {
    my $self = shift;
    $self->_instantiate_stub_class;
    $self->qualified_class->_init_columns();
    my $cols = $self->included_columns;
    while (my $col = $cols->next) {
        my $column = Jifty::DBI::Column->new({ name => $col->name } );
        $self->qualified_class->COLUMNS->{$col->name} = $column;
        for (qw(readable writable hints indexed max_length render_as mandatory)) {
            $column->$_( $col->$_());
        }
        $column->type($col->storage_type);


        $self->qualified_class->_init_methods_for_column($column) 
    }

    return 1;
}



sub _instantiate_stub_class {
    my $self = shift;
    my $base_class
        = Jifty->config->framework('ApplicationClass') . "::Record";
    my $fully_qualified_class = $self->qualified_class();
    my $class                 = <<EOF;
use warnings;
use strict;
package $fully_qualified_class;
use base qw'$base_class';

sub _autogenerated {1}
1;

EOF

    eval "$class";
    if ($@) {
        warn $@;
    }
}

1;
