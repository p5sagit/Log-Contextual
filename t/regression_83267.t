use Test::More qw(no_plan);

BEGIN {
   #an optional expanded test mode
   if (0) {
      eval {
         package NotMain;

         use strict;
         use warnings;
         use Test::More;
         use Log::Contextual::SimpleLogger;

         use Log::Contextual qw(:log),
           -default_logger =>
           Log::Contextual::SimpleLogger->new({levels => [qw( )]});

         eval {
            log_info { "Yep" }
         };
         is($@, '', 'Invoked log function in package other than main');
      };

      is($@, '', 'non-main package subtest did not die');
   }
}

package main;

use strict;
use warnings;
use Test::More;

#bug report does not include a case where Log::Contextual is
#brought in via 'use'
require Log::Contextual;

#try to import a single log function but do not include any tags
eval { Log::Contextual->import('log_info') };
is($@, '', 'Imported log function with out dying');

eval {
   log_info { "test" } 1
};
like(
   $@,
   qr/^ no logger set!  you can't try to log something without a logger!/,
   'Got correct error'
);
