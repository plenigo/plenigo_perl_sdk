use strict;
use warnings;
use 5.10.0;
use FindBin 1.51 qw( $RealBin );
use lib $RealBin;

use Test::Exception;
use Test::More;
use plenigo::Configuration;
use plenigo::AccessRightsManager;

{
    package Mock::Client;
    use Moo;
    has configuration => (is => 'ro');

    sub get {
        my ($self, $path, $args) = @_;

        return $self->_user_product_details($path, $args)
            if ($path eq 'user/product/details');
    }

    sub _user_product_details {
        my ($self, $path, $args) = @_;
        my $test_cases = {
            'bad_data' => { },
            'customer_123_will_renew' => {
                accessGranted => \1,
                userProducts  => [{
                    blocked => \0,
                    nextRenewalDate => 1582761600000,
                    productId => $args->{productId},
                }],
            },
            'customer_456_will_not_renew' => {
                accessGranted => \1,
                userProducts  => [{
                    blocked => \0,
                    nextRenewalDate => 0,
                    productId => $args->{productId},
                }],
            },
        };
        return (exists $test_cases->{ $args->{customerId} }) ?
            $test_cases->{ $args->{customerId} } :
            { error => 'User is not allowed to access the product requested.' };
    }
    1;
}

sub make_candidate {
    my $configuration = plenigo::Configuration->new(
        company_id => 'company_id',
        secret => 'secret',
        staging => 0,
        @_,
    );
    my $access_rights = plenigo::AccessRightsManager->new(
        configuration => $configuration,
        _rest_client => Mock::Client->new,
    );
}

subtest 'AccessRightsManager' => sub {
    my $access_rights = make_candidate;
    isa_ok($access_rights, 'plenigo::AccessRightsManager');
};

subtest 'willRenew' => sub {
    my $access_rights = make_candidate;
    can_ok($access_rights, ('willRenew'));
    is(
        $access_rights->willRenew('customer_123_will_renew', 'product_123'),
        1,
        'customer will renew'
    );
    is(
        $access_rights->willRenew('customer_456_will_not_renew', 'product_123'),
        '',
        'customer will not renew'
    );
    throws_ok {
        $access_rights->willRenew('no_such_customer', 'product_123')
    } 'plenigo::Ex', 'error thrown for unknown customer';
    throws_ok {
        $access_rights->willRenew('bad_data', 'product_123')
    } 'plenigo::Ex', 'error thrown for bad response';
};

my $company_id = $ENV{PLENIGO_COMPANY_ID} || '';
my $secret = $ENV{PLENIGO_SECRET} || '';
my $plenigo_customer_id = $ENV{PLENIGO_CUSTOMER_ID} || '';

SKIP: {
    skip 'integration tests must be filled with valid company data to run correctly', 3
        unless $company_id && $secret;

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
}


done_testing;
