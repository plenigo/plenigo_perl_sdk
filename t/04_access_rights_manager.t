#!/usr/bin/perl
use strict;
use warnings;
use 5.10.0;
use FindBin 1.51 qw( $RealBin );
use lib $RealBin;

use Test::More tests => 3;
use plenigo::Configuration;
use plenigo::AccessRightsManager;

my $company_id = '';
my $secret = '';
my $plenigo_customer_id = '';

my $configuration = plenigo::Configuration->new(company_id => $company_id, secret => $secret, staging => 0);

my $access_rights = plenigo::AccessRightsManager->new(configuration => $configuration);
my %access_rights = $access_rights->hasAccess($plenigo_customer_id, ['perl_test']);
is($access_rights{'accessGranted'}, 0, 'Check access right exists.');

$access_rights->addAccess($plenigo_customer_id, (details => [{productId => 'perl_test'}]));
%access_rights = $access_rights->hasAccess($plenigo_customer_id, ['perl_test']);
is($access_rights{'accessGranted'}, 1, 'Check if access right exists after addition.');

$access_rights->removeAccess($plenigo_customer_id, ['perl_test']);
%access_rights = $access_rights->hasAccess($plenigo_customer_id, ['perl_test']);
is($access_rights{'accessGranted'}, 0, 'Check if access right exists after removal.');