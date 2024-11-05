//
//  PhysicalAssessment.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 25/12/23.
//

import AVFoundation
import CoreMotion
import DeviceKit
import Foundation
import LocalAuthentication
import notify
import UIKit

public class PhysicalAssessment: NSObject, AssessmentDriver {
  private var motionManager = CMMotionManager()
  private var biometricAuth = BiometricAuthentication()
  
  private var currentMuteStatus: Bool?
  private var previousButtonTap = Date()
  private let minimumTapInterval = 0.3
  
  private var onProximityDetected: ((Bool) -> Void)?
  
  public override init() {
    super.init()
  }
  
  public var hasAssessmentPassed: [Assessment: Bool] {
    var results: [Assessment: Bool] = [:]
    
    let assessmentTypes: [Assessment] = [
      .volumeUp,
      .volumeDown,
      .silentSwitch,
      .biometric,
      .powerButton,
      .proximity,
      .accelerometer,
      .microphone,
      .earSpeaker,
      .mainSpeaker,
      .vibration,
      .torch
    ]
    
    for type in assessmentTypes {
      results[type] = assessments[type] as? Bool ?? false
    }
    
    return results
  }
  
  public var assessments: [Assessment: Any] = [
    .silentSwitch: false,
    .volumeUp: false,
    .volumeDown: false,
    .biometric: false,
    .powerButton: false,
    .proximity: false,
    .accelerometer: false,
    .microphone: false,
    .earSpeaker: false,
    .mainSpeaker: false,
    .vibration: false,
    .torch: false
  ]
  
  public func startAssessment(for type: Assessment, completion: (() -> Void)? = nil) {
    switch type {
    case .silentSwitch:
      Mute.shared = .init()
      Mute.shared.notify = { [weak self] muteStatus in
        guard let self = self else { return }
        if let currentMuteStatus = self.currentMuteStatus, currentMuteStatus != muteStatus {
          self.assessments[.silentSwitch] = true
          completion?()
        } else {
          self.currentMuteStatus = muteStatus
        }
      }
      
      Mute.shared.checkInterval = 1.0
      Mute.shared.alwaysNotify = true
      Mute.shared.check()
      
    case .volumeUp:
      VolumeButtonHandler.shared = .init()
      VolumeButtonHandler.shared.volumeUpHandler = { [weak self] in
        self?.assessments[.volumeUp] = true
        completion?()
      }
      
    case .volumeDown:
      VolumeButtonHandler.shared = .init()
      VolumeButtonHandler.shared.volumeDownHandler = { [weak self] in
        self?.assessments[.volumeDown] = true
        completion?()
      }
      
    case .biometric:
      if biometricAuth.canEvaluatePolicy() {
        biometricAuth.authenticateUser(type: Device.current.isTouchIDCapable ? .touchID : .faceID) { [weak self] reason, _ in
          guard let self = self, reason != .none else {
            self?.assessments[.biometric] = true
            completion?()
            return
          }
          
          self.assessments[.biometric] = reason
          completion?()
        }
      } else {
        self.assessments[.biometric] = BiometricFailedReason.biometricUnavailable
        completion?()
      }
      
    case .proximity:
      UIDevice.current.isProximityMonitoringEnabled = true
      if UIDevice.current.isProximityMonitoringEnabled {
        NotificationCenter.default.addObserver(self, selector: #selector(proximityChanged), name: UIDevice.proximityStateDidChangeNotification, object: nil)
      }
      onProximityDetected = { isDetected in
        self.assessments[.proximity] = isDetected
        UIDevice.current.isProximityMonitoringEnabled = false
        completion?()
      }
      
    case .microphone:
      checkMicrophonePermission(onGranted: {
        SpeechRecognizer.shared.startRecording()
        SpeechRecognizer.shared.voiceDetectedCallback = { error in
          if let error = error {
            if let failed = error as? PermissionFailed {
              self.assessments[.microphone] = failed
            } else {
              self.assessments[.microphone] = false
            }
          } else {
            self.assessments[.microphone] = true
          }
          completion?()
        }
      }, onDenied: {
        self.assessments[.microphone] = PermissionFailed.microphoneNotPermitted
        completion?()
      })
    case .accelerometer:
      self.assessments[.accelerometer] = motionManager.isAccelerometerAvailable
      completion?()
      
    case .torch:
      guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
        self.assessments[.torch] = false
        completion?()
        return
      }

      do {
        try device.lockForConfiguration()
        device.torchMode = .on
        self.assessments[.torch] = true

        delay(bySeconds: 1.5) {
          device.torchMode = .off
          device.unlockForConfiguration()
          completion?()
        }

      } catch {
        self.assessments[.torch] = error
        completion?()
      }

    default:
      break
    }
  }

  public func startAssessment(for type: Assessment, completion: ((Any?) -> Void)? = nil) {
    switch type {
    case .vibration:
      let randomCount = Int.random(in: 1...4)
      for index in stride(from: 1, through: randomCount, by: 1) {
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(index)) {
          if Device.current.isPad {
            let messagingAlertSoundId: SystemSoundID = 1003
            AudioServicesPlayAlertSoundWithCompletion(messagingAlertSoundId) {
              AudioServicesDisposeSystemSoundID(messagingAlertSoundId)
            }
          } else {
            AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate) {
              AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate)
            }
          }

          completion?(randomCount)
        }
      }
    case .mainSpeaker:
      let randomCount = Int.random(in: 1...4)
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        SpeechSynthesizer.shared.speak("\(randomCount)", useEarSpeaker: false)
        completion?(randomCount)
      }
    case .earSpeaker:
      let randomCount = Int.random(in: 1...4)
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        SpeechSynthesizer.shared.speak("\(randomCount)", useEarSpeaker: true)
        completion?(randomCount)
      }
    default:
      break
    }
  }

  public func stopAssessment(for type: Assessment) {
    switch type {
    case .volumeUp, .volumeDown:
      VolumeButtonHandler.shared = .init()
    case .silentSwitch:
      Mute.shared = .init()
    case .proximity:
      UIDevice.current.isProximityMonitoringEnabled = false
    case .microphone:
      SpeechRecognizer.shared.stopRecording()
    default:
      break
    }
  }
}

extension PhysicalAssessment {
  @objc func proximityChanged(_ notification: Notification) {
    onProximityDetected?(notification.object != nil)
  }
  
  func checkMicrophonePermission(onGranted: @escaping () -> Void, onDenied: @escaping () -> Void) {
    switch AVAudioSession.sharedInstance().recordPermission {
    case .granted:
      onGranted()
    case .undetermined:
      AVAudioSession.sharedInstance().requestRecordPermission { isGranted in
        DispatchQueue.main.async {
          if isGranted {
            onGranted()
          } else {
            onDenied()
          }
        }
      }
    default:
      onDenied()
    }
  }
}
