# Providing Vaccination / Test / Recovery Events by Digid

* Version 1.1
* Authors: Nick, Ivo

##Draft
This document is a draft and is not yet final. Changes are to be expected as requirements evolve.

## Overview

Netherlands has chosen to employ distributed data models where possible, there is no single source of truth that contains all test results and vaccinations of all citizens. The vaccination and test processes in the Netherlands therefor require the enrollment of an event in a provider database. As such vaccination, test and recovery events belonging to a person can be recorded in one or more systems.

For test results, people general know where they got tested. However, the place where a person's vaccination is registered is not (generally) communicated to the person and is not always linkable to a location. For example: a hospital worker will likely be vaccinated in their own hospital but not by the hospital staff. Their vaccation registration will end up in the database of the external entity. Similarly, a general practicioner could outsource the vaccination to central health services or vice versa, and one of them will hold the registration.

This process aims to allow a person to gather all their vaccination, test and recovery events in a privacy friendly way.

### Terminology
VEP - Vaccination Event Provider
TEP - Test Event Provider
REP - Recovery Event Provider

### Retrieval from the CoronaCheck apps

The CoronaCheck Android and iOS apps, and the web version (intended for desktop use / home printing) are all able to retrieve a person's events.

## Requirements

In order to be able to deliver vaccination, test or recovery events to CoronaCheck, a data source MUST do the following:

* Provide two endpoints:
  * An endpoint that an app can use to determine if a system contains information belonging to a person.
  * An endpoint that an app can use to retrieve events on behalf of the citizen, e.g. https://api.acme.inc/resultretrieval, according to the specs laid out in this document.
* Obtain a x509 PKI-O certificate for CMS signing events.
  * Use this certificate to sign all data responses.
  * Provide the public key of the X509 certificate to the CoronaCheck system so that signed results can be verified against the certificate.
* Obtain another x509 PKI-O certificate to secure the https endpoints
  * Use this certificate to secure the https end points
  * Provide the public key of the X509 certificate to the CoronaCheck system so that endpoints can be verified by TLS pinning.

## Identity Hash
In order to reliably determine a system contains information about a certain person without revealing who that person is an `identity-hash` will be generated for each individual connected party and sent to the Information endpoint. 

Since only the designated party may check the hash, a secret `hash key` is added. The `hash key` will be determined by MinVWS and shared privately with the provider. 

The hash will be created using the following items:

