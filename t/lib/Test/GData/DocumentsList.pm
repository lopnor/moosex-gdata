package Test::GData::DocumentsList;
use MooseX::Singleton;
with 'MooseX::Role::GData';
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
    return Test::GData::DocumentsList::Feed->new(
        {
            entries => $feed
        }
    );
};

around post => sub {
    my ($next, $self, $entry) = @_;
    my $ret = $self->$next(
        baseurl,
        $entry->entry,
    );
    return Test::GData::DocumentsList::Entry->new({entry => $ret});
};

around put => sub {
    my ($next, $self, $args) = @_;
    $self->$next(
        {
            uri => join('/', baseurl, $args->id),
        }
    );
};

around delete => sub {
    my ($next, $self, $entry) = @_;
    my $ret = $self->$next(
        join('/', baseurl, $entry->id),
    );
    return $ret->is_success;
};

1;
