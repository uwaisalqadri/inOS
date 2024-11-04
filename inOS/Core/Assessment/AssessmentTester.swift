//
//  DeviceAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 15/12/23.
//

import Foundation
import UIKit

public protocol AssessmentDriver {
  var hasAssessmentPassed: [Assessment: Bool] { get }
  var assessments: [Assessment: Any] { get }
  
  func startAssessment(for type: Assessment, completion: (() -> Void)?)
  func startAssessment(for type: Assessment, completion: ((Any?) -> Void)?)
  func stopAssessment(for type: Assessment)
}

public extension AssessmentDriver {
  func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) { completion?() }
  func startAssessment(for type: Assessment, completion: ((Any?) -> Void)? = nil) { completion?(nil) }
  func stopAssessment(for type: Assessment) {}
}

public struct AssessmentTester {
  public let driver: AssessmentDriver
  
  public init(driver: AssessmentDriver) {
    self.driver = driver
  }
  
  public init(driver: AssessmentDriverType) {
    switch driver {
    case .connectivity:
      self.driver = ConnectivityAssessment()
    case .device:
      self.driver = DeviceAssessment()
    case .physical:
      self.driver = PhysicalAssessment()
    case .power:
      self.driver = PowerAssessment()
    }
  }
  
  public enum AssessmentDriverType {
    case connectivity
    case device
    case physical
    case power
  }
}
