use strict;
use warnings;
use 5.10.0;
use FindBin 1.51 qw( $RealBin );
use lib $RealBin;

use Test::More tests => 1;
use Crypt::JWT qw(decode_jwt);
use plenigo::Configuration;
use plenigo::CheckoutHelper;
use plenigo::Product;

my $configuration = plenigo::Configuration->new(company_id => 'company_id', secret => 'secret', staging => 0);

my $product = plenigo::Product->createPlenigoProduct('productId');
my $checkoutHelper = plenigo::CheckoutHelper->new(configuration => $configuration);
my $jwt_token = $checkoutHelper->createCheckoutCode($product);
my %decodedJwt = %{decode_jwt(token => $jwt_token, key => $configuration->secret)};
is($decodedJwt{'pi'}, 'productId', 'Check created checkout token for product.');