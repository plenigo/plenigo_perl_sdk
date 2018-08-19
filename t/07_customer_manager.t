#!/usr/bin/perl
use strict;
use warnings;
use 5.10.0;
use FindBin 1.51 qw($RealBin);
use lib $RealBin;

use Test::More tests => 1;
use plenigo::Configuration;
use plenigo::CustomersManager;
use Try::Tiny;

my $company_id = '';
my $secret = '';

my $configuration = plenigo::Configuration->new(company_id => $company_id, secret => $secret, staging => 0);

my $customersManager = plenigo::CustomersManager->new(configuration => $configuration);
my $customerMailPart = 'perltest+' . time();
my %customerDetails = $customersManager->registerCustomer($customerMailPart . '@example.com', 'DE', undef, 'MALE', 'Mike', 'Miller', 0, 0);
ok($customersManager->editCustomer($customerDetails{'customerId'}, $customerMailPart . '_changed@example.com'), 'Customers email changed successfully.');