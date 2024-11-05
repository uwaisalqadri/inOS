//
//  BiometricAuthentication.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 11/1/24.
//

import Foundation
import LocalAuthentication

enum BiometricType {
  case none
  case touchID
  case faceID
  
  var loginReason: String {
    switch self {
    case .none:
      return "Checking Biometric"
    case .touchID:
      return "Touch ID"
    case .faceID:
      return "Face ID"
    }
  }
}

class BiometricAuthentication {
  lazy var context: LAContext = {
    let context = LAContext()
    context.localizedFallbackTitle = ""
    return context
  }()
    
  @discardableResult
  func canEvaluatePolicy() -> Bool {
    return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }
  
  func authenticateUser(type: BiometricType, completion: @escaping (BiometricFailedReason, Error?) -> Void) {
    canEvaluatePolicy()

    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: type.loginReason) { success, evaluateError in
      DispatchQueue.main.async {
        if success {
          completion(.none, nil)
        } else {
          var reason: BiometricFailedReason
          switch evaluateError {
          case LAError.authenticationFailed?:
            reason = .biometricProblemVerifying
          case LAError.userCancel?:
            reason = .biometricCancelled
          case LAError.userFallback?:
            reason = .biometricEnterPin
          case LAError.biometryNotAvailable?:
            reason = .biometricUnavailable
          case LAError.biometryNotEnrolled?:
            reason = .biometricNotSetUp
          case LAError.biometryLockout?:
            reason = .biometricLocked
          default:
            reason = .biometricNotConfigured
          }
          completion(reason, evaluateError)
        }
      }
    }
  }
}
