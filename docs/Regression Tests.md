# CoronaCheck test automation
<!-- markdownlint-disable MD024 -->

By [Joris De Haes](mailto:info@jorisdehaes.nl), March 2023

The regression test automation for the CoronaCheck Holder apps is set up as an UI end-to-end test on the Acceptance environment. The goal is to verify the retrieval of data from the backend, and the data shown on the different screens.

It is an addition to the developer tests (unit, integration, screenshot) and supports the QA activity to verify the apps for regressions.

The test scenarios of iOS extensively verify the correct retrieval and showing of data.

The scenarios on Android also verify the correct handling of data during device manipulation, like date shifting and offline mode.

- [General](#general)
  - [Test data](#test-data)
  - [Password](#password)
- [iOS](#ios)
  - [Goal](#goal)
  - [Components](#components)
  - [Holder UI Tests / Smoketests](#holder-ui-tests--smoketests)
  - [XCodeGen](#xcodegen)
    - [Targets](#targets)
    - [Schemes](#schemes)
  - [Fastlane](#fastlane)
  - [GitHub workflows](#github-workflows)
  - [Test class and functions](#test-class-and-functions)
  - [BaseTest class](#basetest-class)
  - [Models](#models)
    - [TestPerson](#testperson)
    - [Person and Events](#person-and-events)
    - [Other models](#other-models)
  - [Test scenarios](#test-scenarios)
    - [Actions](#actions)
    - [Assertions](#assertions)
    - [Utils](#utils)
    - [XCUIElement(Query)](#xcuielementquery)
    - [Rapidly Evaluate](#rapidly-evaluate)
  - [Controlling Safari](#controlling-safari)
  - [Result file](#result-file)
- [Android](#android)
  - [Goal](#goal-1)
  - [Components](#components-1)
  - [Gradle / Firebase](#gradle--firebase)
  - [GitHub workflows](#github-workflows-1)
  - [Test class and functions](#test-class-and-functions-1)
  - [BaseTest](#basetest)
  - [Mocking the app config](#mocking-the-app-config)
  - [Models](#models-1)
  - [Test scenarios](#test-scenarios-1)
  - [Interaction](#interaction)
    - [Espresso](#espresso)
    - [Barista](#barista)
    - [UI Automator](#ui-automator)
    - [Waiting](#waiting)
  - [Controlling Chrome](#controlling-chrome)
  - [Device manipulation](#device-manipulation)
    - [Date shifting](#date-shifting)
    - [Airplane mode](#airplane-mode)

## General

### Test data

Most test scenarios rely on the Acceptance environment backend and specifically the test data from the test data sheet or the defined tokens.

If the backend is unavailable or the test data is changed, the test results will not match the expected results, and the test scenario will fail.

### Password

The backend is password protected, or can be accessible via VPN or whitelisted IP address. These options are not a good option when running the tests in GitHub or Firebase, so the password is used when interacting with the backend.

The password is stored as a secret in the repositories, and is retrieved during the test execution.

This document will not tell you what the password is, ask someone else.

## iOS

### Goal

For iOS, the main focus is to automate most or all of the test scenarios in the test sheet. This means that a scenario starts with the retrieval of one or more events and asserts the retrieved data on the retrieval screen, overview and/or wallet.

There is no possibility on iOS to manipulate the device date or airplane mode, so that is not tested.

### Components

The iOS test automation is located in the [iOS repository](https://github.com/minvws/nl-covid19-coronacheck-app-ios). It has these components:

1. [HolderUITests](https://github.com/minvws/nl-covid19-coronacheck-app-ios/tree/main/HolderUITests) contains all test scenarios and additional code
    1. [Tests](https://github.com/minvws/nl-covid19-coronacheck-app-ios/tree/main/HolderUITests/Tests): all non-smoke test scenarios
    2. [Smoketests](https://github.com/minvws/nl-covid19-coronacheck-app-ios/tree/main/HolderUITests/Smoketests): smoke test scenarios
    3. [Sources](https://github.com/minvws/nl-covid19-coronacheck-app-ios/tree/main/HolderUITests/Sources): base test, utils, steps, models, additional code
2. The [XCodeGen project file](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/project.yml) defines the test targets and schemes
3. The [fastlane file](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/fastlane/Fastfile) defines the test execution
4. [GitHub workflows](https://github.com/minvws/nl-covid19-coronacheck-app-ios/tree/main/.github/workflows) define the triggers, code generation, test runner and results

### Holder UI Tests / Smoketests

Most scenarios that are defined in the test scenario sheet are tested on iOS in the _Holder UI Tests_, about 300. These include vaccinations, recoveries, negative tests, negative tokens, DCCs.

Running all these tests takes a long time. Besides the option to run all the tests, there is an option to only run important scenarios: the _Holder UI Smoketests_.

The smoke test is a subset of the full test target. This is handled by the definition of the test targets in XCodeGen.

### XCodeGen

#### Targets

In the [XcodeGen file](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/project.yml), the [HolderUITests](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/project.yml#L409) and [HolderUISmoketests](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/project.yml#L415) are defined as Targets. They use a custom [Standard_UITesting](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/project.yml#L244) template, which gives the type as UI testing, and it enables the option to generate the Info.plist file.

 The only difference is that the smoke tests exclude the files from the Tests directory, so only contains the scenarios of the Smoketests directory.

#### Schemes

Both targets have their own scheme, called [HolderUITests](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/project.yml#L409) and [HolderUISmoketests](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/project.yml#L415), so they can be run separately.

The schemes depend on the [UITestScheme](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/project.yml#L468) template. This adds an environment variable to the schemes to retrieve the Acceptance backend password from the environment. It also enables parallel and random test execution.

### Fastlane

The [Fastlane file](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/fastlane/Fastfile) defines the test execution in one statement, the ‘lane’. It defines what scheme to test, on what device, and what tests to skip. The full tests currently [skip test scenarios](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/fastlane/Fastfile#L72) related to (fuzzy) matching.

### GitHub workflows

The two tests have their own workflow on GitHub Actions, [test-ui](https://github.com/minvws/nl-covid19-coronacheck-app-ios/actions/workflows/test-ui.yml) and [smoketest-ui](https://github.com/minvws/nl-covid19-coronacheck-app-ios/actions/workflows/smoketest-ui.yml). The workflows check out the code, build the apps, run the lane defined by Fastlane, and archive the results.

The workflows are configured  in the GitHub workflow files.Only the [smoke test](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/.github/workflows/smoketest-ui.yml) has a schedule to run, but [both](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/.github/workflows/test-ui.yml) can be started from GitHub Actions manually, using the _workflow_dispatch_ trigger.

### Test class and functions

Test scenarios are written as functions in a class. Test functions must start with the ‘test’ prefix, have no arguments and no return value.

Test functions are combined in a test class. This can change behavior for all tests in the test class, like setting the [disclosure mode](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Smoketests/DisclosureMode0GSmoke.swift#L10-L14) or adding a [DCC value](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Smoketests/ForeignDCCSmoke.swift#L19-L23). The test class can also have [class variables](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Tests/Tokentest.swift#L12-L15), available to all test functions in the class.

Test classes inherit from the BaseTest class.

### BaseTest class

The [BaseTest class](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/BaseTest.swift) describes functionality that is common for every test, like starting the application, setting default launch arguments and tearing down after a test.

The launch arguments that are used are for resetting the application on start, for skipping the onboarding, disabling transitions, showing accessibility labels on certain screens, and setting the disclosure mode.

### Models

The tests on iOS have multiple models.

#### TestPerson

A [TestPerson](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/TestPerson.swift) describes a person, and the expected values for all events: vaccinations, recoveries and negative tests. This is made in one class so setting tests up from the test sheet was done quickly.

TestPersons are defined in TestData, so they could be referenced in all test scenarios. This is useful for test groups where the setup is the same for all scenarios, like fuzzy matching.

The TestPerson class was getting too clunky, and had some implicit expectations, like evenly timed vaccinations. Consider this deprecated, even though most test scenarios are still only defined with a TestPerson.

#### Person and Events

Newer tests use the [Person](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Person.swift) and [Event](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Event.swift) subclasses for their models. They only define a single part of a test scenario, and should be combined to match the expectations in a scenario.

#### Other models

There are simple [models](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Types.swift) for the certificate and event types and disclosure modes.

### Test scenarios

The test scenarios have a common structure used in testing: Arrange-Act-Assert (Behavior driven development), or Given-When-Then (Gherkin).

Because the scenarios are usually long flows through the application, and arranging and acting are both actions, these functions are split into two files, Actions and Assertions. Both are extensions of BaseTest, so every test class can access them.

Expected data is defined in local variables. For older tests as a TestPerson, or in newer tests as a Person and one or more Events.

#### Actions

The [actions](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Actions.swift) that are used in the test scenarios are described here, and use common underlying actions like tapping buttons and entering text. Some actions have small assertions.

#### Assertions

[Assertions](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Assertions.swift) are checking if the screen elements like texts and buttons are present and have the correct data.

Assertions use the expected data supplied in the test scenario by the local variables (Test)Person and Events.

Note: Some older assertions have implicit expectations, like that there is [always 30 days](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Assertions.swift#L309) between every vaccination dose. This way only one vaccination date is supplied in TestPerson. The Person/Event models make these expectations explicit, so multiple vaccinations can be defined and retrieved.

Not all fields are checked in all screens. Most of this information can currently not be defined in TestPerson, and data is added to the Person/Events models as needed. On Android, most if not all fields are checked, but for less test scenarios.

#### Utils

There are multiple utils which contain common specific functions. [Utils](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Utils.swift) contains functions for [formatting and offsetting dates](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Utils.swift#L12-L39) , [doses](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Utils.swift#L41-L48), making [screenshots](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Utils.swift#L50-L57), [card elements](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Utils.swift#L59-L106).

For newer tests, [DateUtils](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/DateUtils.swift) takes care of initializing, formatting and offsetting dates.

To aid debugging, [DebugUtils](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/DebugUtils.swift) can print several child (web) elements of an element.

#### XCUIElement(Query)

XCTest uses XCUIElements to interact with the application and set expectations.

It works like `element.action(parameter)`, where the element is an XCUIElement, the action is a standard function or a function defined in the extension, and where the function uses the parameter in its working. If the action does not succeed, for instance a button can' is not found, the test execution fails.

[XCUIElement](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/XCUIElement.swift) is an extension to the main class, and has functions for [clearing text](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/XCUIElement.swift#L14-L25) from the element, asserting the element [does (not) exist](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/XCUIElement.swift#L27-L36), [tapping a button](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/XCUIElement.swift#L38-L43), [containing text](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/XCUIElement.swift#L51-L77) or values, etc.

[XCUIElementQuery](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/XCUIElementQuery.swift) extends the main class with functions to return an [element map](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/XCUIElementQuery.swift#L12-L14), used by the DebugUtils, and to return a [set of labels](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/XCUIElementQuery.swift#L16-L18) of an element, used by the wallet scenarios.

#### Rapidly Evaluate

The default waiting time of XCUITest is 1 second. For small tests this is fine, but for large scenarios and lots of data to assert this adds up. To decrease the waiting time, rapidlyEvaluate is used, which loops and checks very quickly.

### Controlling Safari

Safari is the default web browser on iOS, and is used to retrieve the data from the backend. Safari can be controlled by XCTest using its [bundle identifier](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/BaseTest.swift#L13).

[Retrieving](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Actions.swift#L131-L154) data is handled by controlling Safari to enter the BSN into the textfield and submitting the form. The callback will reopen the Holder application.

If Safari has not logged in before, the username and password are entered into the [login](https://github.com/minvws/nl-covid19-coronacheck-app-ios/blob/main/HolderUITests/Sources/Actions.swift#L156-L178) dialog, before continuing with entering the BSN. After the first time the browser has logged in, it doesn’t need to log in anymore.

### Result file

All test runs of XCode, local or cloud, generate an xcresult file. This file can be opened in XCode to see the results per test, with timing, steps and screenshots.

## Android

### Goal

As most of the data driven tests are covered by the iOS regression test, the Android test focuses more on the device specific tests. These include date shifting and airplane mode before or after data retrieval.

### Components

The Android tests are located in the [Android repository](https://github.com/minvws/nl-covid19-coronacheck-app-android), and has these components:

- The [end2end directory](https://github.com/minvws/nl-covid19-coronacheck-app-android/tree/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end), with the tests, utils, actions, assertions, etc.
- Configuration of the Holder [Gradle](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/build.gradle) file, with Firebase config using Fladle
- [GitHub workflows](https://github.com/minvws/nl-covid19-coronacheck-app-android/tree/main/.github/workflows) define the triggers, code generation, test runner and results

### Gradle / Firebase

The gradle file for the Holder has a few changes for the test automation.

1. The application is [cleared](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/build.gradle#L49) after every test, so tests run independently
2. [Animations](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/build.gradle#L21-L22) are disabled, and the AndroidX test orchestrator is used
3. The [password](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/build.gradle#L170) is made available from the runner arguments to the tests
4. The configuration for the Firebase tests are defined with Fladle. This configuration also passes the password to Firebase, and clears the package after every run.
    1. The normal unit test variant [excludes](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/build.gradle#L175) the end-to-end tests
    2. The [end2end](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/build.gradle#L180-L190) variant runs on multiple API levels
    3. The [onDemand](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/build.gradle#L191-L199) variant only runs on API level 33 (Android 13), and runs only tests with the [@RunFirebaseTestOnDemand](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/build.gradle#L194) annotation.

### GitHub workflows

The two tests have their own workflow on GitHub Actions, [end2end](https://github.com/minvws/nl-covid19-coronacheck-app-android/actions/workflows/end2end.yml) and [UI Tests on demand](https://github.com/minvws/nl-covid19-coronacheck-app-android/actions/workflows/ui_tests_on_demand.yml). The workflows set the version number, check out the code, build the apps, run the related Firebase test. The version number has to be above the minimum version in the config, so 4000 is added.

The workflows are configured  in the GitHub workflow files. The [end2end](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/.github/workflows/end2end.yml#L5) workflow has a schedule to run, but both can be started from GitHub Actions manually, using the _workflow_dispatch_ trigger.

### Test class and functions

Test scenarios are written as functions in a class. Test functions must have the JUnit `@Test` annotation, can be skipped with the `@Ignore` annotation, and can be run with the on demand runner with the [`@RunFirebaseTestOnDemand`](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/utils/RunFirebaseTestOnDemand.kt) annotation.

The tests, with exception of the [SmokeTest](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/SmokeTest.kt), only run on API level 33 (Android 13) with the `@SdkSuppress` annotation.

Test functions are combined in a test class. This can change behavior for all tests in the test class, like [setting](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/FutureEventRetrievalTest.kt#L26-L30) the device date before the tests, and [resetting](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/FutureEventRetrievalTest.kt#L32-L35) it after. The test class can also have [class variables](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/TokenTest.kt#L41), available to all test functions in the class.

Test classes inherit from the BaseTest class.

### BaseTest

The [BaseTest class](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/BaseTest.kt) describes functionality that is common for every test, like [starting](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/BaseTest.kt#L52) the application, [mocking](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/BaseTest.kt#L41) the config, [skipping](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/BaseTest.kt#L46-L48) the onboarding and [ignoring](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/BaseTest.kt#L43-L44) dialogs. This is done by Koin, so BaseTests inherits from AutoCloseKoinTest.

Common objects are [initialized](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/BaseTest.kt#L55-L62) here, like the instrumentation, context, device and current date. The backend [password](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/BaseTest.kt#L61-L62) is retrieved from the instrumentation registry.

### Mocking the app config

The application configuration is mocked using Koin by [overriding the modules](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/utils/ConfigOverride.kt). To make sure everything still works, all relevant configuration data needs to be supplied, as well as both backend TLS [certificates](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/utils/ConfigOverride.kt#L44-L45) and public keys, found in [TestKeys](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/res/TestKeys.kt).

### Models

The models are [Person](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/model/Person.kt), with default values for a person, and [Event](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/model/Event.kt), which has submodels for vaccinations, recoveries, negative tests and negative tokens. All data that is shown on screen are asserted in the test scenarios, or they could be, except for the unique number.

[LocalDate](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/model/LocalDate.kt) also has extra functions to make date formatting easier.

### Test scenarios

The test scenarios have a common structure used in testing: Arrange-Act-Assert (Behavior driven development), or Given-When-Then (Gherkin).

Because the scenarios are usually long flows through the application, and arranging and acting are both actions, these functions are split into two directories, [Actions](https://github.com/minvws/nl-covid19-coronacheck-app-android/tree/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/actions) and [Assertions](https://github.com/minvws/nl-covid19-coronacheck-app-android/tree/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/assertions).

Expected data is defined in local instances of [Person](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/VaccinationRetrievalTest.kt#L35) and one or more [Events](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/VaccinationRetrievalTest.kt#L36-L37).

Actions and Assertions are split up for ease of development in multiple files. They use the underlying interaction functions from different frameworks, each in their own file.

### Interaction

#### Espresso

Google made [Espresso](https://developer.android.com/training/testing/espresso) to write Android UI tests. It is very powerful, but verbose, and can only interact with the application under test. Espresso is used here for cases where Barista is not adequate, like [tapping a button](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/interaction/Espresso.kt#L25-L37) that is shown multiple times.

#### Barista

To make UI testing easier, [Barista](https://github.com/AdevintaSpain/Barista) simplifies the verbose syntax of Espresso. All [used Barista](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/interaction/Barista.kt) functions are wrapped here to add logging.

#### UI Automator

Before Espresso, Google made [UI Automator](https://developer.android.com/training/testing/other-components/ui-automator), which can interact with the system and all applications, but only when it is shown on screen. It is used here to interact with [Chrome](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/actions/Server.kt), setting the [date](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/utils/DateTimeUtils.kt) and toggling [airplane](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/actions/Device.kt) mode.

#### Waiting

Espresso, and by extension Barista, does not have the ability to wait for an element to exist or be in a specific state. Normally this is not a problem, as these frameworks are used for static tests, without server interaction.

Because the end to end regression tests have a dependency on the backend server, tests must wait for elements or states. This is done by [WaitUntilCondition](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/interaction/WaitUntilCondition.kt), which uses a [Wait](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/interaction/wait/Wait.kt) object to loop and check a [Condition](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/interaction/wait/Conditions.kt), like a button being in a [specific state](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/interaction/wait/Conditions.kt#L18-L30), or a [view being shown](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/interaction/wait/Conditions.kt#L32-L44). Waiting fails when it times out before the condition is met.

### Controlling Chrome

Chrome is the default web browser on Android, and is used to retrieve the data from the backend. Chrome is controlled by [UI Automator](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/interaction/UiAutomator.kt).

[Retrieving](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/actions/Server.kt#L19-L29) data is handled by controlling Chrome to enter the BSN into the textfield and submitting the form. The callback will reopen the Holder application.

If Chrome has not logged in before, the username and password are entered into the [login](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/actions/Server.kt#L31-L39) dialog, before continuing with entering the BSN. After the first time the browser has logged in, it doesn’t need to log in anymore.

If Chrome has not been used before, it will show several onboarding dialogs, even on Firebase. These are all [checked](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/actions/Server.kt#L41-L50) and handled.

### Device manipulation

#### Date shifting

For test scenarios where the device is set in the past or the future, the device date needs to be set. This is done with the [DateTimeUtils](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/utils/DateTimeUtils.kt), which opens the Date settings, and interacts with the calendar to set the requested date, or reset to automatic.

#### Airplane mode

For test scenarios where the device is offline, airplane mode needs to be toggled. This is done by [interacting](https://github.com/minvws/nl-covid19-coronacheck-app-android/blob/main/holder/src/androidTest/java/nl/rijksoverheid/ctr/holder/end2end/actions/Device.kt) with the quick settings and tapping on the Airplane mode.
