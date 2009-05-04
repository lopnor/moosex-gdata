package MooseX::GData::Feed;
use Moose::Role;
use Moose::Util::TypeConstraints;

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
    Class::MOP::load_class($class);
    return [
        map { $class->new({entry => $_}) } $self->feed->entries
    ];
}

1;
