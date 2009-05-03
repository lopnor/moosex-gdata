package Test::GData::DocumentsList::Feed;
use Moose;
use Moose::Util::TypeConstraints;
use Test::GData::DocumentsList::Entry;

subtype 'XML::Atom::Feed'
    => as 'Object'
    => where {$_->isa('XML::Atom::Feed')};

subtype 'Test::GData::DocumentsList::EntryList'
    => as 'ArrayRef';

coerce 'Test::GData::DocumentsList::EntryList'
    => from 'XML::Atom::Feed'
    => via {
        my $feed = shift;
        return [
            map {Test::GData::DocumentsList::Entry->new({entry => $_})} $feed->entries
        ];
    };

has entries => (
    is => 'ro',
    isa => 'Test::GData::DocumentsList::EntryList',
    coerce => 1,
);

1;
