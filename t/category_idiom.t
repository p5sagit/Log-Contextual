use strict;
use warnings;

use Test::More;

my @out;

# these shouldn't be packages, but I'm not sure how else I'm going to
# do it yet.

{
   package CatLogger;

   use Log::Contextual::NullLogger;
   use base 'Log::Contextual::SimpleLogger';

   sub include_category { $_[1] eq 'awesome' }

   sub log_contextual_coderef {
      my $logger = CatLogger->new({ levels_upto => 'trace', coderef => sub { push @out, $_[0] } });

      return Log::Contextual::NullLogger->new
         unless $logger->include_category($_[0]{args}[0]);
      return $logger;
   }

   1;
}

{
   package Foo;

   use Log::Contextual ':log', -args => ['lame'],
      -package_logger => \&CatLogger::log_contextual_coderef;

   log_debug { 'test' };
}

ok @out == 0, 'no output because category is lame';

{
   package Bar;
   use Log::Contextual::NullLogger;

   use Log::Contextual ':log', -args => ['awesome'],
      -package_logger => \&CatLogger::log_contextual_coderef;

   log_debug { 'test' };
}

ok @out == 1, 'output because category is awesome';

done_testing;
