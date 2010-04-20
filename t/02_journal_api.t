use strict;
use warnings;
use Cwd;
my $test_db =  getcwd . '/test_data/test.db';

use Test::More tests => 11;                      # last test to print

# Use test
BEGIN{ use_ok('Runners::Journal'); }

# Builds DB Tests
my $journal_obj = Runners::Journal->new;
system("rm $test_db") if -e $test_db;
$journal_obj->build_db($test_db);
is(-e $test_db, 1);

# Setup a test run
$journal_obj->{dbh}->do(qq~insert into running_journal (run_name) values(?)~, undef, 'baz');

# Test create_run
my $run_obj = $journal_obj->create_run(run_name => "Foo");
isa_ok $run_obj, 'Runners::Run';
is $run_obj->run_name, "Foo";
is $run_obj->id, 2;

# Test get_run
is $journal_obj->get_run, undef;
my $second_run_obj = $journal_obj->get_run(id => 1);
isa_ok $second_run_obj,'Runners::Run'; 
is $second_run_obj->run_name, 'baz';
is $second_run_obj->id, 1;

# Test update_run/get_run
$second_run_obj->run_name('foobar');
$journal_obj->update_run($second_run_obj);
my $third_run_obj = $journal_obj->get_run(id=>1);
is $third_run_obj->run_name, 'baz';
is $third_run_obj->id, 1;



