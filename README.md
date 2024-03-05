# SIOPv2 OpenID4VP 

:heavy_exclamation_mark: **Important!** Before you proceed, please read
the [EUDI Wallet Reference Implementation project description](https://github.com/eu-digital-identity-wallet/.github-private/blob/main/profile/reference-implementation.md)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

## Introduction

OpenID4VP is a Protocol that enables the presentation of Verifiable Credentials. It is built on top of OAuth 2.0 and supports multiple credential formats, including W3C Verifiable Credentials Data Model, ISO mdoc, and AnonCreds. This protocol allows for simple, secure, and developer-friendly credential presentation and can be used to support credential presentation and the issuance of access tokens for access to APIs based on Verifiable Credentials in the wallet

OpenID Connect for Verifiable Presentations (OIDC4VP) and Self-Issued OpenID Provider v2 (SIOP v2) are two specifications that have been approved as OpenID Implementer’s Drafts by the OpenID Foundation membership 1. SIOP v2 is an OpenID specification that allows end-users to act as their own OpenID Providers (OPs). Using Self-Issued OPs, end-users can authenticate themselves and present claims directly to a Relying Party (RP), typically a webapp, without involving a third-party Identity Provider 2. OIDC4VP enables the presentation of Verifiable Credentials using the OpenID Connect protocol.

## Library implementation

This is a Swift library, that conforms to Self Issued OpenID Provider v2 (SIOPv2 - draft 12) and OpenID for Verifiable Presentations (OpenID4VP - draft 18) specifications as defined by the OpenID Connect working group.
In particular, the library focus on the wallet's role and in addition focuses on the 
usage of those two protocols as they are constraint by ISO 23220-4 and ISO-18013-7

Additionally, it has support for Verifiable Presentations using the Presentation Exchange  library version 2. 
You can use this library to simplify the integration of OIDC4VP into your mobile applications.


## Usage

Entry point to the library is the class [SiopOpenId4Vp](https://github.com/niscy-eudiw/siop-openid4vp-ios/blob/main/Sources/SiopOpenID4VP/SiopOpenID4VP.swift).

You can add the library to your project using Swift Package Manager. [Releases](https://github.com/niscy-eudiw/siop-openid4vp-ios/tags)

```swift
import SiopOpenID4VP

let siopOpenId4Vp = SiopOpenID4VP()
```


### Resolve an authorization request URI 

Wallet receives an OAUTH2 Authorization request, formed by the Verifier, that may represent either 

- a SIOPv2 authentication request, or 
- a OpenID4VP authorization request,  
- or a combined SIOP & OpenID4VP request

In the same device  scenario the aforementioned authorization request reaches the wallet in terms of 
a deep link. Similarly, in the cross device scenario, the request would be obtained via scanning a QR Code.

Regardless of the scenario, wallet must take the URI (of the deep link or the QR Code) that represents the 
authorization request and ask the SDK to validate the URI (that is to make sure that it represents one of the supported
requests mentioned aforementioned) and in addition gather from Verifier additional information that may be included by
reference (such as `presentation_definition_uri`, `client_metadata_uri` etc)

The object that captures the aforementioned functionality is 
[ResolvedSiopOpenId4VPRequestData](https://github.com/niscy-eudiw/siop-openid4vp-ios/blob/main/Sources/OpenID4VPEntities/Resolved/ResolvedSiopOpenId4VPRequestData.swift)


async/await version:

```swift
import SiopOpenID4VP

let authorizationRequestUri : URL = ...

let sdk = SiopOpenID4VP()
let result = try await sdk.authorization(url: authorizationRequestUri)

switch result {
    ...
}
```

Combine version:

```swift
import SiopOpenID4VP

let authorizationRequestUri : URL = ...

let sdk = SiopOpenID4VP()
sdk.authorizationPublisher(for: authorizationRequestUri)
    .sink { completion in
    ...
    } receiveValue: { authorizationRequest in
    ...
    }
    .store(...)
```

### Holder's consensus, Handling of a valid authorization request

After receiving a valid authorization wallet has to process it. Depending on the type of request this means

* For a SIOPv2 authentication request, wallet must get holder's consensus and provide an `id_token`
* For a OpenID4VP authorization request,
    * wallet should check whether holder has claims that can fulfill verifier's requirements
    * let the holder choose which claims will be presented to the verifier and form a `vp_token`
* For a combined SIOP & OpenID4VP request, wallet should perform both actions described above.

This functionality is a wallet concern and it is not supported directly by the library


### Build an authorization response


After collecting holder's consensus, wallet can use the library to form an appropriate response [AuthorizationResponse](https://github.com/niscy-eudiw/siop-openid4vp-ios/blob/main/Sources/OpenID4VPEntities/AuthorisationRequest/AuthorizationResponse.swift).

```swift
import SiopOpenID4VP
// Example assumes that requestObject is SiopAuthentication & holder's agreed to the issuance of id_token
let resolved: ResolvedSiopOpenId4VPRequestData = ...
let jwt: JWTString = ... // provided by wallet
let consent: ClientConsent = .idToken(idToken: jwt)
let response = try AuthorizationResponse(
      resolvedRequest: resolved,
      consent: consent
    )
```

### Dispatch authorization response to verifier / RP (WIP)

The final step, of processing an authorization request, is to dispatch to the verifier the authorization response.
Depending on the `response_mode` that the verifier included in his authorization request, this is done either
* via a direct post (when `response_mode` is `direct_post` or `direct_post.jwt`), or
* by forming an appropriate `redirect_uri` (when response mode is `fragment` or `fragment.jwt`)

Library tackles this dispatching via the Dispatcher class.

```swift
let authorizationResponse // from previous step
let dispatchResponse = dispatch.dispatch(response: authorizationResponse)
```

## SIOPv2 & OpenId4VP features supported

## `response_mode`

A Wallet can take the form a web or mobile application.
OpenId4VP describes flows for both cases. Given that we are focusing on a mobile wallet we could
assume that `AuthorizationRequest` contains always a `response_mode` equal to `direct_post`

Library currently supports `response_mode`
* `direct_post`
* `redirect` (fragment or query)


## Supported Client ID Scheme

Library requires the presence of `client_id_scheme` with value
`pre-registered` assuming out of bound knowledge of verifier meta-data

## Authorization Request encoding

OAUTH2 foresees that `AuthorizationRequest` is encoded as an HTTP GET
request which contains specific HTTP parameters.

OpenID4VP on the other hand foresees in addition, support to
[RFC 9101](https://www.rfc-editor.org/rfc/rfc9101.html#request_object) where
the aforementioned HTTP Get contains a JWT encoded `AuthorizationRequest`

Finally, ISO-23220-4 requires the  usage of RFC 9101

Library supports obtaining the request object both by value (using `request` attribute) or
by reference (using `request_uri`)


## Presentation Definition
The Verifier articulates requirements of the Credential(s) that are requested using
`presentation_definition` and `presentation_definition_uri` parameters that contain a 
Presentation Definition JSON object. 

According to OpenId4VP, verifier may pass the `presentation_definition` either

* [by value](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#section-5.1)
* [by reference](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-presentation_definition_uri)
* [using scope](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-using-scope-parameter-to-re)

Library supports all these options

## Client metadata in Authorization Request
According to [OpenId4VP](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-authorization-request) verifier may pass his metadata (client metadata) either
* by value, or
* by reference

Library supports both options

## Supported response types

Library currently supports `response_type` equal to `id_token` or `vp_token id_token`


## Dependencies (to other libs)

* Presentation Exchange [Presentation Exchange](https://github.com/niscy-eudiw/presentation-exchange-swift)
* JSONSchema support: [JSON Schema](https://github.com/kylef/JSONSchema.swift)
* JSONPath support: [Sextant](https://github.com/KittyMac/Sextant.git)
* Lint support: [SwiftLint](https://github.com/realm/SwiftLint.git)
* JWS, JWE, and JWK support: [JOSESwift](https://github.com/airsidemobile/JOSESwift.git)
* Testing support: [Mockingbird](https://github.com/birdrides/mockingbird.git)