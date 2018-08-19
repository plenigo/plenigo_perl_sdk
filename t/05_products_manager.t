#!/usr/bin/perl
use strict;
use warnings;
use 5.10.0;
use FindBin 1.51 qw( $RealBin );
use lib $RealBin;

use Test::More tests => 2;
use plenigo::Configuration;
use plenigo::ProductsManager;

my $company_id = '';
my $secret = '';
my $product_id = '';

my $configuration = plenigo::Configuration->new(company_id => $company_id, secret => $secret, staging => 0);

my $products = plenigo::access::ProductsManager->new(configuration => $configuration);
my %product = $products->getProductDetail($product_id);
is($product{'id'}, $product_id, 'Get product details for a single product.');

my %product_list = $products->getAllProducts(0, 10);
is($product_list{'pageNumber'}, 0, 'Get product details for all products.');