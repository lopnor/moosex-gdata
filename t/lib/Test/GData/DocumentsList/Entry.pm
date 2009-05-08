package Test::GData::DocumentsList::Entry;
use Any::Moose;
use Any::Moose '::Util::TypeConstraints';

with 'MooseX::GData::Entry';
use XML::Atom::Category;

enum 'Test::GData::DocumentsList::Entry::Kind'
    => qw(spreadsheet document);

has kind => (
    is => 'ro',
    isa => 'Test::GData::DocumentsList::Entry::Kind',
    required => 1,
    lazy_build => 1,
);

sub _build_kind {
    my $self = shift;
    return $self->_kind_from_atom($self->atom);
}

around _build_atom => sub {
    my ($next, $self) = @_;
    my $atom = $next->($self);
    if ($self->{kind}) {
        my $cat = XML::Atom::Category->new(Version => 1);
        $cat->scheme('http://schemas.google.com/g/2005#kind');
        $cat->term(join("#", 'http://schemas.google.com/docs/2007',$self->{kind}));
        $atom->category($cat);
    }
    return $atom;
};

sub _kind_from_atom {
    my ($self, $atom) = @_;
    my ($cat) = grep {
        $_->scheme eq 'http://schemas.google.com/g/2005#kind'
    } $atom->category;
    return $cat->label;
}

1;
