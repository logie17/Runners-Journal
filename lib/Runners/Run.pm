package Runners::Run;
use strict;
use warnings;

use base qw(Class::Accessor);

our $VERSION = 0.01;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# STATIC METHODS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

sub new
# Purpose: Constructor
# Input:   Ref/String of class
#          Hash of parameters
# Output:  Ref to instance
{
    my ( $class, %params) = @_;

    my $self = bless {}, ref($class) || $class;

    $self->_init(\%params);

    return $self;
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# PUBLIC METHODS 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

__PACKAGE__->mk_accessors(qw(id run_name date description));

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# PRIVATE METHODS 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

sub _init
# Purpose: Initializes object state
# Input:   Ref to self
#          Hash ref of parameters
# Output:  Ref to to self
{
    my ($self, $params_hr) = @_;

    $self->id($params_hr->{id} || undef);
    $self->run_name($params_hr->{run_name} || undef);

    return $self;
}

1;
