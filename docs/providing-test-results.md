# CoronaTester Prototype - Test Result Provisioning

In the CoronaTester project we are prototyping a means of presenting a digital proof of a negative test result. This document describes the steps a party needs to take to provide test results that the CoronaTester app will use to provide proof of negative test.

## Overview

The process is designed in such a way that privacy is perserved as much as possible, while preventing abuse of the system. Mitigating measures have been designed to prevent a wide range of attacks. 

The following diagram describes a high level overview of the result retrieval process:

![High Level Overview](images/overview.png)


## Requirements

In order to be able to deliver test results to the CoronaTester app, a test provider MUST do the following:

* Implement a mechanism to distribute a 'token' to the citizen that can be used to collect a negative result. 
* Provide an endpoint that an app can use to retrieve a test result on behalf of the citizen, e.g. https://api.acme.inc/resultretrieval, according to the specs laid out in this document.
* Obtain an x509 PKI certificate (e.g. PKI-O) for signing test results.
* CMS sign its test results and other responses using the x509 certificate.
* Provide the public key of the certificate to the CoronaTester system so that signed results can be verified against the certificate.
* Provide an additional public key for SSL pinning against their endpoint.
* Provide a privacy statement that the app can display before handing off a token to the endpoint.

and can optionally:

* Require an out of band ownership verification of the test result if the test result is handed out in an unsupervised manner (see details in next chapter).

## Distributing a test token

Somewhere in the test process, the party should supply the user with a token. This can either be during registration, while taking the test, or when delivering the results.

For security reasons the token must be at least [TODO INSERT SIZE AND UNITS] long.

Our recommendation is to provide the token to the user in the form of a QR code. The CoronaTest app is designed to work with QR codes and provides the user the ability to scan a QR code containing their test token. We also provide support for manually entering the token - however due to the poor user experience we highly recommend that QR codes are provided. It is of course possible to use both a manual token and a QR so the user can choose their desired method.

### Analog tokens

For manual entry, the token should look like this:

```
XXX-YYYYYYYYYYYY-ZV
```

Where:
* XXX is a 3-letter identifier that is unique to the test provider and assigned by CoronaTester. It tells the app which endpoint to use, which keys etc.
* YYYYYYYYYYYYY is a token of arbitrary length. The token should be sufficiently large to protect against brute-force attacks, while remaining short enough to be able to perform manual entry. (see the Security Guidelines later in this document for additional guidelines.)
* Z is a checksum (TODO: define checksum algo) to help avoid typing mistakes and to put up a small barrier for the apps to only pass tokens to an endpoint if a sanity check is performed using the check digits. This helps avoid hits on your endpoint by presenting invalid tokens.
* V is the token version that tells the app how to interpret the token. It should currently always be 2.

The CoronaTester app lets the user type any alphanumeric characters from the following set:

```
ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
```

If the token is provided orally to the user (e.g. by phone), we recommend to only use the following subset of 23 characters:

```
BCFGJLQRSTUVXYZ23456789
```

This set is optimized to avoid confusion between visually similar characters, e.g. 0 (zero) vs O (letter), as well as orally similar sounding letters. 

The token matches the following regular expression pattern:

```
^[A-Z0-9]{3}-[A-Z0-9]+-[A-Z0-9]{1}[2-9]{1}$
```

### QR tokens

When providing the token through a QR code, the CoronaTester app can scan the token if it adheres to the following content:

```javascript
{
   "protocolVersion": "1.0",
   "providerIdentifier": "XXX",
   "token": "YYYYYYYYYYYYYYYY",
}
```

[Ivo: maybe we should define a charset here too? This is the same as above but with `+`, `/` and `=` added so base64 is acceptable]

The token must match the following regular expression pattern:

```
^[a-zA-Z0-9=\+\/]+$
```

### Token ownership verification

