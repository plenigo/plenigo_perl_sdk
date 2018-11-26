use strict;
use warnings;
use 5.10.0;
use FindBin 1.51 qw( $RealBin );
use lib $RealBin;

use Test::More tests => 3;
use plenigo::Configuration;
use plenigo::Product;

my $configuration = plenigo::Configuration->new(company_id => 'company_id', secret => 'secret', staging => 0);

my $product = plenigo::Product->createPlenigoProduct('productId');
my %checkout_data = $product->createCheckoutData($configuration);
is($checkout_data{'pi'}, 'productId', 'Check created checkout string for standard plenigo product.');

$product = plenigo::Product->createCustomProduct('productId', 'title', 'NEWSPAPER', 12.99, 'EUR');
%checkout_data = $product->createCheckoutData($configuration);
is($checkout_data{'pr'}, '12.99', 'Check created checkout string for custom product.');

$product = plenigo::Product->createModifiedPlenigoProduct('productId', 'newProductId', 'title');
%checkout_data = $product->createCheckoutData($configuration);
is($checkout_data{'pir'}, 'newProductId', 'Check created checkout string for plenigo product with overwritten product information.');