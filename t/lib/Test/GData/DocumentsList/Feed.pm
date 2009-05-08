package Test::GData::DocumentsList::Feed;
use Any::Moose;

with 'MooseX::GData::Feed';

sub entry_class { 'Test::GData::DocumentsList::Entry' }

1;
