//
//  CompassPresenter.swift
//  inOS
//
//  Created by Uwais Alqadri on 29/10/24.
//

import SwiftUI
import CoreMotion

class CompassAssessmentPresenter: ObservableObject {
  @Published var state = State()
  private var motionManager = CMMotionManager()
  
  enum Action {
    case startUpdating
    case stopUpdating
    case success
    case failed
  }
  
  struct State {
    var heading: Double = 0.0
    var previousHeading: Double?
    var fullRotationCounter: Int = 0
    var hasCompletedFullRotation: Bool = false
    var progress: Double = 0.0
    var isTimerPaused: Bool = false
  }
  
  func send(_ action: Action) {
    switch action {
    case .startUpdating:
      guard motionManager.isDeviceMotionAvailable else { return }
      
      motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
      motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] data, error in
        guard let self = self, let data = data, error == nil else { return }
        
        let newHeading = atan2(data.magneticField.field.y, data.magneticField.field.x) * 180 / .pi
        let normalizedHeading = newHeading < 0 ? newHeading + 360 : newHeading
        
        if let previousHeading = self.state.previousHeading {
          if previousHeading > 300 && normalizedHeading < 60 {
            self.state.fullRotationCounter += 1
          }
          
          if self.state.fullRotationCounter >= 1 {
            self.state.hasCompletedFullRotation = true
            send(.success)
          }
        }
        
        state.heading = normalizedHeading
        state.previousHeading = normalizedHeading
        state.progress = normalizedHeading / 360.0
      }
      
    case .stopUpdating:
      motionManager.stopDeviceMotionUpdates()
      
    case .success:
      Notifications.didCompassPassed.post(with: true)
      
    case .failed:
      Notifications.didCompassPassed.post(with: false)
      
    }
  }
}
