use inc::Module::Install;

name            'Runners-Journal';
author          'Logan Bell <logan@orchardtech.com>';
version         '0.01';
license         'gpl';
perl_version    '5.008008';
all_from        'lib/Runners/Journal.pm';

#requires        'Test::MockModule'      => '0.05';

WriteAll;
