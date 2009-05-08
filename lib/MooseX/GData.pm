package MooseX::GData;
use Any::Moose '::Role';

use Carp;
use LWP::UserAgent;
use URI;
use HTTP::Headers;
use HTTP::Request;
use Net::Google::AuthSub;
use XML::Atom::Feed;
use XML::Atom::Entry;

our $VERSION = '0.01';

requires qw(service source);

has username => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has password => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has ua => (
    isa => 'LWP::UserAgent',
    is => 'ro',
    lazy_build => 1,
);

has gdata_version => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => '2',
);

sub _build_ua {
    my $self = shift;

    my $auth = Net::Google::AuthSub->new(
        service => 'writely',
        source => $self->source,
    );

    my $res = $auth->login(
        $self->username,
        $self->password,
    );
    unless ($res && $res->is_success) {
        croak 'Net::Google::AuthSub login failed';
    }

    my $ua = LWP::UserAgent->new(
        agent => $self->source,
    );
    $ua->default_headers(
        HTTP::Headers->new(
            Authorization => sprintf('GoogleLogin auth=%s', $res->auth),
            GData_Version => $self->gdata_version,
        )
    );
    return $ua;
}

sub request {
    my ($self, $args) = @_;
    my $method = delete $args->{method};
    $method ||= $args->{content} ? 'POST' : 'GET';
    my $uri = URI->new($args->{'uri'});
    $uri->query_form($args->{query}) if $args->{query};
    my $req = HTTP::Request->new($method => "$uri");
    $req->content($args->{content}) if $args->{content};
    $req->header('Content-Type' => $args->{content_type}) if $args->{content_type};
    if ($args->{header}) {
        while (my @pair = each %{$args->{header}}) {
            $req->header(@pair);
        }
    }
    my $res = $self->ua->request($req);
    unless ($res->is_success) {
        die sprintf("request for '%s' failed: %s", $uri, $res->status_line);
    }
    return $res;
}

sub feed {
    my ($self, $url, $query) = @_;
    my $res = $self->request(
        {
            uri => $url,
            query => $query || undef,
        }
    );
    return XML::Atom::Feed->new(\($res->content));
}

sub entry {
    my ($self, $url, $query) = @_;
    my $res = $self->request(
        {
            uri => $url,
            query => $query || undef,
        }
    );
    return XML::Atom::Entry->new(\($res->content));
}

sub post {
    my ($self, $uri, $entry) = @_;
    my $res = $self->request(
        {
            uri => $uri,
            content => $entry->entry->as_xml,
            content_type => 'application/atom+xml',
        }
    );
    my $res_entry = XML::Atom::Entry->new(\($res->content));
    $entry->entry($res_entry);
    return $entry;
}

sub put {
    my ($self, $entry) = @_;
    my $res = $self->request(
        {
            uri => $entry->id,
            method => 'PUT',
            content => $entry->entry->as_xml,
            content_type => 'application/atom+xml',
            header => {
                'If-Match' => $entry->etag,
            }
        }
    );
    my $res_entry = XML::Atom::Entry->new(\($res->content));
    $entry->entry($res_entry);
    return $entry;
}

sub delete {
    my ($self, $entry) = @_;
    my $res = $self->request(
        {
            uri => $entry->id,
            method => 'DELETE',
            header => {
                'If-Match' => $entry->etag,
            }
        }
    );
    return $res->is_success;
}

1;
__END__

=head1 NAME

MooseX::Role::GData -

=head1 SYNOPSIS

  use MooseX::Role::GData;

=head1 DESCRIPTION

MooseX::Role::GData is

=head1 AUTHOR

Nobuo Danjou E<lt>nobuo.danjou@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
