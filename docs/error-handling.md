# Error Handling in CoronaCheck apps

When an error occurs in the CoronaCheck apps (or one of the backends), we inform the user that something went wrong. To aid helpdesks and engineering teams in finding the cause of an error, we communicate an error code as part of the error dialog. The user can mention this code to the helpdesk. Using a coding system for errors helps identify errors and helps improve error reporting, as it is sometimes hard to get an accurate description of the error situation by the end user. 

To ensure we can properly identify where an issue is, each reported error code should:

a) identify which situation it is (e.g. which feature, which backend call, etc)         
b) what the error is

So that we can see from the code in which flow it happened, which api call it was, and why it happened.

## Error code standardization

Error codes displayed in an error dialog will be formatted like this:

`xyy/ppp/hhh/bbbbbb (flow.step/provider/errorcode/detailederrorcode)`

### Flow

x identifies in which main flow it happened (the number is assigned based on the order we added the feature to the app)

Holder:
* onboarding/startup flow is 0
* commercial test flow is 1
* vaccination flow is 2
* recovery flow is 3
* digid test flow is 4
* hkvi scan flow is 5

Verifier:
* onboarding/startup flow is 0
* scan flow is 1

### Step

yy identifies the step/call (within the flow, in 2 digits with 10-step increments so that later other steps can be injected), e.g for the vaccination flow:

* 10 is event_providers refresh
* 20 is unomi
* 30 is event call
* 40 is storing events
* 50 is nonce call,
* 60 is signer call,
* 70 is storing credentials

See [Appendix A](#appendix-a) for the currently known steps for all major flows.

### Provider identifier

ppp is the provider identifier (000 for non-provider specific errors)

### Error code

hhh is the http error code from the server (0xx for client side local errors)

### Error detail code

If available: bbbbbb is any code from the body of the server call, e.g. 999

## Examples

* `220/RVV/500/999111`  means: while retrieving a vaccination and doing a unomi call to RIVM, the server responded  with a 500 error and the body said it was 9999111.
* `110/ABC/051` means: while retrieving a commercial code and entering the code, for provider ABC, the Luhn check failed. (no detailed error code)

## Client side errors

For client side errors (0hh) there's a generic set that can happen with any api call. Where possible, these should be further broken down, e.g. if there are 2 ways an ssl pinning can fail, hen 010, 011 and 012 can be used).

00h - connection related failures
01h - ssl pinning failures
02h - cms signature failures
03h - json parse failures
04h - data validation failures
≥ 05h - flow specific failures (051 → luhn check failed etc)

See [Appendix B](#appendix-b) for client side error lists. 

# Appendix A

Known step lists

## Holder app

### Startup / Onboarding (flow 0)

### Commercial test (flow 1)

### Vaccination (flow 2)

(voorzet, todo ios/android devs)

* 10 is event_providers refresh
* 20 is unomi
* 30 is event call
* 40 is storing events
* 50 is nonce call,
* 60 is signer call,
* 70 is storing credentials

### Recovery (flow 3)

### Digid test results (flow 4)

### Paper scan (flow 5)

## Verifier app

### Startup / Onboarding (flow 0)

### Scan flow (flow 1)

# Appendix B

Client side error lists

## 00h - connection related failures

voorzet, todo android/ios devs.

* 001 - Unable to connect to host
* 002 - Invalid hostname.. etc.

## 01h - ssl pinning failures

* 010 - ...

## 02h - cms signature failures

## 03h - json parse failures

## 04h - data validation failures

* 040 - Malformed json string
* 041 - Required field missing, etc..

## ≥ 05h - flow specific failures 

* 051 - luhn check failed etc