If the token can be securely transfered to the user (e.g. by scanning a QR code in the test facility right after having confirmed identity, under supervision of staff), it is not necesarry to require ownership verification. In most circumstances however, ownership should be verified upon entering the test result. Ownership verification is performed by sending a 4-digit one time code to the user's phone per sms or per email, at the moment the user enters the token into the app. Although this doesn't guarantee for 100% that the result won't be passed to someone else, it now requires a deliberate act of fraud, instead of just 'handing over a voucher'. 

The process of providing a one time code sent via sms/e-mail is familiar to users who have used Two Factor Authentication mechanisms. It is important to note that the scheme documented in this this specification is not a true 2FA schema. In a true 2FA schema two distinct factors should be used, whereas in our case there is only one distinct factor - both the token and the verification code constitute 'something you have'. 

## Exchanging the token for a test result

Once scanned / read in the app, CoronaTester will try to fetch a test result.

The test provider should provide an endpoint that allows the user to collect this test result using the token provided in the previous step. Depending on where in the process the token was supplied, and depending on when the user enters it in their app, there can be 3 distinct responses:

* A result is not yet available (the request should be retried later)
* A result is available but requires verification (a verifiation code has been sent and should be retried with the code)
* A result is available (the negative test result is included in the response)

Both states will be detailed below.

### Request as received by the endpoint.

The detailed specification of the endpoint is provided in appendix 3. In common CURL syntax it looks like this:

```
CURL
  -X POST
  -H "Authorization: Bearer <token>"
  -H "CoronaTester-Protocol-Version: 1.0"
  -d { "verificationCode": "12345"}
  https://test-provider-endpoint-base-url
```

The call will contain a body with a `verificationCode` obtained from the ownership verification process (see further down on verification details). If your facility employs supervised scanning of a QR and doesn't require ownership verification, the app will omit this body. 

Notes:

* The useragent will be anonimized.
* HTTP POST is used instead of a GET to aid in preventing logging/caching of the token.

### Returning a 'pending' state

If the token is supplied and/or entered by the user BEFORE a test result is present, the endpoint must return a 'pending' state. This indicates to the app that the result is yet to be determined, and the app should try again in the specified time frame.

The HTTP response code is: 202

The response body would look like this:

```javascript
{
    "protocolVersion": "1.0",
    "providerIdentifier": "XXX"
    "status": "pending",
    "pollToken": "...", // optional
    "pollDelay": 300, // seconds, optional
}
```

Where: 

* `protocolVersion` is the version of the protocol used. This helps the app interpret the QR correctly. This should currently always be `1.0`.
* `providerIdentifier` is the 3-letter identifier of the test provider, as supplied by the CoronaTester team.
* `status`: Should be `pending` or `complete`, to indicate that a result is included or not.
* `pollToken`: An optional token of max 50 characters to be used for the next attempt to retrieve the test result. If no pollToken is provided, the next attempt will use the original token provided by the user.
* `pollDelay`: An optional delay that tells the app the minimum number of seconds to wait before checking again. If the test process is sufficiently predictable, this can be used to indicate to the user when their result is expected. If no pollDelay is provided the app will try again a) after 5 minutes (if the app stays in the foreground), b) if the user opens the app from the background and more than the 'pollDelay' amount of seconds has passed or c) manually by means of a refresh button, pull to refresh or similar mechanism.
* `signature`: the CMS signature signed with the X509 certificate

#### Poll tokens

The API provides support for poll tokens. If the user's test result is not known the first time your API is called, you can return a new, globally unique string (the "poll token"). The user's app will present this token the next time the service is called. By providing a new unique token for every request you make it harder for the user to attempt to load their test results into multiple telephones.

If the request provides a new pollToken in the response, then the previous `pollToken` should be kept around and valid, until the new one is seen in a request once. This ensures that when a request fails to retrieve the contents of the `pollToken`, it can retry with the previous one. Otherwise a test result could become unretrievable.

#### Poll delay

To protect backends, the minimum amount of time between requests is 5 minutes. Specifying a `pollDelay` shorter than 5 minutes will not be respected and treated as if it said 300. A longer `pollDelay` is of course acceptable.

