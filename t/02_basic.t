use strict;
use warnings;
use Test::More;
use lib 't/lib';

my $config;

BEGIN {
    plan skip_all => 'Set TEST_MOOSEX_ROLE_GDATA to run this test'
        unless $ENV{TEST_MOOSEX_ROLE_GDATA};

    eval "use Config::Pit";
    plan skip_all => 'Config::Pit not found' if $@;

    $config = Config::Pit::get('google.com');
    plan skip_all => 'set username and password for google.com via "ppit set google.com"'
        unless ($config->{username} && $config->{password});
    plan tests => 13;

    use_ok( 'Test::GData::DocumentsList' );
}

ok my $service = Test::GData::DocumentsList->initialize(
    username => $config->{username},
    password => $config->{password},
);

my $docname = 'foobar'.scalar localtime;
TODO: {
#    todo_skip 'not yet' => 2;
    ok my $entry = $service->post(
        Test::GData::DocumentsList::Entry->new(
            {
                title => $docname,
                kind => 'document',
            }
        )
    );
    isa_ok $entry, 'Test::GData::DocumentsList::Entry';
}

ok my $feed = $service->feed;
isa_ok $feed, 'Test::GData::DocumentsList::Feed';

ok my $entry = $feed->entries->[0];
isa_ok $entry, 'Test::GData::DocumentsList::Entry';
ok $entry->id, $entry->id;
ok $entry->title, $entry->title;
ok $entry->kind, $entry->kind;

{
    ok my ($entry) = grep {$_->title eq $docname} @{$feed->entries};
    ok $service->delete($entry);
}
