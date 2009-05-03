package Test::GData::DocumentsList::Entry;
use Moose;
use Moose::Util::TypeConstraints;
use XML::Atom;

enum 'Test::GData::DocumentsList::Entry::Kind'
    => qw(spreadsheet document);

has id => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    lazy_build => 1,
);

has title => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    lazy_build => 1,
);

has kind => (
    is => 'ro',
    isa => 'Test::GData::DocumentsList::Entry::Kind',
    required => 1,
    lazy_build => 1,
);

has entry => (
    is => 'rw',
    isa => 'XML::Atom::Entry',
    required => 1,
    lazy_build => 1,
);

my $ns = XML::Atom::Namespace->new('gd', 'http://schemas.google.com/g/2005');

sub _build_id {
    my $self = shift;
    return $self->entry->get($ns, 'resourceId');
}

sub _build_title {
    my $self = shift;
    return $self->entry->title;
}

sub _build_kind {
    my $self = shift;
    my ($cat) = grep {
        $_->scheme eq 'http://schemas.google.com/g/2005#kind'
    } $self->entry->category;
    return $cat->label;
}

sub _build_entry {
    my $self = shift;
    my $atom = XML::Atom::Entry->new(Version => 1);
    $atom->title($self->title) if $self->{title};
    $atom->set($ns, 'resourceID', $self->id) if $self->{id};
    my $cat = XML::Atom::Category->new(Version => 1);
    $cat->scheme('http://schemas.google.com/g/2005#kind');
    $cat->term(join("#", 'http://schemas.google.com/docs/2007',$self->kind));
    $atom->category($cat);
    return $atom;
}

1;
