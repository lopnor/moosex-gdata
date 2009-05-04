package MooseX::GData::Entry;
use Moose::Role;

use MooseX::GData;
use XML::Atom;
use XML::Atom::Entry;

has id => (
    is => 'rw',
    isa => 'Str',
    lazy_build => 1,
    trigger => sub { shift->dirty(1) },
);

has title => (
    is => 'rw',
    isa => 'Str',
    lazy_build => 1,
    trigger => sub { shift->dirty(1) },
);

has etag => (
    is => 'rw',
    isa => 'Str',
);

has entry => (
    is => 'rw',
    isa => 'XML::Atom::Entry',
    lazy_build => 1,
    trigger => sub {
        my ($self,$entry) = @_;
        $self->{etag} = $entry->get_attr('gd:etag');
        $self->{id} = $entry->id;
        $self->{title} = $entry->title;
        $self->dirty(0);
    },
);

has dirty => (
    is => 'rw',
    isa => 'Bool',
);

my $ns = XML::Atom::Namespace->new('gd', 'http://schemas.google.com/g/2005');

sub _build_id {
    my $self = shift;
    return $self->entry->id;
}

sub _build_title {
    my $self = shift;
    return $self->entry->title;
}

around entry => sub {
    my ($next, $self, $arg) = @_;
    unless ($arg) {
        $self->{entry} = $self->_build_entry if $self->dirty;
        return $next->($self);
    }
    $next->($self, $arg);
};

sub _build_entry {
    my $self = shift;
    my $atom = XML::Atom::Entry->new(Version => 1);
    $atom->title($self->title) if $self->{title};
    $atom->id($self->id) if $self->{id};
    $atom->set_attr($ns, 'etag', $self->{etag}) if $self->{etag};
    return $atom;
}

1;
