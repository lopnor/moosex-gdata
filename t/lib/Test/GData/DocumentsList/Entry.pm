package Test::GData::DocumentsList::Entry;
use Moose;
use Moose::Util::TypeConstraints;

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
    my ($cat) = grep {
        $_->scheme eq 'http://schemas.google.com/g/2005#kind'
    } $self->entry->category;
    return $cat->label;
}

around _build_entry => sub {
    my ($next, $self) = @_;
    my $atom = $self->$next;
    my $cat = XML::Atom::Category->new(Version => 1);
    $cat->scheme('http://schemas.google.com/g/2005#kind');
    $cat->term(join("#", 'http://schemas.google.com/docs/2007',$self->kind));
    $atom->category($cat);
    return $atom;
};

1;
