use inc::Module::Install;
name 'MooseX-GData';
all_from 'lib/MooseX/GData.pm';

requires_any_moose;
requires 'Carp';
requires 'Net::Google::AuthSub';
requires 'Crypt::SSLeay';
requires 'LWP::UserAgent';
requires 'URI';
requires 'XML::Atom';
requires 'Class::Method::Modifiers';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
build_requires 'Test::Exception';
use_test_base;
auto_include;
WriteAll;
