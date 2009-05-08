package MooseX::GData::Entry;
use Any::Moose '::Role';

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

has atom => (
    is => 'rw',
    isa => 'XML::Atom::Entry',
    lazy_build => 1,
    trigger => sub {
        my ($self,$atom) = @_;
        $self->_update_atom($atom);
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

around atom => sub {
    my ($next, $self, $arg) = @_;
    unless ($arg) {
        $self->{atom} = $self->_build_atom if $self->dirty;
        return $next->($self);
    }
    $next->($self, $arg);
};

sub _update_atom {
    my ($self, $atom) = @_;
    $self->{etag} = $atom->get_attr('gd:etag');
    $self->{id} = $atom->id;
    $self->{title} = $atom->title;
    $self->dirty(0);
}

sub _build_atom {
    my $self = shift;
    my $atom = XML::Atom::Entry->new(Version => 1);
    $atom->title($self->title) if $self->{title};
    $atom->id($self->id) if $self->{id};
    $atom->set_attr($ns, 'etag', $self->{etag}) if $self->{etag};
    return $atom;
}

1;
