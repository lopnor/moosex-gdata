package MooseX::GData::Feed;
use Any::Moose '::Role';
use Any::Moose '::Util::TypeConstraints';

requires 'entry_class';

subtype 'MooseX::GData::Type::EntryList'
    => as 'ArrayRef';

has feed => (
    is => 'rw',
    isa => 'XML::Atom::Feed',
);

has entries => (
    is => 'rw',
    isa => 'MooseX::GData::Type::EntryList',
    lazy_build => 1,
);

sub _build_entries {
    my $self = shift;
    my $class = $self->entry_class;
    Any::Moose::load_class($class);
    return [
        map { $class->new({atom => $_}) } $self->feed->entries
    ];
}

1;
