# better-jit-handler

> This is a modular refactor of the [Salesforce generated SAML JIT Handler](https://resources.docs.salesforce.com/218/latest/en-us/sfdc/pdf/salesforce_single_sign_on.pdf) with 99% test coverage. Handles Internal and External Users. May be easily modified to capture relevant fields for your own SAML Assertion implementation.

> By parsing the SAML XML and by extracting logic into separate handlers by object, this JIT Handler makes it easier to maintain a custom SSO implementation.

## SimpleJITHandler.cls

This is the global implementation of the [Auth.SamlJitHandler](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_interface_Auth_SamlJitHandler.htm). Modifications of this file are unlikely.

## SamlModel

Parses the SAML XML request into an object model.

## AccountJITHandler.cls

Contains logic for create and update of Account records under JIT Flow.

## ContactJITHandler.cls

Contains logic for create and update of Contact records under JIT Flow.

## UserJITHandler.cls

Contains logic for create and update of User records under JIT Flow.

## JITTestUtil.cls

A TestUtil class for constants, data creation, and retrieval.

## Test Classes

 1. SimpleJITHandlerTest
 1. AccountJITHandlerTest
 1. ContactJITHandlerTest
 1. UserJITHandlerTest
