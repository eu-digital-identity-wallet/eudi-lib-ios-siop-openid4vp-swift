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

// Protocol to verify JWT claims
private protocol JWTClaimsSetVerifier {
  func verify(claimsSet: JWTClaimsSet) throws
}

private enum JWTVerificationError: Error {
  case expiredJWT
  case issuedInFuture
  case issuedAfterExpiration
  case notYetActive
  case activeAfterExpiration
  case activeBeforeIssuance
}

private struct DateUtils {
  static func isAfter(_ date1: Date, _ date2: Date, _ skew: TimeInterval) -> Bool {
    return date1.timeIntervalSince(date2) > skew
  }

  static func isBefore(_ date1: Date, _ date2: Date, _ skew: TimeInterval = .zero) -> Bool {
    return date1.timeIntervalSince(date2) < -skew
  }
}

// TimeChecks class implementation in Swift
internal class TimeChecks: JWTClaimsSetVerifier {
  private let skew: TimeInterval

  init(skew: TimeInterval) {
    self.skew = skew
  }

  func verify(claimsSet: JWTClaimsSet) throws {
    let now = Date()
    let skewInSeconds = skew

    if let exp = claimsSet.expirationTime {
      if !DateUtils.isAfter(exp, now, skewInSeconds) {
        throw JWTVerificationError.expiredJWT
      }
    }

    if let iat = claimsSet.issueTime {
      if !DateUtils.isBefore(iat, now) {
        throw JWTVerificationError.issuedInFuture
      }

      if let exp = claimsSet.expirationTime, !iat.timeIntervalSince(exp).isLess(than: 0) {
        throw JWTVerificationError.issuedAfterExpiration
      }
    }
  }
}
