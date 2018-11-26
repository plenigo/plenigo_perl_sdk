#!/usr/bin/perl
use strict;
use warnings;
use 5.10.0;
use FindBin 1.51 qw($RealBin);
use lib $RealBin;

=pod
# integration tests must be filled with valid company data to run correctly

use Test::More tests => 1;
use plenigo::Configuration;
use plenigo::CustomersManager;
use plenigo::PurchasesManager;
use Try::Tiny;

my $company_id = '';
my $secret = '';

my $configuration = plenigo::Configuration->new(company_id => $company_id, secret => $secret, staging => 0);

my $customers_manager = plenigo::CustomersManager->new(configuration => $configuration);
my $customer_mail_part = 'perltest+' . time();
my %customer_details = $customers_manager->registerCustomer($customer_mail_part . '@example.com', 'DE', undef, 'MALE', 'Mike', 'Miller', 0, 0);

my $purchases_manager = plenigo::PurchasesManager->new(configuration => $configuration);
ok($purchases_manager->getCustomerSubscriptions($customer_details{'customerId'}), 'Subscriptions of the customer returned successfully.');
=cut
