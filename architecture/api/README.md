# Mobile Application Rest API(s)

There are several api's that are in use by each application.

TODO: (update) Swagger files

## Holder App
Full url of the api is: `https://holder-api.ENV.coronacheck.nl/v#/holder/`

Api Name     | CDN | CMS  | Description
-------------|-----|------|-------------------|
config       | Yes | Yes  | Application configuration file
config_ctp   | Yes | Yes  | Configuration file containing public key(s) from Coronatest Providers used for Certificate Pinning and CMS Signature verification
public_keys  | Yes | Yes  | Contains public_keys used by CL cryptography
test_types   | Yes | Yes  | List of possible tests (`uuid` and `name`)
nonce        | No  | No   | Gets a `nonce` and `stoken` used in CL cryptography
get_test_ism | No  | No   | Turns a `test-result` into a `signed-test-result`


## Verifier App
Full url of the api is: `https://verifier-api.ENV.coronacheck.nl/v#/verifier/`

Api Name     | CDN | CMS  | Description
-------------|-----|------|-------------------|
config       | Yes | Yes  | Application configuration file
public_keys  | Yes | Yes  | Contains public_keys used by CL cryptography
test_types   | Yes | Yes  | List of possible tests (`uuid` and `name`)
