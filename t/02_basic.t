use strict;
use warnings;
use Test::More;
use lib 't/lib';

my $config;

BEGIN {
    plan skip_all => 'Set TEST_MOOSEX_GDATA to run this test'
        unless $ENV{TEST_MOOSEX_GDATA};

    eval "use Config::Pit";
    plan skip_all => 'Config::Pit not found' if $@;

    $config = Config::Pit::get('google.com');
    plan skip_all => 'set username and password for google.com via "ppit set google.com"'
        unless ($config->{username} && $config->{password});
    plan tests => 20;

    use_ok( 'Test::GData::DocumentsList' );
    use_ok( 'Test::GData::DocumentsList::Entry' );
}

ok my $service = Test::GData::DocumentsList->new(
    username => $config->{username},
    password => $config->{password},
);

my $docname = 'foobar'.scalar localtime;
TODO: {
#    todo_skip 'not yet' => 3;
    ok my $topost = Test::GData::DocumentsList::Entry->new(
        {
            title => $docname,
            kind => 'document',
        }
    );
    ok my $entry = $service->post($topost);
    isa_ok $entry, 'Test::GData::DocumentsList::Entry';
}

ok my $feed = $service->feed;
isa_ok $feed, 'Test::GData::DocumentsList::Feed';

ok my $entry = $feed->entries->[0];
isa_ok $entry, 'Test::GData::DocumentsList::Entry';
ok $entry->id, $entry->id;
is $entry->title, $docname, "doc name is $docname";
ok $entry->kind, $entry->kind;
ok $entry->etag, $entry->etag;
$docname .= 'foo';
ok $entry->title($docname);
my $edited = $service->put($entry);
is $edited->title, $docname, 'title edited';

{
    ok my ($entry) = grep {$_->title eq $docname} @{$feed->entries};
    is $entry->title, $edited->title;
    is $entry->etag, $edited->etag;
    ok $service->delete($entry);
}
