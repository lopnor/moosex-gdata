package Test::GData::DocumentsList::Feed;
use Moose;

with 'MooseX::GData::Feed';

sub entry_class { 'Test::GData::DocumentsList::Entry' }

1;
