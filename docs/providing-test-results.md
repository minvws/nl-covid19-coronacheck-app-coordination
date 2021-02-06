# CoronaTester Prototype - Test Result Provisioning

In the CoronaTester project we are prototyping a means of presenting a digital proof of a negative test result. This document describes the step a party needs to take to be able to provide test results that the CoronaTester app could use to provide proof of negative test.

## Overview

The process is designed in such a way that privacy is perserved as much as possible, while preventing abuse of the system. Mitigating measures have been designed to prevent a wide range of attacks. 

The following diagram describes a high level overview of the result retrieval process:

![High Level Overview](images/overview.png)


## Requirements

In order to be able to deliver test results to the CoronaTester app, a test provider needs to provide the following:

* The provider MUST implement a mechanism to distribute a 'token' to the citizen that can be used to collect a negative result. 
* The provider MUST provide an endpoint that an app can use to retrieve a test result on behalf of the citizen, e.g. https://api.acme.inc/resultretrieval, according to the specs laid out in this document.
* The provider MUST obtain an X509 PKI certificate (e.g. PKI-O) for signing test results
* The provider MUST CMS sign its test results and other responses using the certificate.
* The provider MUST provide the public key of the certificate to the CoronaTester system so that signed results can be verified against the certificate.
* The provider MAY provide an additional public key for SSL pinning against their endpoint (if not provided, the endpoint MUST use the same certificate both for pinning and signing).
* The provider MUST provide a privacy statement that the app can display before handing off a token to the endpoint
* The provider SHOULD require an out of band ownership verification of the test result if the test result is handed out in an unsupervised manner (see details in next chapter).

## Distributing a test token

Somewhere in the test process, the party should supply the user with a token. This can either be during registration, while taking the test, or when delivering the results. 

The token should be presented in a way that the user can enter it in the app. Manual text entry is provided in the CoronaTester app, however to enhance security and avoid rogue retrieval, the token should be sufficiently large; providing the user with a QR code that the CoronaTester app can scan is considered more secure. It is possible to use both a manual token and a QR so the user can choose their desired method.

### Analog tokens

For manualy entry, the token should look like this:

```
XXX-YYYYYYYYYYYY-ZV
```

Where:
* XXX is a 3-letter identifier that is unique to the test provider and assigned by CoronaTester. It tells the app which endpoint to use, which keys etc.
* YYYYYYYYYYYYY is a token of arbitrary length. The token should be sufficiently large to protect against brute-force attacks, while remaining short enough to be able to perform manual entry. (see the Security Guidelines later in this document for additional guidelines.)
* Z is a checksum (TODO: define checksum algo) to help avoid typing mistakes and to put up a small barrier for the apps to only pass tokens to an endpoint if a sanity check is performed using the check digits. (This helps avoid hits on your endpoint by presenting fake tokens. Note though that the algorithm to calculate the checksum is simplistic and not a guaranteed protection against abuse)
* V is the protocol version that tells the app how to interpret the token. It should currently always be 2. (we avoid 0 and 1 as they can be confusing characters) 

The CoronaTester app lets the user type any A-Z and 0-9 characters. If the token is provided orally to the user (e.g. by phone), we recommend to only use the following subset of 23 characters:

```
BCFGJLQRSTUVXYZ23456789
```

This set is optimized to avoid confusion between visually similar characters, e.g. 0 (zero) vs O (letter), as well as orally similar sounding letters. 

### QR tokens

When providing the token through a QR code, the CoronaTester app can scan the token if it adheres to the following content:

```javascript
{
   "protocolVersion": "1.0",
   "providerIdentifier": "XXX",
   "token": "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY",
}
```

### Token ownership verification

If the token can be securely transfered to the user (e.g. by scanning a QR code in the test facility right after having confirmed identity, under supervision of staff), it is not necesarry to require ownership verification. In most circumstances however, ownership should be verified upon entering the test result. Ownership verification is performed by sending a 4-digit one time code to the user's phone per sms or per email, at the moment the user enters the token into the app. Although this doesn't guarantee for 100% that the result won't be passed to someone else, it now requires a deliberate act of fraud, instead of just 'handing over a voucher'. 

The process of providing a one time code sent via sms/e-mail is familiar to users who have used Two Factor Authentication mechanisms. (Note: it's not called '2FA' in this specification since in true 2FA two distinct factors should be used, whereas in our case both the token and the verification code constitute 'something you have'). 

## Exchanging the token for a test result

Once scanned / read in the app, the CoronaTester app will try to fetch a test result.

The test provider should provide an endpoint that allows the user to collect this test result, using the token provided in the previous step. Depending on where in the process the token was supplied, and depending on when the user enters it in their app, there can be 3 distinct responses:

* A result is not yet available (the request should be tried later)
* A result is available but requires verification (a verifiation code has been sent and should be tried again with the code)
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

The call will contain a body with a verificationCode obtained from the ownership verification process (see further down on verification details). If your facility employs supervised scanning of a QR and doesn't require ownership verification, the app will omit this body. 

Note: The useragent will be anonimized.

POST is used to aid in preventing logging/caching of the token.


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

* protocolVersion is the version of the protocol used. This helps the app interpret the QR correctly. This should currently always be 1.0
* providerIdentifier is the 3-letter identifier or the test provider, as supplied by the CoronaTester team.
* status: Should be "pending" or "complete" to indicate that a result is included or not.
* pollToken: An optional token to use for the next attempt to retrieve the test result. If no pollToken is provided, the next attempt will use the original token provided by the user. This is a great way to exchange a smaller, orally optimized, token that he user would have entered, by a longer token that provides more security.
* pollDelay: An optional delay that tells the app when to check again. If the test process is sufficiently predictable, this can be used to indicate to the user when their result is expected. If no pollDelay is provided the app will try again a) after 5 minutes (if the app stays in the foreground), b) if the user opens the app from the background and more than the 'pollDelay' amount of seconds has passed or c) manually by means of a regresh button, pull to refresh or similar mechanism.
* signature: the CMS signature signed with the X509 certificate