Please note that the `pollDelay` is not guaranteed. Foreground/background activity might influence the actual time it takes between checks, and we may add a random factor for load distribution. 

### Requesting owner verification

If the testing party wants to tighten the binding between user and test result, ownership verification should be considered when a result is available and the result will be issued outside a supervised context. The server should issue a verification code to the user by ways of sms, phone or e-mail and should return a response that prompts the CoronaTester app to ask for this validation number.

To prompt the response, use HTTP responsecode: 401

The response body should look like this:

```javascript
{
    "protocolVersion": "1.0",
    "providerIdentifier": "XXX"
    "status": "verification_required",
}

```

The client can then repeat the request, but include the verificationCode body.

### Returning a test result

When a result is available, the http response code should be: 200

And the response should look like this:

```javascript
{
    "protocolVersion": "1.0",
    "providerIdentifier": "XXX",
    "status": "complete",
    "result": {
        "sampleDate": "2020-10-10T10:00:00Z", // rounded to nearest hour
        "testType": "pcr", // TODO: define valid range
        "negativeResult": true,
        "signature": "..." // TODO: finalize 'signature' field vs 'sign entire json and package as zip' discussion
    }
}
```

Where:

* `protocolVersion` indicates the version of this protocol that was used.
* `providerIdentifier`: the provider identifier as discussed earlier
* `status`: Either `pending` or `complete`
* `sampleDate`: The date/time on which the sample for the covid test was obtained (in ISO 8601 / RFC3339 UTC date+time format with Z suffix). Rounded to the nearest hour to avoid linkability to test facility visits.
* `testType`: The type of test that was used to obtain the result
* `negativeResult`: The presence of a negative result of the covid test. `false` when a negative result is present. `true` in all other situations.
* `signature`: the signature of the response.

Notes:
* We deliberately use `sampleDate` and not an expiry after x hours/minutes/seconds. This is because we anticipate that validity might depend on both epidemiological conditions as well as on where the test result is presented. E.g. a 2-day festival might require a longer validity than a short seminar; By including the sample date, verifiers can control how much data they really see.
* Returning `false` for the `negativeResult` does not necessarily imply 'positive'. This is data minimisation: it is not necessary for the app to know whether a person is positive, only that they have had a negative test result. A `true` in the `negativeResult` field could either indicate a positive test, or no test at all, etc.

### Response for invalid/expired tokens

Invalid or expired tokens should have the same response (this ensures that attempts to try tokens do not reveal whether they are invalid or expired). 

The http response code for an invalid token should be: 401

```javascript
{
    "protocolVersion": "1.0",
    "providerIdentifier": "XXX"
    "status": "invalid_token",
}

```

Note: both failed/expired tokens and missing `verificationCode` result in a 401 (as the request could be retried with the correct token/verificationCode). The app will distinguish between the 2 states by looking at the body.

### Error states

If an error occurs on the server, a proper 50x response should be returned. If such an error occurs, the CoronaTester app will ask te user to try the request at a later time.

A response body may be provided for debugging purposes, but this is optional and the app will ignore it. (TODO: or do we want to include a message that we relay to the user?)

Avoid including details about your server implementation in the error body (e.g. no stack trace).

