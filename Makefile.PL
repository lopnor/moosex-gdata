use inc::Module::Install;
name 'MooseX-GData';
all_from 'lib/MooseX/GData.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
