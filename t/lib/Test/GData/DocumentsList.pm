package Test::GData::DocumentsList;
use MooseX::Singleton;
with 'MooseX::GData';
use Test::GData::DocumentsList::Feed;

our $VERSION = '0.01';
sub service { 'writely' }
sub source { __PACKAGE__ . $VERSION }
sub baseurl { 'http://docs.google.com/feeds/documents/private/full' }

around feed => sub {
    my ($next, $self, $args) = @_;
    my $feed = $next->($self, 
        baseurl,
        $args,
    );
    return Test::GData::DocumentsList::Feed->new({feed => $feed});
};

around post => sub {
    my ($next, $self, $entry) = @_;
    return $next->($self,
        baseurl,
        $entry
    );
};

1;
