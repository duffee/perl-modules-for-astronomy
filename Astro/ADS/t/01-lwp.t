#!perl -T

use Test::More tests => 8;

use Astro::ADS::Query;

ok( $query = new Astro::ADS::Query(), 'Creating a query object');
is( $query->url(), 'cdsads.u-strasbg.fr', 'Defaults to strasbourg');
is( $query->proxy(), '', 'No proxy');

like( $query->agent(), qr{^Astro::ADS/$Astro::ADS::Query::VERSION \(.+\)$}, 'get the useragent string');
ok( $query->agent('Test Suite'), 'Add information to useragent string');
like( $query->agent(), qr{^Astro::ADS/$Astro::ADS::Query::VERSION \[Test Suite\] \(.+\)$}, 'get the modified useragent string');
ok( $query->agent(''), 'remove information from useragent string');
like( $query->agent(), qr{^Astro::ADS/$Astro::ADS::Query::VERSION \[\] \(.+\)$}, 'get the removed useragent string');
