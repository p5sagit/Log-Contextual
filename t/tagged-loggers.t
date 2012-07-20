use strict;
use warnings;

use Log::Contextual::SimpleLogger;

my $var2;
my $var_logger2;
BEGIN {
   $var_logger2 = Log::Contextual::SimpleLogger->new({
      levels  => [qw(trace debug info warn error fatal)],
      coderef => sub { $var2 = shift },
   })
}

use Log::Contextual qw{:log with_logger set_logger set_logger_for},
   -logger_for => { 'MyApp::View' => $var_logger2 },
   -logger => 'MyApp::View';
use Test::More qw(no_plan);

my $var1;
my $var3;
BEGIN {
   my $var_logger1 = Log::Contextual::SimpleLogger->new({
      levels  => [qw(trace debug info warn error fatal)],
      coderef => sub { $var1 = shift },
   });

   my $var_logger3 = Log::Contextual::SimpleLogger->new({
      levels  => [qw(trace debug info warn error fatal)],
      coderef => sub { $var3 = shift },
   });

   set_logger_for 'MyApp::Model' => $var_logger1;
   set_logger_for 'MyApp::Controller' => sub {
      my $package = shift;
      Log::Contextual::SimpleLogger->new({
         levels  => [qw(trace debug info warn error fatal)],
         coderef => sub { $var3 = (shift @_) . $package },
      })
   };
};

log_debug { 'should log to $var2 from global' };
is($var2, "[debug] should log to \$var2 from global\n", 'tag from -logger works');
$var2 = '';

with_logger 'MyApp::Model' => sub {
   log_debug { 'should log to $var1' };
};

is($var1, "[debug] should log to \$var1\n", 'basic tag works');

with_logger 'MyApp::View' => sub {
   log_debug { 'should log to $var2' };
};

is($var2, "[debug] should log to \$var2\n", 'basic tag from -logger_for works');

with_logger 'MyApp::Controller' => sub { Animorph::lol() };

is($var3, "[debug] should log to \$var3\nAnimorph", 'with logger outside of package works');

$var3 = '';

Zilog::lol();

is($var3, "[debug] should log to \$var3\nZilog", '-package_logger => "named_logger" works');

$var3 = '';

Mario::lol();

is($var3, "[debug] should log to \$var3\nMario", '-default_logger => "named_logger" works');

BEGIN {
   package Animorph;
   use Log::Contextual ':log';

   sub lol { log_debug { 'should log to $var3' } }
}

BEGIN {
   package Zilog;
   use Log::Contextual ':log', -package_logger => 'MyApp::Controller';

   sub lol { log_debug { 'should log to $var3' } }
}

BEGIN {
   package Mario;
   use Log::Contextual ':log', -default_logger => 'MyApp::Controller';

   sub lol { warn "foo"; log_debug { 'should log to $var3' } }
}
