# CoronaCheck - Result Provider Validation Portal

Version: 1.0.0
Status: DRAFT

## Overview

Test results are provided to the CoronaCheck app directly by Test Result providers who have implemented the interfaces documented in [providing test results](providing-test-results.md).

In order to ensure that the implementations are implemented correctly we will provide a method whereby the implementation can be tested both manually and automatically. That method is the subject of this document.

## Validation Process

This procedure must be performed during the onboarding procedure and can be performed on demand during the product lifecycle (for example during release preperation). Result Providers are responsible for ensuring that their API implementations are correct and remain correct.

SEE SEE: [providing-test-results.md](providing-test-results.md) for the process after phase 1.

After phase two, the process will be:

1. Result provider deploys their API into an acceptance environment.
2. Result provider loads the latest test set into their database.
3. Result provider makes use of the Validation Portal to execute a validation run against their accepance environment
4a. If unsuccessful, Result provider applies technical fixes and follows this process again from step 1.
4b. If successful, the Result Provider sends the results to the CoronaCheck team per email.

## Phase 1

The goal of the first phase is to build the minimum workable set of functionality required for the tests to be executed by the CoronaCheck team.

* Test set will be defined and published in the coordination repository in the CSV format.
* A set of tests which cover our minimum requirement of correctness will be created.
* A set of scripts which can be executed manually to perform said tests will be created.

SEE: [providing-test-results.md](providing-test-results.md) for the file specs

## Phase 2

In the second phase we will build the Validation Portal; this is a self-service portal where the Result Providers can execute a test run themselves, on demand, without requiring any technical knowledge.

Here's a wireframe of the minimal screens:

[logo]: images/validation-portal-phase2-wireframe.png "Wireframe of the screens in the portal"

This will be specified further in the future.
