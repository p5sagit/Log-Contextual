use strict;
use warnings;
use Test::More qw(no_plan);

#original bug report https://rt.cpan.org/Public/Bug/Display.html?id=83267

#The following code from Module::Metadata exposed the bug
#BEGIN {
#  if ($INC{'Log/Contextual.pm'}) {
#    Log::Contextual->import('log_info');
#  } else {
#    *log_info = sub (&) { warn $_[0]->() };
#  }
#}


#bug report does not include a case where Log::Contextual is
#brought in via 'use'
require Log::Contextual;

#try to import a single log function but do not include any tags
eval { Log::Contextual->import('log_info') };
ok(! $@, 'Imported log function correctly');
