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
  private var onBatteryUpdated: (() -> Void)?
  private var cancellables = Set<AnyCancellable>()

  public override init() {}
  
  public var hasAssessmentPassed: [Assessment: Bool] = [
    .batteryStatus: false,
    .connector: false,
    .wirelessCharging: false
  ]
  
  public var assessments: [Assessment: Any] = [:]
  
  public func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) {
    UIDevice.current.isBatteryMonitoringEnabled = true
    guard UIDevice.current.isBatteryMonitoringEnabled else { return }
    
    self.onBatteryUpdated = completion
    
    switch type {
    case .connector:
      NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)
        .sink { [weak self] notification in
          self?.hasAssessmentPassed[.connector] = UIDevice.current.batteryState == .charging
          completion?()
        }
        .store(in: &cancellables)
      
    case .batteryStatus:
      batteryLevel = UIDevice.current.batteryLevel
      timer = Timer.scheduledTimer(
        timeInterval: 10,
        target: self,
        selector: #selector(measureAgain),
        userInfo: nil,
        repeats: false
      )
      
      assessments[.batteryStatus] = Battery(
        remainingTime: "\(remainingTimeInMinutes)",
        percentage: batteryLevel
      )
      completion?()
      
    case .wirelessCharging:
      let batteryState = UIDevice.current.batteryState
      NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)
        .sink { [weak self] notification in
          self?.hasAssessmentPassed[.wirelessCharging] = batteryState == .charging && batteryState == .unplugged
          completion?()
        }
        .store(in: &cancellables)
      
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

    if var battery = assessments[.batteryStatus] as? Battery {
      battery.remainingTime = "\(remainingTimeInMinutes)"
      battery.percentage = batteryAfterInterval
//      onBatteryUpdated?()
    }
  }
}
