import Foundation

public typealias JSONPath = String
public typealias Match = Dictionary<ClaimId, [Dictionary<InputDescriptorId, [(JSONPath, Any)]>]>
public typealias ClaimId = String
public typealias Purpose = String
public typealias Name = String
public typealias InputDescriptorId = String
public typealias Group = String
