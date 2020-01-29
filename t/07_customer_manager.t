use strict;
use warnings;
use 5.10.0;
use FindBin 1.51 qw($RealBin);
use lib $RealBin;

use Test::More skip_all => 'integration tests must be filled with valid company data to run correctly';
use plenigo::Configuration;
use plenigo::CustomersManager;
use Try::Tiny;

my $company_id = '';
my $secret = '';

my $configuration = plenigo::Configuration->new(company_id => $company_id, secret => $secret, staging => 0);

my $customers_manager = plenigo::CustomersManager->new(configuration => $configuration);
my $customer_mail_part = 'perltest+' . time();
my %customer_details = $customers_manager->registerCustomer($customer_mail_part . '@example.com', 'DE', undef, 'MALE', 'Mike', 'Miller', 0, 0);
ok($customers_manager->editCustomer($customer_details{'customerId'}, $customerMailPart . '_changed@example.com'), 'Customers email changed successfully.');
