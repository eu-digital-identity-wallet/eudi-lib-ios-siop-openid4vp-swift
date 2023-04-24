import Foundation

public class OpenID4VP {
  
  func process(url: URL) async throws -> PresentationDefinition {
    let authorizationRequestData = AuthorizationRequestData(from: url)
    
    let validAuthorizationData = try ValidatedAuthorizationRequestData(authorizationRequestData: authorizationRequestData)
    
    guard let presentationDefinitionSource = validAuthorizationData.presentationDefinitionSource else {
      throw ValidatedAuthorizationError.noAuthorizationData
    }
    
    let resolvedValidAuthorizationData = try await ResolvedAuthorizationRequestData(resolver: PresentationDefinitionResolver(), source: presentationDefinitionSource)
    
    return resolvedValidAuthorizationData.presentationDefinition
  }
  
  func match(presentationDefinition: PresentationDefinition, claims: [Claim]) {
  }
  
  func verify() {}
}
