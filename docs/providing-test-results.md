# CoronaTester Prototype - Test Result Provisioning

In the CoronaTester project we are prototyping a means of presenting a digital proof of a negative test result. This document describes the step a party needs to take to be able to provide test results that the CoronaTester app could use to provide proof of negative test.

## Overview

High level overview of the result retrieval process, as seen from the app on the user's device:

(TODO: DIAGRAM)

## Onboarding

In order to be able to deliver test results to the CoronaTester app, a test provider needs to enter into a dialog with the CoronaTester team and exchange the following information:

* The provider MUST implement a mechanism to distribute a 'token' to the citizen that can be used to collect a negative result. 
* The provider MUST provide an endpoint that an app can use to retrieve a test result on behalf of the citizen, e.g. https://api.acme.inc/resultretrieval, according to the specs laid out in this document.
* The provider MUST obtain an X509 PKI certificate (e.g. PKI-O) for signing test results
* The provider MUST CMS sign its test results and other responses using the certificate.
* The provider MUST provide the public key of the certificate to the CoronaTester system so that signed results can be verified against the certificate.
* The provider MAY provide an additional public key for SSL pinning against their endpoint.
* The provider SHOULD provide a privacy statement that the app can display before handing off a token to the endpoint

## Distributing a test 'token'

Somewhere in the test process, the party should supply the user with a token. This can either be during registration, while taking the test, or when delivering the results. 

The token should be presented in a way that the user can enter it in the app. Manual text entry is provided in the CoronaTester app, however to enhance security and avoid rogue retrieval, the token should be sufficiently large; providing the user with a QR code that the CoronaTester app can scan is considered more secure. It is however allowed to use both a token and a QR so the user can choose their desired method.

### Analog tokens

For manualy entry, the token should look like this:

```
XXX-YYYYYYYYYYYY-ZZV
```

Where:
* XXX is a 3-letter identifier that is unique to the test provider and assigned by CoronaTester. It tells the app which endpoint to use, which keys etc.
* YYYYYYYYYYYYY is a token of arbitrary length. The token should be sufficiently large to protect against brute-force attacks, while remaining short enough to be able to perform manual entry. (see the Security Guidelines later in this document for additional guidelines.)
* ZZ is a checksum to help avoid typing mistakes and to put up a small barrier for the apps to only pass tokens to an endpoint if a sanity check is performed using the check digits. (This helps avoid hits on your endpoint by presenting fake tokens. Note though that the algorithm to calculate the checksum is simplistic and not a guaranteed protection against abuse)
* V is the protocol version that tells the app how to interpret the token. It should currently always be 2. (we avoid 0 and 1 as they can be confusing characters) 

The CoronaTester app lets the user type any A-Z and 0-9 characters. If the token is provided orally to the user (e.g. by phone), we recommend to only use the following subset of characters:

```
TODO: 23-char subset from CM
```

This set is optimized to avoid confusion between visually similar characters, e.g. 0 (zero) vs O (letter), as well as orally similar sounding letters. 

### QR tokens

When providing the user with a QR code, the CoronaTester app can scan the token, if it adheres to the following content:

```javascript
{
   "protocolVersion": "1.0",
   "providerIdentifier": "XXX",
   "token": "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY",
}
```

## Providing an endpoint for test retrieval

The test provider should provide an endpoint that allows the user to collect their test result using the token provided in the previous step. Depending on where in the process the token was supplied, and depending on when the user enters it in their app, there can be 2 distinct states:

* A result is not yet available (pending)
* A result is available (complete)

Both states will be detailed below.



### Request

The detailed specification of the endpoint is provided in appendix 3. In common CURL syntax it looks like this:

```
CURL
  -X POST
  -H "Authorization: Bearer <token>"
  -H "CoronaTester-Protocol-Version: 1.0"
  https://test-provider-endpoint-base-url
```

The call will not provide a body. The useragent will be anonimized.

POST is used to aid in preventing logging/caching of the token

### Reply 

In all cases - the reply with be a zip file; with a JSON and a PKI-CMS signature in the files:

  unzip 
 		content.json
        content.sig

### PKI-CMS digital signature for the resulting content.

The content.sig contains a binary PKI CMS signature; e.g. as made by

        openssl cms -sign -outform DER \
             -out content.sig -content content.json \
             -signer mycrt.crt

