package Log::Contextual::NullLogger;

use strict;
use warnings;

{
  for my $name (qw( trace debug info warn error fatal )) {

    no strict 'refs';

    *{$name} = sub {};

    *{"is_$name"} = sub { 0 };
  }
}

sub new {
  my ($class, $args) = @_;
  bless {}, $class;
}

1;