Note that the pollDelay is not guaranteed. Foreground/background activity might influence the actual time it takes between checks. 

To protect backends, the minimum amount of time between requests is 5 minutes. Specifying a pollDelay shorter than 5 minutes will not be respected and treated as if it said 300. A longer pollDelay is of course acceptable.


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

````

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

* protocolVersion indicates the version of this protocol that was used.
* provideridentifier: the provider identifier as discussed earlier
* status: Either "pending" or "complete"
* sampleDate: The date/time on which the sample for the covid test was obtained (in ISO 8601 / RFC3339 UTC date+time format with Z suffix). Rounded to the nearest hour to avoid linkability to test facility visits. Note that we deliberately use sampleDate and not an expiry after x hours/minutes/seconds. This is because we anticipate that validity might depend on both epidemiological conditions as well as on where the test result is presented. E.g. a 2-day festival might require a longer validity than a short seminar; By including the sample date, verifiers can control how much data they really see.
* testType: The type of test that was used to obtain the result
* negativeResult: The presence of a negative result of the covid test. Note that false does not necessarily imply 'positive'. This is data minimisation: it is not necessary for the app to know wheter a person is positive, only negative. A true value in the negativeResult field could either indicate a positive test, or no test at all, etc.
* signature: the signatuer of the response.


## Signing responses

The app only accepts the responses if they are signed. This chapter describes the way the endpoint should sign the responses.

### Signature algorithm

We are using a CMS algorithm because this is widely available across a large variety of technologies. It is usable from the commandline using tools such as openssl. We may in the future provide libraries and/or off the shelf proxy containers to aid in developing an endpoint. Note however that although the CoronaTester team may provide samples or ready to use software, the provider remains solely responsible for the test results that are handed out and remain the processor in the GDPR sense.

The signing looks like this:

```
signature = BASE64(CMS(JSONBYTES, x509cert))
```

The signature should use the raw json bytes from the response

### Including the signature in the response

Since we sign the entire JSON body, the signature itself can't be part of the response body, to avoid signature-inception. Therefor the signature should be included as a response header named 'cms-signature'. For example, this could looke like this:

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

See the appendix for more detailed example, but to try out the algorighm on the commandline, it would be:

```
    openssl cms -sign -outform DER \
                -out content.sig -content response.json \
                -signer mycrt.crt
             
```    

The resulting content.sig can be base64 encoded and placed in the cms-signature header.         

The mycrt.crt is a X.509 certificate as issued to the sender by PKI-O. Full example in appendix 5.

### Governance and the digital signature of the test result

Whenever a digital signature is placed - it is the signers responsibility to ensure that this signature is placed on the right data; and that they have taken appropriate steps to ensure it is not issued or distributed in error, twice or can be 'obtained' without sufficient controls.

It is the responsibility of the party fetching the data to ensure that it is connected to the right system (by means of certificate pinning and PKI-O certificate checks). 

And in B2B settings, the client may be required to provide a PKI-O client certificate to authenticate.


# Security and privacy guidelines

When providing endpoints for test retrieval, along with the general best practices regarding web application security, the following security and privacy guidelines should be followed:

* Do not include any personally identifiable data in responses.
* The unique identifier of the test result should not be linkable to an individual citizen, pseudonymization is recommended
* Tokens should have a limited lifetime, to mitigate against longer brute-force attacks against the token space. This limited lifetime should be communicated to the user (e.g. 'please enter this code in the CoronaTester app before ....)
* Properly secure endpoints against common attacks by implementing, for example, but not limited to, OWASP best practices.
* Properly secure endpoints against DDOS attacks 
* Properly secure endpoints against brute force attacks, for example by accepting a maximum number of attempts to provide a verificationCode
* Do not log IP addresses for longer than necessary to perform normal opsec practices for preventing/combating abuse.
* DO not store IP addresses alongside test results or user data.

Note that this is not an extensive list and the provider is solely responsible for their own handling of the user's data according to its privacy policy.

# Appendix 1: Example implementations of X509 CMS signing

Todo: provide samples

# Appendix 2: Validating the signing output

Todo: provide an endpoint which can be used to check the outputs / signatures against.

# Appendix 3: OpenAPI specification of endpoint

Todo: swagger doc

# Appendix 4: 

# Appendix 5: PKI example


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
		    "pollDelay": 300, 
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

