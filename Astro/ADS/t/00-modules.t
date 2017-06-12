#!perl -T
# from http://perlbuzz.com/2017/06/11/improve-your-test-logs-with-simple-distro-diagnostics/

use warnings;
use strict;
use Test::More tests => 1;

use Astro::ADS;
use LWP::UserAgent;
use Net::Domain;

my @modules = qw(
	LWP::UserAgent
	Net::Domain
    Test::More
);

pass( 'All external modules loaded' );

diag( "Testing Astro::ADS version $Astro::ADS::VERSION under Perl $], $^X" );
for my $module ( @modules ) {
    no strict 'refs';
    my $ver = ${$module . '::VERSION'};
    diag( "Using $module $ver" );
}