- BSN
- First Name (as it appears on a person's passport)
- Last Name (as it appears on a person's passport)
- Day of Birth (in String format with leading zero)

The `identity-hash` can be generated as follows:

```shell
echo -n "<BSN>-<First Name>-<Last Name>-<Day Of Birth>" | openssl dgst -sha256 -hmac "<hash key>" 
```

For example:
- BSN: 000000012
- First Name: Pluk
- Last Name: Petteflet
- Day of Birth: 01
- Secret Hash Key: ZrHsI6MZmObcqrSkVpea

```shell
echo -n "000000012-Pluk-Petteflet-01" | openssl dgst -sha256 -hmac "ZrHsI6MZmObcqrSkVpea" 
```

Will return: `47a6c28642c05a30f48b191869126a808e31f7ebe87fd8dc867657d60d29d307` as the `identity-hash`


## JWT Tokens
In order to authenticate to the API endpoints mentioned below, each request will contain a JWT token. The contents of the JWT token is mentioned in the definition of the api endpoint.

All JWT tokens are signed by MinVWS using a public/private keypair in the 'RS256' format. The public key used by MVWS will provided on a public api endpoint.

Key rollover(s) will be published and communicated at least 2 weeks in advance. The provider should implement a key roll-over mechanism, so that if a new key is distributed, it will temporarily accept both keys, to account for users migrating over a short period of time.

The provider MUST validate the signature in the token. Only tokens signed by MinVWS should be considered by the api endpoint(s).

## Api Endpoints

This chapter explains the endpoints that a provider must implement.

### Information Available 

In order to determine if a person is present in the provider's system a hash is sent to the first endpoint. The identity-hash is included inside the JWT token provided in the `Authorization: Bearer <JWT Token>` header.

#### Request

In `cURL` the request looks as follows:
```
curl
  -X POST
  -H 'Authorization: Bearer <JWT TOKEN>'
  -H 'CoronaCheck-Protocol-Version: 3.0'
  -d '{ "filter": "vaccination" }'
  https://api.acme.inc/information
```

The `filter` is optional. If left out, the provider should check if they have either vaccination, test or recovery events for this user. Allowed values are: `vaccination`, `test` or `recovery`.

#### Response

The response (CMS Signed) should be provided as follows:
```javascript
{
    "protocolVersion": "3.0",
    "providerIdentifier": "XXX",
    "informationAvailable": true // true or false if information is available
}
```

#### JWT Token
The JWT token will contain the unencrypted `identity-hash`.

### Events Api
If the Information Available api returns `true` the app will follow up with a second request in order to get the actual vaccatination events. This time the JWT token will contain two items, the identity-hash and the actual BSN. The BSN inside the JWT token is encrypted.

#### Request

In `cURL` the request looks as follows:
```
curl
  -X POST
  -H 'Authorization: Bearer <JWT TOKEN>'
  -H 'CoronaCheck-Protocol-Version: 3.0'
  -d '{ "filter": "vaccination" }'
  https://api.acme.inc/events
```

#### Response

The response (CMS Signed) may contain multiple events. The response should be provided as follows:

```javascript
{
    "protocolVersion": "3.0",
    "providerIdentifier": "XXX",
    "status": "complete", // This refers to the data-completeness, not vaccination status.
    "holder": {
        "identityHash": "", // The identity-hash belonging to this person.
        "firstName": "",
        "lastName": "",
        "birthDate": "1970-01-01" // ISO 8601
    },
    "events": [
        {
            "type": "vaccination",
            "unique": "ee5afb32-3ef5-4fdf-94e3-e61b752dbed9",
            "vaccination": {
                // Vaccination record
            }
        },
        {
            "type": "test",
            "unique: "",
            "test": {
                // Test record
            }
        },
        {
            "recovery":
            "unique",
            "recovery: {
                // Recovery record
            }
        }
    ]    
}
```

For the details of the vaccination, test and recovery records, see the overview at https://github.com/minvws/nl-covid19-coronacheck-app-coordination/blob/main/docs/data-structures-overview.md

There are a few edge cases to consider:
* In case the person is known but events do not exist, the `events` array can be left empty.
* In case the person is known but the events are still processing, the `events` array can be left blank and the `status` field can be set to `pending`. The app will ask the user to try again later. This should be avoided though, the best user experience is if the events are immediately available and the 'information' call matches this state.

#### JWT Token
The JWT token will contain the BSN in an encrypted format. The encryption will be done using libsodium public/private sealboxes (X25519).

The private key that can be used to decrypt the token must remain with the provider at all times. The public key has to be provided to MinVWS.


## CMS Signature algorithm

We are using a CMS algorithm because this is widely available across a large variety of technologies. It is usable from the commandline using tools such as openssl. We may in the future provide libraries and/or off the shelf proxy containers to aid in developing an endpoint. Note however that although the CoronaCheck team may provide samples or ready to use software, the provider remains solely responsible for the test results that are handed out and remain the processor in the GDPR sense.

Note: Add all intermediate certificates to the CMS signature (in order to establish a trust chain).

The signature should use an appropriate signature algorithm and padding; conformant to the current, in-force SOG-IS (https://www.sogis.eu/uk/supporting_doc_en.html) standard. Note specifically that the default padding in OpenSSL (PCSK#1.5) is not considered secure.

The signing looks like this:

```
signature = CMS(PAYLOAD_JSONBYTES, x509cert)
```

The signature must be calculated over the raw json bytes from the response stream.

### Including the signature in the response

The signature and the payload must be wrapped inside a wrapper response. In earlier versions of this protocol we used a header to transmit the signature, but an CMS signature can exceed the maximum header size of some web servers / proxies.

The wrapper contains 2 fields:

* A base64 encoding of the signature, which contains the signature calculated in the previous chapter.
* A base64 encoded version of the (exact) payload.

For example:

```
HTTP/2 200 
date: Sat, 06 Feb 2021 08:52:00 GMT
content-type: application/json
content-length: 145
{
    "signature": "<base64 encoded version of the signature>",
    "payload": "<base64 encoded version of the payload>"
}
```

### Signature verification

The client app will perform the following actions when a signed response is received:

1. Base64-decode the payload to obtain the jsonbytes of the original response.
2. Base64-decode the signature
3. Check if the signature is valid for the jsonbytes of the payload
   4a. If yes: parse the jsonbytes and process the result
   4b. If no: refuse to use the json data and display an error

### Command line example

See appendix 1 for more detailed examples. To try out the algorighm on a Linux commandline, you could use:

```
    openssl cms -sign -outform DER \
                -out content.sig -content response.json \
                -signer mycrt.crt
             
```    

The resulting content.sig can be base64 encoded and placed in the cms-signature header.

The mycrt.crt is a X.509 certificate as issued to the sender by PKI-O. Full example in appendix 1.

### More sample code

More sample code for the signing method can be found in our [Github Sample Code repository](https://github.com/minvws/nl-covid19-coronacheck-tester-signature-demo)

## CORS headers

To be able to retrieve the result from a web browser (the web client for home printing), the following CORS headers should be present on the app token retrieval endpoint:

```
Access-Control-Allow-Origin: https://coronacheck.nl
Access-Control-Allow-Headers: Authorization, CoronaCheck-Protocol-Version, Content-Type
Access-Control-Allow-Methods: POST, GET, OPTIONS
```

For acceptance testing, the url is slightly different, so on acceptance test environments, the headers should be:

```
Access-Control-Allow-Origin: https://web.acc.coronacheck.nl
Access-Control-Allow-Headers: Authorization, CoronaCheck-Protocol-Version, Content-Type
Access-Control-Allow-Methods: POST, GET, OPTIONS
```

Notes:
* The app endpoint must respect the OPTIONS request (respond with 200 status code) that browsers will perform to check the headers. The OPTIONS request should have the same headers but no body.

## Changelog

1.1
* Generalized for id-hash based retrieval of vaccinations, recoveries and test results

1.0
* Initial version