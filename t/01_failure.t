use strict;
use warnings;
use Test::More tests => 2;
use Test::Exception;

use lib 't/lib';

BEGIN {
    use_ok('Test::GData::DocumentsList');
}

throws_ok {
    my $dlist = Test::GData::DocumentsList->new(
        username => 'foo',
        password => 'bar',
    );
    $dlist->feed;
} qr{Net::Google::AuthSub login failed};