```javascript
{
    "message": "An internal server error occured."
}

````

## Signing responses

The app only accepts the responses if they are signed. This chapter describes the way the endpoint should sign the responses.

### Signature algorithm

We are using a CMS algorithm because this is widely available across a large variety of technologies. It is usable from the commandline using tools such as openssl. We may in the future provide libraries and/or off the shelf proxy containers to aid in developing an endpoint. Note however that although the CoronaTester team may provide samples or ready to use software, the provider remains solely responsible for the test results that are handed out and remain the processor in the GDPR sense.

The signing looks like this:

```
signature = BASE64(CMS(JSONBYTES, x509cert))
```

The signature must be calculated over the raw json bytes from the response stream.

### Including the signature in the response

The signature must be returned in a response header named `cms-signature`. Since the signature is calculated over the bytes contained in the response body it is impossible to include the signature itself in the body.

For example, this could looke like this:

```
HTTP/2 200 
date: Sat, 06 Feb 2021 08:52:00 GMT
content-type: application/json
content-length: 145
cms-signature: dGhpcyBpcyBhIHRlc3Qgc2lnbmF0dXJlIHRoaXMgaXMgYSB0ZXN0IHNpZ25hdHVyZSB0aGlzIGlzIGEgdGVzdCBzaWduYXR1cmU=
{
    "protocolVersion": 1.0,
    // etc
}
```

### Command line example

See appendix 1 for more detailed examples. To try out the algorighm on a Linux commandline, you could use:

```
    openssl cms -sign -outform DER \
                -out content.sig -content response.json \
                -signer mycrt.crt
             
```    

The resulting content.sig can be base64 encoded and placed in the cms-signature header.         

The mycrt.crt is a X.509 certificate as issued to the sender by PKI-O. Full example in appendix 1.

### Governance and the digital signature of the test result

Whenever a digital signature is placed - it is the signers responsibility to ensure that this signature is placed on the right data; and that they have taken appropriate steps to ensure it is not issued or distributed in error, twice or can be 'obtained' without sufficient controls.

It is the responsibility of the party fetching the data to ensure that it is connected to the right system (by means of certificate pinning and PKI-O certificate checks). 

And in B2B settings, the client may be required to provide a PKI-O client certificate to authenticate.


# Security and privacy guidelines

When providing endpoints for test retrieval, along with the general best practices regarding web application security, the following security and privacy guidelines should be followed:

* Do not include any personally identifiable data in responses.
* The unique identifier of the test result MUST NOT be linkable to an individual citizen, pseudonymization is required
* Tokens should have a limited lifetime, to mitigate against longer brute-force attacks against the token space. This limited lifetime should be communicated to the user (e.g. 'please enter this code in the CoronaTester app before ....)
* Properly secure endpoints against common attacks by implementing, for example, but not limited to, OWASP best practices.
* Properly secure endpoints against DDOS attacks 
* Properly secure endpoints against brute force attacks, for example by accepting a maximum number of attempts to provide a verificationCode
* Do not log IP addresses for longer than necessary to perform normal opsec practices for preventing/combating abuse.
* Do not store IP addresses alongside test results or user data.

Note that this is not an extensive list and the provider is solely responsible for their own handling of the user's data according to its privacy policy.

# Appendix 1: Example implementations of X509 CMS signing

## Command line example

The following works on most Linux environments. Note that for this example to work on MacOS, you need an openssl binary with cms support compiled in (the default openssl shipped with macos does not include cms).


```
    #!/bin/sh
    set -e
    
    TMPDIR="${TMPDIR:-/tmp}"
    OUTDIR="${OUTDIR:-$TMPDIR/example.$$}"
    DIR=${PWD}
    
    if [ -e client.crt ]; then
        echo Using existing client.crt demo certificate
    else
        echo Generating a client.crt demo certificate
             req -new -x509 -nodes \
        	-out client.crt -keyout client.crt \
        	-subj /CN=Client/O=Example/C=NL 
    fi
    
    mkdir -p "${OUTDIR}"
    (
        cd "${OUTDIR}"
        cat > content.json <<EOM
		{
	    	"protocolVersion": "1.0",
		    "providerIdentifier": "XXX"
		    "status": "pending",
		    "pollToken": "...", 
		    "pollDelay": 300
		}
		EOM

        cat content.json | openssl cms -sign \
        		-outform DER -out content.sig \
        		-signer "${DIR}/client.crt"
        
        cd "${DIR}"
        rm -rf "${OUTDIR}"
    ) || exit $?
    
    echo Generated a signature.
    exit 0
```

# Appendix 2: Validating the signing output

Todo: provide an endpoint which can be used to check the outputs / signatures against.

# Appendix 3: OpenAPI specification of endpoint

Todo: swagger doc


