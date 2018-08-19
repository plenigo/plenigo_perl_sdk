package plenigo::RestClient;

use REST::Client;
use JSON;
use Carp qw(confess);
use Carp::Always;
use Crypt::JWT qw(encode_jwt);
use Data::UUID;
use Moo;
use plenigo::Ex;

our $VERSION = '0.1000';

has configuration => (
    is       => 'ro',
    required => 1
);

sub _createJwt {
    my ($self) = @_;

    my $ug = Data::UUID->new;
    my $uuid = $ug->create();
    my $exp = time() + (5 * 60);
    my $jws_token = encode_jwt(payload => { jti => $ug->to_string($uuid), aud => 'plenigo', exp => $exp, companyId => $self->configuration->company_id }, alg => 'HS256', key => $self->configuration->secret);
    return $jws_token
}

sub _createRestClient {
    my ($self) = @_;

    my $client = REST::Client->new({
        host    => $self->configuration->api_host,
        timeout => 10,
    });
    $client->addHeader('plenigoToken', $self->_createJwt);
    $client->addHeader('Content-Type', 'application/json');
    $client->addHeader('Accept', 'application/json');

    return $client;
}

sub _checkResponse {
    my ($self, $client) = @_;

    if ($client->responseCode == 400) {
        plenigo::Ex->throw({ code => 400, message => 'The given parameters could not be processed.', errorDetails => decode_json($client->responseContent) });
    }
    if ($client->responseCode == 401) {
        plenigo::Ex->throw({ code => 401, message => 'API request could not be authorized. Company id or/and secret is/are not correct.' });
    }
    if ($client->responseCode == 500) {
        plenigo::Ex->throw({ code => 500, message => 'There was an internal error. Please try again later.' });
    }
}

sub get {
    my ($self, $url_path, $query_params) = @_;

    my $client = $self->_createRestClient;
    $client->GET($self->configuration->api_url . $url_path . $client->buildQuery($query_params));
    $self->_checkResponse($client);
    return(response_code => $client->responseCode, response_content => decode_json($client->responseContent));
}

sub post {
    my ($self, $url_path, $query_params, %body) = @_;

    my $client = $self->_createRestClient;
    my $json_text = encode_json \%body;
    $client->POST($self->configuration->api_url . $url_path . $client->buildQuery($query_params), $json_text);
    $self->_checkResponse($client);
    my $responseContent;
    if (not $client->responseContent eq "") {
        $responseContent = decode_json($client->responseContent);
    }
    return(response_code => $client->responseCode, response_content => $responseContent);
}

sub put {
    my ($self, $url_path, $query_params, %body) = @_;

    my $client = $self->_createRestClient;
    my $json_text = encode_json \%body;
    $client->PUT($self->configuration->api_url . $url_path . $client->buildQuery($query_params), $json_text);
    $self->_checkResponse($client);
    my $responseContent;
    if (not $client->responseContent eq "") {
        $responseContent = decode_json($client->responseContent);
    }
    return(response_code => $client->responseCode, response_content => $responseContent);
}

sub delete {
    my ($self, $url_path, $query_params) = @_;

    my $client = $self->_createRestClient;
    $client->DELETE($self->configuration->api_url . $url_path . $client->buildQuery($query_params));
    $self->_checkResponse($client);
    my $responseContent;
    if (not $client->responseContent eq "") {
        $responseContent = decode_json($client->responseContent);
    }
    return(response_code => $client->responseCode, response_content => $responseContent);
}

1;
