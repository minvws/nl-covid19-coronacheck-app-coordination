# Error Handling in CoronaCheck apps

When an error occurs in the CoronaCheck Android, iOS or web apps (or one of the backends), we inform the user that something went wrong. To aid helpdesks and engineering teams in finding the cause of an error, we communicate an error code as part of the error dialog. The user can mention this code to the helpdesk. Using a coding system for errors helps identify errors and helps improve error reporting, as it is sometimes hard to get an accurate description of the error situation by the end user. 

To ensure we can properly identify where an issue is, each reported error code should:

* identify which situation it is (e.g. which feature, which backend call, etc)         
* what the error is

So that we can see from the code in which flow it happened, which api call it was, and why it happened.

## Error code standardization

Error codes displayed in an error dialog will be formatted like this:

`s xyy ppp? hhh bbbbbb (system flow.step provider errorcode detailederrorcode)`

### System

s identifies which system the user is operating.

* Android: A
* iOS: i
* Web: W

### Flow

x identifies in which main flow it happened (the number is assigned based on the order we added the feature to the app)

Holder:
* launch / startup flow: 0
* commercial test flow: 1
* vaccination flow: 2
* recovery flow: 3
* digid test flow: 4
* hkvi scan flow: 5

Verifier:
* launch / startup flow: 0

Print portal: 
* onboarding flow: 0
* commercial test flow: 1
* vaccination flow: 2
* recovery flow: 3
* digid test flow: 4

### Step

yy identifies the step/call (within the flow, in 2 digits with 10-step increments so that later other steps can be injected), e.g for the vaccination flow:

* tvs / digid: 10
* event_providers: 20
* access_tokens: 30
* unomi: 40
* event call: 50
* storing events: 60
* prepare issue call: 70
* signer call: 80
* storing credentials: 90

See [Appendix A](#appendix-a) for the currently known steps for all major flows.

### Provider identifier

ppp is the provider identifier ( 000 for non-provider specific errors)

### Error code

hhh is the http error code from the server (0xx for client side local errors)

### Error detail code

If available: bbbbbb is any code from the body of the server call, e.g. 999

## Examples

* `i 220 RVV 500 999111`  means: while retrieving a vaccination on iOS and doing a unomi call to RIVM, the server responded  with a 500 error and the body said it was 999111.
* `A 110 ABC 051` means: while retrieving a commercial code on Android and entering the code, for provider ABC, the Luhn check failed. (no detailed error code)

## Client side errors

For client side errors (0hh) there's a generic set that can happen with any api call. Where possible, these should be further broken down, e.g. if there are 2 ways an ssl pinning can fail, hen 010, 011 and 012 can be used).

* 00h - connection related failures
* 01h - ssl pinning failures
* 02h - cms signature failures
* 03h - json parse failures
* 04h - data validation failures
* ≥ 05h - flow specific failures (051 → luhn check failed etc)

See [Appendix B](#appendix-b) for client side error lists. 

# Appendix A

Known step lists

## Holder app

### Startup / Onboarding (flow 0)

* configuration: 10
* public keys: 20

### Commercial test (flow 1)

* test_providers: 20
* test result: 50
* storing events: 60
* prepare issue call: 70
* signer call: 80
* storing credentials: 90

### Vaccination (flow 2)

(voorzet, todo ios/android/web devs)

* tvs / digid: 10
* event_providers: 20
* access_tokens: 30
* unomi: 40
* event call: 50
* storing events: 60
* prepare issue call: 70
* signer call: 80
* storing credentials: 90

### Recovery (flow 3)

* tvs / digid: 10
* event_providers: 20
* access_tokens: 30
* unomi: 40
* event call: 50
* storing events: 60
* prepare issue call: 70
* signer call: 80
* storing credentials: 90

### Digid test results (flow 4)

* tvs / digid: 10
* event_providers: 20
* access_tokens: 30
* unomi: 40
* event call: 50
* storing events: 60
* prepare issue call: 70
* signer call: 80
* storing credentials: 90

### Paper scan (flow 5)

* coupling: 10
* storing events: 60
* prepare issue call: 70
* signer call: 80
* storing credentials: 90


## Verifier app

### Startup / Onboarding (flow 0)

* configuration: 10
* public keys: 20

### Scan flow (flow 1)

# Appendix B

Client side error lists

## 00h - connection related failures

voorzet, todo android/ios/web devs.

* 001: Unable to connect to host
* 002: Invalid hostname.. etc.
* 003: Invalid response
* 004: Timed out
* 005: Connection lost

## 01h - ssl pinning failures

* 010: ...

## 02h - cms signature failures

* 020: invalid signature

## 03h - json parse failures

* 030: Can not decode object from json
* 031: Can not encode object to json

## 04h - data validation failures

* 040: Malformed json string
* 041: Required field missing, etc..

## ≥ 05h - flow specific failures 

* 051: luhn check failed etc
* 052: can not convert paper DCC into event V3
* 053: can not base64 decode nonce
* 054: can not create commitment message
* 055: error saving greenCards / origins / credentials
* 056: error saving events
* 057: failed to initialize the Go crypto library

## 06h - SQL failures
 
* 060: Integrity constraint violation

## 07h - TVS/DigiD failures

* 070: General errors
    * 070-0: Invalid discovery document
    * 070-1: User cancelled flow
    * 070-2: Flow cancelled programmatically
    * 070-3: Network error
    * 070-4: Server error
    * 070-5: JSON deserialization error
    * 070-6: Token response construction error
    * 070-7: Invalid registration response
    * 070-8: Unable to parse ID Token
    * 070-9: Invalid ID Token
    * 070-10: Safari open 
    * 070-11: Browser open
    * 070-12: Token refresh
    * 070-13: JSON serialization error
* 071: OAuth authorization errors
    * 071-1000: invalid_request
    * 071-1001: unauthorized_client
    * 071-1002: access_denied
    * 071-1003: unsupported_response_type
    * 071-1004: invalid_scope
    * 071-1005: server_error
    * 071-1006: temporarily_unavailable
    * 071-1007: Client error
    * 071-1008: Unknown error
* 072: OAuth token errors
    * 072-2000: invalid_request
    * 072-2001: invalid_client
    * 072-2002: invalid_grant
    * 072-2003: unauthorized_client
    * 072-2004: unsupported_grant_type
    * 072-2005: invalid_scope
    * 072-2006: Client error
    * 072-2007: Unknown error
* 073: Resource server authorization errors
* 074: OAuth errors on registration endpoint
    * 074-4000: invalid_request
    * 074-4001: invalid_redirect_uri
    * 074-4002: invalid_client_metadata
    * 074-4003: Client error
    * 074-4004: Unknown error
