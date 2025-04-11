/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation
import PresentationExchange

/// An enumeration representing different types of authorization requests.
public enum AuthorizationRequest {
  /// A not secured authorization request.
  case notSecured(data: ResolvedRequestData)

  /// A JWT authorization request.
  case jwt(request: ResolvedRequestData)
  
  /// The resolution was not succesful
  case invalidResolution(
    error: AuthorizationRequestError,
    dispatchDetails: ErrorDispatchDetails?
  )
}

/// An extension providing an initializer for the `AuthorizationRequest` enumeration.
public extension AuthorizationRequest {
  
  /// Initializes an `AuthorizationRequest` using the provided authorization request data.
  /// - Parameters:
  ///   - authorizationRequestData: The authorization request data to process.
  init(
    authorizationRequestData: AuthorisationRequestObject?,
    walletConfiguration: SiopOpenId4VPConfiguration? = nil
  ) async throws {
    
    var validated: ValidatedSiopOpenId4VPRequest? = nil
    var resolved: ResolvedRequestData? = nil
    
    guard let authorizationRequestData = authorizationRequestData else {
      let details: ErrorDispatchDetails? = switch walletConfiguration?.errorDispatchPolicy {
      case .none:
        nil
      case .allClients:
        await Self.errorDetails()
      case .onlyAuthenticatedClients:
        nil
      }
      self = .invalidResolution(
        error: ValidationError.noAuthorizationData,
        dispatchDetails: details
      )
      return
    }
    
    guard !authorizationRequestData.hasConflicts else {
      self = await .invalidResolution(
        error: ValidationError.conflictingData,
        dispatchDetails: Self.errorDetails(authorizationRequestData)
      )
      return
    }
    
    do {
      validated = try await Self.validateRequest(authorizationRequestData, walletConfiguration)
      
      guard let validated = validated else {
        throw ValidationError.validationError("Validated data are nil")
      }
      
      resolved = try await Self.resolveRequest(validated, walletConfiguration)
      guard let resolved = resolved else {
        throw ValidationError.validationError("Resolved data are nil")
      }
      
      self = authorizationRequestData.requestUri != nil ? .jwt(request: resolved) : .notSecured(data: resolved)
      
    } catch let error as AuthorizationRequestError {
      self = await .invalidResolution(
        error: error,
        dispatchDetails: Self.errorDetails(
          authorizationRequestData,
          validated,
          walletConfiguration
        )
      )
    } catch {
      self = await .invalidResolution(
        error: ValidationError.validationError(
          error.localizedDescription
        ),
        dispatchDetails: Self.errorDetails(
          authorizationRequestData,
          validated,
          walletConfiguration
        )
      )
    }
  }

  private static func validateRequest(
    _ authorizationRequestData: AuthorisationRequestObject,
    _ walletConfiguration: SiopOpenId4VPConfiguration?
  ) async throws -> ValidatedSiopOpenId4VPRequest? {
    return if let request = authorizationRequestData.request {
      try await .init(
        request: request,
        requestUriMethod: .init(
          method: authorizationRequestData.requestUriMethod
        ),
        walletConfiguration: walletConfiguration
      )
    } else if let requestUri = authorizationRequestData.requestUri {
      try await .init(
        requestUri: requestUri,
        requestUriMethod: .init(
          method: authorizationRequestData.requestUriMethod
        ),
        clientId: authorizationRequestData.clientId,
        walletConfiguration: walletConfiguration
      )
    } else {
      try await .init(
        authorizationRequestData: authorizationRequestData,
        walletConfiguration: walletConfiguration
      )
    }
  }

  private static func resolveRequest(
    _ validated: ValidatedSiopOpenId4VPRequest,
    _ walletConfiguration: SiopOpenId4VPConfiguration?
  ) async throws -> ResolvedRequestData? {
    return try await .init(
      vpConfiguration: walletConfiguration?.vpConfiguration ?? .default(),
      clientMetaDataResolver: ClientMetaDataResolver(
        fetcher: Fetcher(
          session: walletConfiguration?.session ?? URLSession.shared
        )
      ),
      presentationDefinitionResolver: PresentationDefinitionResolver(
        fetcher: Fetcher(
          session: walletConfiguration?.session ?? URLSession.shared
        )
      ),
      validatedAuthorizationRequest: validated
    )
  }
  
  private static func errorDetails(
    _ authorizationRequestData: AuthorisationRequestObject? = nil,
    _ validated: ValidatedSiopOpenId4VPRequest? = nil,
    _ walletConfiguration: SiopOpenId4VPConfiguration? = nil
  ) async -> ErrorDispatchDetails? {
    
    func jarmSpec() async throws -> JarmSpec {
      try await JarmSpec(
        clientMetaData: validated?.clientMetaData(),
        walletOpenId4VPConfig: walletConfiguration
      )
    }
    
    return if let validated = validated,
       let responseMode = validated.responseMode {
      await .init(
        responseMode: responseMode,
        nonce: validated.nonce,
        state: validated.state,
        clientId: validated.clientId,
        jarmSpec: try? jarmSpec()
      )
      
    } else if let authorizationRequestData = authorizationRequestData {
      await .init(
        responseMode: authorizationRequestData.validResponseMode,
        nonce: authorizationRequestData.nonce,
        state: authorizationRequestData.state,
        clientId: validated?.clientId,
        jarmSpec: try? jarmSpec()
      )
    } else {
      nil
    }
  }
}

internal extension AuthorisationRequestObject {
  var validResponseMode: ResponseMode {
    return (try? ResponseMode(authorizationRequestData: self)) ?? .none
  }
}
