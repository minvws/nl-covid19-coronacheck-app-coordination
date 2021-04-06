# CoronaCheck Prototype - Test Result Provisioning

Version 2.3.0

In the CoronaCheck project we are prototyping a means of presenting a digital proof of a negative test result. This document describes the steps a party needs to take to provide test results that the CoronaCheck app will use to provide proof of negative test.

## Contents

- [CoronaCheck Prototype - Test Result Provisioning](#coronacheck-prototype---test-result-provisioning)
  * [Overview](#overview)
  * [Requirements](#requirements)
  * [Distributing a test token](#distributing-a-test-token)
    + [Analog Code](#analog-code)
    + [QR Token](#qr-token)
    + [Deeplink](#deeplink)
    + [Token ownership verification](#token-ownership-verification)
  * [Exchanging the token for a test result](#exchanging-the-token-for-a-test-result)
    + [Request as received by the endpoint.](#request-as-received-by-the-endpoint)
    + [Returning a 'pending' state](#returning-a--pending--state)
      - [Poll tokens](#poll-tokens)
      - [Poll delay](#poll-delay)
    + [Requesting owner verification](#requesting-owner-verification)
    + [Returning a test result](#returning-a-test-result)
    + [Response payload for invalid/expired tokens](#response-payload-for-invalid-expired-tokens)
    + [Test result retention](#test-result-retention)
    + [Error states](#error-states)
  * [Initial normalization](#initial-normalization)
  * [Signing responses](#signing-responses)
    + [Obtaining a signing certificate](#obtaining-a-signing-certificate)
    + [Signature algorithm](#signature-algorithm)
    + [Including the signature in the response](#including-the-signature-in-the-response)
    + [Signature verification](#signature-verification)
    + [Command line example](#command-line-example)
    + [More sample code](#more-sample-code)
    + [Governance and the digital signature of the test result](#governance-and-the-digital-signature-of-the-test-result)
- [Security and privacy guidelines](#security-and-privacy-guidelines)
- [Appendix 1: Example implementations of X509 CMS signing](#appendix-1--example-implementations-of-x509-cms-signing)
- [Appendix 2: Validating the signing output](#appendix-2--validating-the-signing-output)
- [Appendix 3: OpenAPI specification of endpoint](#appendix-3--openapi-specification-of-endpoint)
- [Appendix 4: Available Test Types](#appendix-4--available-test-types)
- [Changelog](#changelog)

## Overview

The process is designed in such a way that privacy is perserved as much as possible, while preventing abuse of the system. Mitigating measures have been designed to prevent a wide range of attacks. 

The following diagram describes a high level overview of the result retrieval process:

### Retrieval from the CoronaCheck app

![High Level Overview](images/overview.png)

### Retrieval from print terminals

For persons who do now own a smartphone or a printer, we have designed a way to print a QR from a public print terminal. The process is similar to the app retrieval process, with a few changes:

![High Level Overview PT](images/overview-pt.png)

## Requirements

In order to be able to deliver test results for CoronaCheck, a test provider MUST do the following:

* Implement a mechanism to distribute a `token` in the form of a QR or `code` to the citizen that can be used to collect a negative result. 
* Provide two endpoints:
    * An endpoint that an app can use to retrieve a test result on behalf of the citizen, e.g. https://api.acme.inc/resultretrieval, according to the specs laid out in this document.
    * An endpoint that offers the retrieval of test results to print terminals, e.g. https://api.acme.inc/resultretrieval/print. 
* Obtain an x509 PKI-O certificate for CMS signing test results.
* CMS sign its test results and other responses using the x509 certificate.
* Add all intermediate certificates to the CMS signature (in order to establish a trust chain).
* Provide the public key of the CMS X509 certificate to the CoronaCheck system so that signed results can be verified against the certificate.
* Provide an additional public key for TLS/SSL pinning against their endpoint.
* Provide a privacy statement that the app can display before handing off a token to the endpoint.
* Require an out of band ownership verification of the test result if the test result is handed out in an unsupervised manner (see details in next chapter).

## Distributing a test token

After a user has taken a test, and the result is negative, the party should supply the user with a token. There are multiple ways to communicate the token to the user, and multiple steps in the process where this can take place, but it must be provided *after* the user's test result is determined to be negative.

For security reasons the token must be at least 10 characters long.

Our recommendation is to provide the token to the user in the form of a QR code. The CoronaTest app is designed to work with QR codes and provides the user the ability to scan a QR code containing their test token. We also provide support for manually entering the token - however due to the poor user experience we highly recommend that QR codes are provided, with the manual code / deeplink as fallback in case the user is viewing their result on the same device. 

### Analog Code

For manual entry, the token can be wrapped in a code that consists of the `providerIdentifer`, `token`, checksum, and code version. It should look like this:

```
XXX-YYYYYYYYYYYYY-ZV
```

Where:
* XXX is a 3-letter identifier that is unique to the test provider and assigned by CoronaCheck. It tells the app which endpoint to use, which keys etc.
* YYYYYYYYYYYYY is a token of arbitrary length. The token should be sufficiently large to protect against brute-force attacks, while remaining short enough to be able to perform manual entry. (see the Security Guidelines later in this document for additional guidelines.)
* Z is a checksum to help avoid typing mistakes and to put up a small barrier for the apps to only pass tokens to an endpoint if a sanity check is performed using the check digits. This helps avoid hits on your endpoint by presenting invalid tokens.
* V is the code version that tells the app how to interpret the code. It should currently always be 2.

To ensure the code can be provided orally to the user (e.g. by phone), and to allow the user to write down the code, only the following subset of 23 characters should be used to generate tokens:

```
BCFGJLQRSTUVXYZ23456789
```

This set is optimized to avoid confusion between visually similar characters, e.g. 0 (zero) vs O (letter), as well as orally similar sounding letters. 

The code ( prefix, token and checksum/version) matches the following regular expression pattern:

```
^[A-Z0-9]{3}-[A-Z0-9]+-[A-Z0-9]{1}[2-9]{1}$
```

The checksum is defined as the Luhn mod-N for alphanummerics; where the codepoints are as per the allowed set of characters ```BCFGJLQRSTUVXYZ23456789```; with the B assigned a 0 and the 9 the number 22.

Note that the version number (2) is at the end of the string; this is an anti-pattern; but conscious choise; these are to be human readable/entered strings that would look odd starting with (always the same) number. Also note that the 'XXX-' allows for a future 'Z-XXX-' or 'ZXXX-' type of start.

### QR Token

When providing the code through a QR code, the CoronaCheck App will be able to scan the token using the device's camera. The app will look for the following content:

```javascript
{
   "protocolVersion": "2.0",
   "providerIdentifier": "XXX",
   "token": "YYYYYYYYYYYYY",
}
```

The token should use the same character subset as the oral codes (as it's common to provide the manual code as an alternative to scanning the QR, in case the user sees the QR on the same device). 

### Deeplink

When providing the token via a website that the user can visit using the device where CoronaCheck is installed, the token can be directly loaded into the CoronaCheck app by utilizing the app's deeplink functionality. To use the deeplink, the token should be wrapped inside the same code that the manual entry uses (XXX-YYYYYYYYYY-ZV) The deeplink should be constructed as such:

```https://www.coronacheck.nl/app/redeem#XXX-YYYYYYYYYYYY-ZV```

If a user does not have the app installed, the URL will take the user to the CoronaCheck website, where they can find download links to download the app. If the user does have the app, this URL will automatically open the URL and fetch the test result using the token. 

Note the use of the ```#``` in the URL. By using an anchor the token is not leaked to the CoronaCheck website when the user does not have the app installed. 

### Token ownership verification

If the token can be securely transferred to the user (e.g. by scanning a QR code in the test facility right after having confirmed identity, under supervision of staff), it is not necessary to require ownership verification. In most circumstances however, ownership should be verified upon entering the test result. Ownership verification is performed by sending a 4-digit one time code to the user's phone per sms or per email, at the moment the user enters the token into the app. Although this doesn't guarantee for 100% that the result won't be passed to someone else, it now requires a deliberate act of fraud, instead of just 'handing over a voucher'. 

The process of providing a one time code sent via sms/e-mail is familiar to users who have used Two Factor Authentication mechanisms. It is important to note that the scheme documented in this this specification is not a true 2FA schema. In a true 2FA schema two distinct factors should be used, whereas in our case there is only one distinct factor - both the token and the verification code constitute 'something you have'. 

Verification codes must be numeric and 6 digits. 

## Exchanging the token for a test result

Once the token is scanned / read / entered in the app or terminal, CoronaCheck will try to fetch a test result.

The test provider should provide two endpoints that allows the user to collect this test result using the token provided in the previous step:
* The CoronaCheck end user app will fetch the result, using the token, directly from the test provider backend. This flow should include the verification step (using a verification code sent to the user's device) described earlier. 
* Print terminals will fetch the result, using the token, directly from the test provider backend too. However instead of a verification via sms, the terminal staff will ask the user voor proof of identity, and enter the birth month / day. This month/day will be provided to the endpoint and should be checked by the test provider.

Depending on where in the process the token was supplied, and depending on when the user enters it in their app, there can be 3 distinct responses:

* A result is not yet available (the request should be retried later)
* A result is available but requires verification (a verification code has been sent and should be retried with the code)
* A result is available (the negative test result is included in the response)

Both states will be detailed below.

### Request as received by the endpoint.

The detailed specification of the endpoint is provided in appendix 3.

The Authorization header will contain a Bearer token which consists of the `token` (YYYYYYYYYYYYY) part of the `code`.

In common CURL syntax it looks like this when the request comes from an *app*:

```
curl
  -X POST
  -H "Authorization: Bearer YYYYYYYYYYYYY"
  -H "CoronaCheck-Protocol-Version: 2.0"
  -d { "verificationCode": "12345"}
  https://test-provider-endpoint-base-url
```

The call will contain a body with a `verificationCode` obtained from the ownership verification process (see further down on verification details). If your facility employs supervised scanning of a QR and doesn't require ownership verification, the app will omit this body. 

When the request comes from a *terminal*, it looks like this:

```
curl
  -X POST
  -H "Authorization: Bearer YYYYYYYYYYYYY"
  -H "CoronaCheck-Protocol-Version: 2.0"
  -d { "birthMonth": "12", "birthDay": "24" }
  https://test-provider-endpoint-base-url-print
```

Notes:

* The useragent will be anonimized.
* HTTP POST is used instead of a GET to aid in preventing logging/caching of the token or code.
* The birthday and month are strings, not zero-padded (e.g. "4" and not "04"). There are IDs which have "X", "XX", "0" or "00" as value (for persons with no known birthdate). In this case, the terminal will always send "0". (The field in the terminal will use a numeric keyboard). 

### Returning a 'pending' state

A token must *only* be provided to users who have a negative test result. However, to accommodate a small set of providers who have a delay (caused by caching/batching) in publishing the result for consumption by the app, we support returning a 'pending' state. This indicates to the app that the result is not yet available, and the app should try again in the specified time frame. Note that this approach is *not recommended* as the user already knows they have a negative result, but are still unable to retrieve it. 

The HTTP response code is: 202

The response body would look like this (for both the app and terminal endpoints):

```javascript
{
    "protocolVersion": "2.0",
    "providerIdentifier": "XXX"
    "status": "pending",
    "pollToken": "...", // optional
    "pollDelay": 300, // seconds, optional
}
```

Where: 

* `protocolVersion` is the version of the protocol used. This helps the app interpret the QR correctly. This should match the version of the protocol implemented.
* `providerIdentifier` is the 3-letter identifier of the test provider, as supplied by the CoronaCheck team.
* `status`: Should be `pending` or `complete` (lowercase), to indicate that a result is included or not.
* `pollToken`: An optional token of max 50 characters to be used for the next attempt to retrieve the test result. If no pollToken is provided, the next attempt will use the original token provided by the user.
* `pollDelay`: An optional delay that tells the app the minimum number of seconds to wait before checking again. When present - the callee MUST adhere to this delay (to give the origin server thundering herd control). If the test process is sufficiently predictable, this can be used to indicate to the user when their result is expected. If no pollDelay is provided the app will try again a) after 5 minutes (if the app stays in the foreground), b) if the user opens the app from the background and more than the 'pollDelay' amount of seconds has passed or c) manually by means of a refresh button, pull to refresh or similar mechanism.

#### Poll tokens

The API provides support for poll tokens. If the user's test result is not known the first time your API is called, you can return a new, globally unique string (the "poll token"). The user's app will present this token the next time the service is called. By providing a new unique token for every request you make it harder for the user to attempt to load their test results into multiple telephones.

If the request provides a new pollToken in the response, then the previous `pollToken` should be kept around and valid, until the new one is seen in a request once. This ensures that when a request fails to retrieve the contents of the `pollToken`, it can retry with the previous one. Otherwise a test result could become unretrievable.

#### Poll delay

To protect backends, the minimum amount of time between requests is 5 minutes. Specifying a `pollDelay` shorter than 5 minutes will not be respected and treated as if it said 300. A longer `pollDelay` is of course acceptable.

Please note that the `pollDelay` is not guaranteed. Foreground/background activity might influence the actual time it takes between checks, and we may add a random factor for load distribution. 

### Requesting owner verification

If the testing party wants to tighten the binding between user and test result, ownership verification should be considered when a result is available and the result will be issued outside a supervised context. The server should issue a verification code to the user by ways of sms, phone or e-mail and should return a response that prompts the CoronaCheck app to ask for this validation number. 

To prompt the response, use HTTP response code: 401

The response body should look like this:

```javascript
{
    "protocolVersion": "2.0",
    "providerIdentifier": "XXX"
    "status": "verification_required",
}

```

The client can then repeat the request, but include the verificationCode body.

### Returning a test result

When a result is available, the http response code should be: 200

And the payload should look like this:

```javascript
{
    "protocolVersion": "2.0",
    "providerIdentifier": "XXX",
    "status": "complete",
    "result": {
        "sampleDate": "2020-10-10T10:00:00Z", // rounded to nearest hour
        "testType": "pcr", // See Appendix 4
        "negativeResult": true,
        "unique": "kjwSlZ5F6X2j8c12XmPx4fkhuewdBuEYmelDaRAi",
        "isSpecimen": true, // Optional
        "holder": {
            "firstNameInitial": "J", // Normalized
            "lastNameInitial": "D", // Normalized
            "birthDay": "31", // String, but no leading zero, e.g. "4"
            "birthMonth": "12" // String, but no leading zero, e.g. "4"
	}
    }
}
```

Where:

* `protocolVersion` indicates the version of this protocol that was used.
* `providerIdentifier`: the provider identifier as discussed earlier
* `status`: Either `pending` or `complete` (lowercase)
* `sampleDate`: The date/time on which the sample for the covid test was obtained (in ISO 8601 / RFC3339 UTC date+time format with Z suffix). Rounded to the nearest hour to avoid linkability to test facility visits.
* `testType`: The type of test that was used to obtain the result
* `negativeResult`: The presence of a negative result of the covid test. `true` when a negative result is present. `false` in all other situations.
* `unique`: An opaque string that is unique for this test result for this provider. An id for a test result could be used, or something that's derived/generated randomly. The signing service will use this unique id to ensure that it will only sign each test result once. (It is added to a simple strike list)
* `isSpecimen`: Boolean. When set to true, the verifier app will show a grey verification screen instead of a green one. To be used for testing and demo purposes.
* `holder`: A number of personally identifiable information fields that allow verification against an ID, without revealing a full identity. 
    * `firstNameInitial`: The first letter of the first name as specified on the person's ID. This must be (normalized)[#initial-normalization] according to a number of rules. 
    * `lastNameInitial`: The first letter of the last name as specified on the person's ID. Any middle names or Dutch 'tussenvoegsel' should be ignored, e.g. 'Joe van der Plank' has 'P' as lastNameInitial. Like the other initial, this should be normalized. 
    * `birthDay`: The non-zero-padded day of the month of a person's birthdate. We use a string because persons with unknown birthdays sometimes have an 'X' on their ID.
    * `birthMonth`: The non-zero-padded month of the birthdate.

Notes:
* We deliberately use `sampleDate` and not an expiry after x hours/minutes/seconds. This is because we anticipate that validity might depend on both epidemiological conditions as well as on where the test result is presented. E.g. a 2-day festival might require a longer validity than a short seminar; By including the sample date, verifiers can control how much data they really see.
* Returning `false` for the `negativeResult` does not necessarily imply 'positive'. This is data minimisation: it is not necessary for the app to know whether a person is positive, only that they have had a negative test result. A `false` in the `negativeResult` field could either indicate a positive test, or no test at all, etc.

### Response payload for invalid/expired tokens

Invalid or expired tokens should have the same response (this ensures that attempts to try tokens do not reveal whether they are invalid or expired). 

The http response code for an invalid token should be: 401

```javascript
{
    "protocolVersion": "2.0",
    "providerIdentifier": "XXX",
    "status": "invalid_token"
}

```

Note: both failed/expired tokens and missing `verificationCode` result in a 401 (as the request could be retried with the correct token/verificationCode). The app will distinguish between the 2 states by looking at the body.

### Performing terminal verification

The endpoint for terminals (which omits verification codes and uses birth month/day instead) should only be accessible to terminals. Terminals will use an SSL client certificate that can be verified when the call is made. The public certificate needed to perform this verification will be distributed when a test provider is configured into the CoronaCheck ecosystem.

### Token retention

A token should remain valid until 40 hours after the sample time of the underlying test result.

Even when a user has already retrieved their test result via a token, it should remain valid. A reason for this is that they need to confirm in the CoronaCheck app that this is indeed the correct result that should be converted to a QR. This process is cancelable by the user, and is not atomic (e.g. it could fail before a QR has been generated succesfully). To avoid the user ending up with neither a valid code nor a valid QR, the token should *not* be immediately removed after succesful retrieval. If the user cancels the operation and re-enters the code later, they can still retrieve their result. 

(The 40 hours is based on the validity of the proof of test: users who decide to load the result right before entering a venue, can still do so).

To avoid reuse of the code by multiple phones/users, the Signer Service will only sign each test result once, based on its `unique` field, so even if during the 40 hour window the user would retrieve the result multiple times, only once it can be converted to a signed test result in the signing service. 

### Error states

If an error occurs on the server, a proper 50x response should be returned. If such an error occurs, the CoronaCheck app will ask te user to try the request at a later time.

A response body may be provided for debugging purposes, but this is optional and the app will ignore it. (TODO: or do we want to include a message that we relay to the user?)

Avoid including details about your server implementation in the error body (e.g. no stack trace).

```javascript
{
    "message": "An internal server error occured."
}
```

## Initial normalization

The initials of first name and last name should be normalized according to the following rules:

* Tussenvoegsels / middle names should be ignored. E.g for `van Dam` the initial is D. 
* Accents/diacritics should be removed. E.g Ö becomes O, Ã becomes A, etc.
* If a name starts with a quotation mark, the quote should be skipped. E.g. for a person named `'Aouji` the initial is A
* Special case: if the name starts with a quote followed by a lowercase character and a hyphen, the first uppercase letter after the hyphen should be used. E.g for `'s-Gravezande` the initial is G. 
* The final initial should be uppercase. 
* After normalization the initial matches the regular expression [A-Z]

Rationale: characters outside the range A-Z are easier to link to an actual person because they are more rare (some combinations of initials could point only to a small number of individuals). 

## Signing responses

The app only accepts the responses if they are signed. This chapter describes the way the endpoint should sign the responses.

### Obtaining a signing certificate

Signatures should be created using a certificate from the so-called PKI-O private root. General information about PKI-O certificates can be found on [the Logius website](https://logius.nl/diensten/pkioverheid/aanvragen). 

To order a certificate you can make use of a TSP such as (in alphabetical order, without endorsing one over the other):

* Digidentity - [link to private certificate form](https://www.digidentity.eu/nl/certificates) (Note: at Digidentity a private certificate is called an SBR certificate)
* KPN - [link to private certificate form](https://certificaat.kpn.com/aanvragen/servercertificaten/private/)
* QuoVadis - [link to private certificate form](https://www.quovadissupport.nl/modules/PPSC/certificate?ts=1613133082&sc_lang=nl_nl)

(Note: the websites are maintained by their respective owners - the links may change) 

### Signature algorithm

We are using a CMS algorithm because this is widely available across a large variety of technologies. It is usable from the commandline using tools such as openssl. We may in the future provide libraries and/or off the shelf proxy containers to aid in developing an endpoint. Note however that although the CoronaCheck team may provide samples or ready to use software, the provider remains solely responsible for the test results that are handed out and remain the processor in the GDPR sense.

The signature should use an appropritate signature algorithm and padding; conformant to the current, in-force SOG-IS (https://www.sogis.eu/uk/supporting_doc_en.html) standard. Note specifically that the default padding in OpenSSL (PCSK#1.5) is not considered secure.

The signing looks like this:

```
signature = CMS(PAYLOAD_JSONBYTES, x509cert)
```

The signature must be calculated over the raw json bytes from the response stream.

### Including the signature in the response

The signature and the payload must be wrapped inside a wrapper response. In earlier versions of this document we used a header to transmit the signature, but an CMS signature can exceed the maximum header size of some web servers / proxies.

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

### Governance and the digital signature of the test result

Whenever a digital signature is placed - it is the signers responsibility to ensure that this signature is placed on the right data; and that they have taken appropriate steps to ensure it is not issued or distributed in error, twice or can be 'obtained' without sufficient controls.

It is the responsibility of the party fetching the data to ensure that it is connected to the right system (by means of certificate pinning and PKI-O certificate checks). 

And in B2B settings (such as the print terminals), the client may be required to provide a PKI-O client certificate to authenticate (and the provider must check validity of this certificate).

# Security and privacy guidelines

When providing endpoints for test retrieval, along with the general best practices regarding web application security, the following security and privacy guidelines should be followed:

* Do not include any personally identifiable data in responses.
* The app will not trust redirects. This means exact specification of endpoint urls, accurate to the point of trailing slashes and extensions. 
* The CMS signature should use an appropritate signature algorithm and padding; conformant to the current, in-force [SOG-IS](https://www.sogis.eu/uk/supporting_doc_en.html) standard.
* The unique identifier of the test result MUST NOT be linkable to an individual citizen, pseudonymization is required. 
* Tokens should have a lifetime of at maximum 40 hours after the sample time (see [token retention](#token-retention)
* Verification codes should have a limited lifetime of 5 minutes. 
* Properly secure endpoints against common attacks by implementing, for example, but not limited to, OWASP best practices.
* Properly secure endpoints against DDOS attacks. 
* Properly secure endpoints against brute force attacks, for example by accepting a maximum number of attempts to provide a verificationCode
* Do not log IP addresses for longer than necessary to perform normal opsec practices for preventing/combating abuse.
* Do not store IP addresses alongside test results or user data.
 
Note that this is not an extensive list and the provider is solely responsible for their own handling of the user's data according to its privacy policy.

# Appendix 1: Example implementations of X509 CMS signing

The directory 'shellscript' of https://github.com/minvws/nl-covid19-coronacheck-tester-signature-demo contains a script to generate such signatures ``sign.sh``:

    #!/bin/sh
    set -e

    if [ $# -gt 2 ]; then
	    echo "Syntax: $0 [example.json [client.crt]]"
    	exit 1
    fi
    
    JSON=${1:-example.json}
    CERT=${2:-client.crt}
    
    SIG_B64=$(openssl cms -in "$JSON" -sign \
    	-outform DER -signer "$CERT" -certfile chain.pem -binary | base64)

    JSON_B64=$(base64 "$JSON")
    cat <<EOM
    [
    	{
    		"payload": "$JSON_B64",
    		"signature": "$SIG_B64"
    	}
    ]
    EOM

along with the code needed to decode and verify this.

# Appendix 2: Validating the signing output

The directory 'shellscript' of https://github.com/minvws/nl-covid19-coronacheck-tester-signature-demo contains a script that can verify a signature and decode the json.

Its typical use is

      curl --silent 'https://api.FQDN.nl/something/config' | sh verify.sh        

when used against a PKI-Overheid.nl certificate; or 

      curl --silent 'https://api.FQDN.nl/something/config' | sh verify.sh self-signed.pem

when used against a self-signed test certificate.

# Appendix 3: OpenAPI specification of endpoint

Todo: swagger doc

# Appendix 4: Available Test Types

ID         | Name
-----------|--------
pcr        | PCR Test (Traditional)
pcr-lamp   | PCR Test (LAMP)

# Changelog

2.2.0

* Reduced ambiguity by requiring (instead of recommending) tokens to only use the 'orally optimized subset' of token characters.
* Be more explicit about the validity of tokens.
* Clarify that tokens must only be handed out to users whose test result is negative.
* Specified the requirements of verification codes (numeric and 6-digit). 

2.1.0

* Specify [token retention](#token-retention)
* Added table of contents
* Added ability to create specimen results

2.0.0

* Replaced birthday checksum with initials/birthday day/month

1.3.0
* Document the addition of intermediate certificates to the signature

1.2.2

* Fix Checksum calculation link

1.2.1 

* Updated app name

1.2.0

* Fixed discrepancy between image and text. Added Appendix 4 with available test types.
* Rename the `uniqueId` to `unique` to clearly mark it is not a database id.

1.1.0

* Added information on how to calculate the birthday checksum
* Added info on where to obtain a PKI-O certificate. 
* Added remark about not trusting redirects to security guidelines. 
* Added remark about verification code validity. 
* Fixed documentation where negativeResult=true seemed to mean positive. 
* Changed the signature packaging to accommodate test parties that have limits on the size of http headers
* Added unique identifier to test result (to be able to check that a test result will only be offered once to the signer service)

1.0.0

* Initial version


