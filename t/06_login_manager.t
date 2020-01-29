use strict;
use warnings;
use 5.10.0;
use FindBin 1.51 qw($RealBin);
use lib $RealBin;

=pod
# integration tests must be filled with valid company data to run correctly

use Test::More tests => 2;
use plenigo::Configuration;
use plenigo::LoginManager;
use Try::Tiny;

my $company_id = '';
my $secret = '';
my $customer_id = '';
my $customer_email = '';
my $customer_password = '';

my $configuration = plenigo::Configuration->new(company_id => $company_id, secret => $secret, staging => 0);

my $loginManager = plenigo::LoginManager->new(configuration => $configuration);
my %customer_details = $loginManager->verifyLoginData($customer_email, $customer_password);
is($customer_details{'userId'}, $customer_id, 'Check customer\'s log in data via API.');

ok($loginManager->createLoginTokens($customer_id), 'Create login tokens for a given user.');
=cut
