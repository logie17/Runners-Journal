package Runners::Journal;
use strict;
use warnings;
use DBI;
use Runners::Run;
use base qw(Class::Accessor);

our $VERSION = 0.01;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# CONSTANTS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

use constant COLUMNS        => scalar 'id,run_name,date,description';
use constant TABLE_NAME     => scalar 'running_journal';

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


sub build_db
# Purpose:  Builds the DB from scratch
# Input:    1. Ref to self
# Input:    2. Path to db_path (Sqlite)
# Output:   True
{
    my ($self, $db_path) = @_;

    return if !$db_path;

    $self->_dbh_connect($db_path);
    $self->_build_db;

    return 1;
}

sub create_run
# Purpose:  Creates run, inserts in DB and associated Runner object
# Input:    1. Ref to self
#           2. List if where parameters
# Output:   Runners::Run object
{
    my ($self, %params) = @_;

    return if !$params{run_name};

    return $self->_insert_query(%params);

}

sub get_run
# Purpose:  Gets a run object based on an id
# Input     1. Ref to self
#           2. List of where parameters
# Output:   
{
    my ($self, %params) = @_;

    return $self->_select_query( %params );

}

sub update_run
{
    my ($self, $run_obj) = @_;

    my %params = map { $_ => $run_obj->$_ } @{$self->{columns_ar}}; 

    $self->_update_query(%params); 

    return $run_obj;

}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# PRIVATE METHODS 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

sub _build_db
# Purpose:  Builds db
# Input:    1. Ref to self 
# Output:   1. True
{
    my ($self) = @_;
    my @data = <DATA>;    
    my $sql_statement = join "", @data;
    $self->{dbh}->do($sql_statement);

    return 1;
}

sub _create_obj
# Purpose:  Creates a run object
# Input:    1. Ref to self
#           2. List of params
# Output:   1. Runner::Journal object
{
    my ($self, %params) = @_;

    my $run_obj = Runners::Run->new(%params);

    return $run_obj;
}

sub _dbh_connect
# Purpose:  Connects to database
# Input:    1. Ref to self
#           2. Path to db file
# Output:   1. True
{
    my ($self, $db_path) = @_;

    $self->{$db_path} ||= $db_path;
    $self->{dbh} = DBI->connect("dbi:SQLite:dbname=$db_path","","") || die "Can't connect to $db_path: $DBI::errstr";

    return 1;
}

sub _init
# Purpose: Initializes object state
# Input:   Ref to self
#          Hash ref of parameters
# Output:  Ref to to self
{
    my ($self, $params_hr) = @_;

    $self->_dbh_connect($params_hr->{db_path}) if defined $params_hr->{db_path} && $params_hr->{db_path};
    @{$self->{columns_ar}} = split(/,/, COLUMNS());

    return $self;
}

sub _insert_query
# Purpose:  A method to insert against DB
# Input:    1. Ref to self
#           2. Hash of parameters
# Output:   1. A new Runners::Run object
{
    my ($self, %params) = @_;

    my $insert_clause   =  '(' . join(',', map { $_ } keys %params) . ')';
    $insert_clause      .= ' values(' . join (',', map{'?'} values %params) . ')';

    my @values = values %params;

    my $sql_statement = "insert into " . TABLE_NAME . " " . $insert_clause;

    $self->{dbh}->do($sql_statement, undef, @values);

    my $id = $self->{dbh}->last_insert_id('','','','');

    return $self->_create_obj(id => $id, %params);
}

sub _select_query
# Purpose:  A method to do basic queries against the DB.
# Input:    1. Ref to self
#           2. Hash of parameters
# Output:   1. A new Runners::Run object
{
    my ($self, %params) = @_;

    return if !%params;
    
    my ($where_clause, @where_values) = $self->_where_clause(%params);

    my $sql_statement = "select " . COLUMNS . " from " . TABLE_NAME . " where " . $where_clause;

    my $row_hr = $self->{dbh}->selectrow_hashref($sql_statement, undef, @where_values);

    if ( my $id = $row_hr->{id} )
    {
        return $self->_create_obj(id => $id, %{$row_hr});
    }

    return undef;
}

sub _update_query
# Purpose:  A method to do updates against DB
# Input:    1. Ref to self
#           2. Hash of parameters
# Output:   True
{
    my ($self, %params) = @_;

    return if !$params{id};

    my ($where_clause, @where_values) = $self->_where_clause( id => $params{id});

    my $update_clause   =  join(',', map { $_  . '=?'} grep {$_ ne 'id'} keys %params);

    my @values = values %params;

    my $sql_statement = "update " . TABLE_NAME . " set " . $update_clause . " where " . $where_clause;

    $self->{dbh}->do($sql_statement, undef, @values);

    return 1; 
}

sub _where_clause
# Purpose:  Build out where clause
# Input:    1. Ref to self 
#           2. Hash ref of key/values for where clause construction
# Output:   1. String (where clause - with place holders)
#           2. A list of where values
{
    my ($self, %where) = @_;

    my $where_clause = join '', map { $_ . '= ? ' } keys %where;
    my @where_values = values %where;

    return ($where_clause, @where_values);
}

1;

__DATA__
create table running_journal(
    id integer primary key autoincrement,
    run_name varchar(255),
    date date,
    description text
);
commit;

__END__

=head1 Synopsis

my $journal = Runners::Journal->new;

my $run_obj = $journal->get_run(where => { name="foo" } );

$run_obj->description("bar");

$journal_obj->update_run($run_obj);

$journal_obj->delete_run($run_obj);

$journal_obj->create_run(run_name => "Foo", description => "Bar");


