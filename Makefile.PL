use inc::Module::Install;
name 'MooseX-Role-GData';
all_from 'lib/MooseX/Role/GData.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
