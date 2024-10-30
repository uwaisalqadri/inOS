//
//  PowerAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 24/12/23.
//

import Foundation
import UIKit
import Combine

public class PowerAssessment: NSObject, AssessmentDriver {
  private var batteryLevel: Float = 0.0
  private var remainingTimeInMinutes: Float = 0.0
  private var timer = Timer()
  private var cancellables = Set<AnyCancellable>()

  public override init() {}
  
  public var hasAssessmentPassed: [Assessment: Bool] {
    return [.batteryStatus: true]
  }
  
  public var assessments: [Assessment: Any] = [:]
  
  public func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) {
    UIDevice.current.isBatteryMonitoringEnabled = true
    guard UIDevice.current.isBatteryMonitoringEnabled else { return }
    
    switch type {
    case .connector:
      NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)
        .sink { [weak self] notification in
          self?.assessments[.connector] = UIDevice.current.batteryState == .charging
          completion?()
        }
        .store(in: &cancellables)
      
    case .batteryStatus:
      batteryLevel = UIDevice.current.batteryLevel
      timer = Timer.scheduledTimer(
        timeInterval: 20,
        target: self,
        selector: #selector(measureAgain),
        userInfo: nil,
        repeats: false
      )
      
      assessments[.batteryStatus] = Battery(
        remainingTime: "\(remainingTimeInMinutes)",
        percentage: batteryLevel.toPercentage()
      )
      completion?()
      
    default:
      break
    }
  }
  
  public func stopAssessment(for type: Assessment) {
    if type == .batteryStatus {
      UIDevice.current.isBatteryMonitoringEnabled = false
    }
  }
}

extension PowerAssessment {
  @objc func measureAgain() {
    let batteryAfterInterval = UIDevice.current.batteryLevel
    let difference = batteryAfterInterval - batteryLevel
    let remainingPercentage = 100.0 - batteryAfterInterval
    remainingTimeInMinutes = remainingPercentage / difference
  }
}