Where mycrt.crt is a X.509 certificate as issued to the sender by PKI-O. Full example in appendix 5.

### Returning a 'pending' state

If the token is supplied and/or entered by the user BEFORE a test result is present, the endpoint must return a 'pending' state. This indicates to the app that the result is yet to be determined, and the app should try again in the specified time frame.

The result would look like this:

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

### Returning a test result

When a result is available, it must look like this:

```javascript
{
    "protocolVersion": "1.0",
    "providerIdentifier": "XXX",
    "status": "complete",
    "sampleDate": "2020-10-10T10:00:00Z", // rounded to nearest hour
    "testType": "pcr", // TODO: define valid range
    "result": "negative", // can be "negative" or "notnegative"
    "signature": "..."
}
```

Where:

* protocolVersion indicates the version of this protocol that was used.
* provideridentifier: the provider identifier as discussed earlier
* status: Either "pending" or "complete"
* sampleDate: The date/time on which the sample for the covid test was obtained. Rounded to the nearest hour to avoid linkability to test facility visits. Note that we deliberately use sampleDate and not an expiry after x hours/minutes/seconds. This is because we anticipate that validity might depend on both epidemiological conditions as well as on where the test result is presented. E.g. a 2-day festival might require a longer validity than a short seminar; By including the sample date, verifiers can control how much data they really see.
* testType: The type of test that was used to obtain the result
* result: The result of the covid test. Note that we deliberately use the term "notnegative" instead of "positive". This is for data minimisation: it is not necessary for the app to know wheter a person is positive, only negative. The status 'notnegative' could either indicate a positive test, or no test at all, etc.
* signature: the signatuer of the response.

## Signing responses

All responses should be signed. We are using a CMS algorythm because this is widely available across a large variety of technologies. It is usable from the commandline using tools such as openssl. We may in the future provide libraries and/or off the shelf proxy containers to aid in developing an endpoint. Note however that although the CoronaTester team may provide samples or ready to use software, the provider remains solely responsible for the test results that are handed out and remain the processor in the GDPR sense.

Todo: explain signing algo

Signatures on QR tokens: 

```
S = signing_algo(concat(providerIdentifier, token), x509)
```

On pending results:

```
S = signing_algo(concat(providerIdentifier, status, pollToken, pollDelay), x509)
```

Note that pollToken and  pollDelay are optional. If they are omited from the response, they should also be emited from the signature.

On completed results:

```
S = signing_algo(contact(providerIdentifier, result, sampleDate, testType), x509)
```

# Security and privacy guidelines

* A test result MUST NOT include any personally identifiable data
* The unique identifier of the test result should not be linkable to an individual citizen, pseudonymization is recommended
* Tokens should have a limited lifetime, to mitigate against longer brute-force attacks against the token space. This limited lifetime should be communicated to the user (e.g. 'please enter this code in the CoronaTester app before ....)
* The endpoint should be properly secured against common attacks by implementing, for example, but not limited to, OWASP best practices.
* The endpoint should be protected against DDOS attacks (e.g. throttling)
* IP addresses may not be logged longer than x (normal opsec practices for preventing/combating abuse are ok)
* The IP address of the user may not be stored alongside test results or other data.



# Appendix 1: Example implementations of X509 CMS signing

Todo: provide samples

# Appendix 2: Validating the signing output

Todo: provide an endpoint which can be used to check the outputs / signatures against.

# Appendix 3: OpenAPI specification of endpoint

Todo: swagger doc

# Appendix 4: 

# Appendix 5: PKI example


    #!/bin/sh
    set -e
    
    TMPDIR="${TMPDIR:-/tmp}"
    OUTDIR="${OUTDIR:-$TMPDIR/example.$$}"
    DIR=${PWD}
    
    if [ -e client.crt ]; then
        echo Using existing client.crt demo certificate
    else
        echo Generating a client.crt demo certificate
        openssl req -new -x509 -nodes \
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
		    "pollToken": "...", // optional
		    "pollDelay": 300, // seconds, optional
		}
		EOM

        cat content.json | openssl cms -sign \
        		-outform DER -out content.sig \
        		-signer "${DIR}/client.crt"
        rm -f "${DIR}/client.zip"
        zip a "${DIR}/client.zip" content.json content.sig

        cd "${DIR}"
        rm -rf "${OUTDIR}"
    ) || exit $?
    
    echo Grenerated a client.zip.
    exit 0


