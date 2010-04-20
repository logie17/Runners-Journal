use strict;
use warnings;
use Cwd;

my $test_db =  getcwd . '/test_data/test.db';

use Test::More tests => 2;                      # last test to print

# Use test
BEGIN{ use_ok('Runners::Journal'); }

# Builds DB Test
system("rm $test_db") if -e $test_db;
my $runners_obj = Runners::Journal->new;
$runners_obj->build_db($test_db);

is(-e $test_db, 1);


