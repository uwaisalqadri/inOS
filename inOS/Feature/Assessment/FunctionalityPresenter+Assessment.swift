//
//  FunctionalityPresenter+Assessment.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/05/25.
//

import inCore
import Combine
import SwiftUI

extension FunctionalityPresenter {
  @MainActor
  func streamAssessment(for assessment: Assessment) -> AsyncThrowingStream<Bool, Error> {
    return AsyncThrowingStream { continuation in
      switch assessment {
      case .cpu:
        if let cpu = drivers[.device]?.assessments[assessment] as? CPUInformation {
          continuation.yield(cpu.model?.isEmpty != true)
          continuation.finish()
        }

      case .storage:
        drivers[.device]?.startAssessment(for: assessment) { [drivers] in
          if let storage = drivers[.device]?.assessments[assessment] as? Storage {
            continuation.yield(storage.totalSpace?.isEmpty != true)
            continuation.finish()
          }
        }

      case .batteryStatus:
        drivers[.power]?.startAssessment(for: assessment) { [drivers] in
          if let battery = drivers[.power]?.assessments[assessment] as? Battery {
            continuation.yield(battery.technology?.isEmpty != true)
            continuation.finish()
          }
        }

      case .jailbreak:
        continuation.yield(drivers[.device]?.hasAssessmentPassed[assessment] ?? false)
        continuation.finish()

      case .volumeUp, .volumeDown, .biometric, .proximity, .accelerometer, .microphone:
        drivers[.physical]?.startAssessment(for: assessment) { [drivers] in
          if let reason = drivers[.physical]?.assessments[.biometric] as? BiometricFailedReason {
            continuation.finish(throwing: reason)
            return
          }

          if let failure = drivers[.physical]?.assessments[.microphone] as? PermissionFailed {
            continuation.finish(throwing: failure)
            return
          }

          continuation.yield(self.drivers[.physical]?.hasAssessmentPassed[assessment] ?? false)
          continuation.finish()
          drivers[.physical]?.stopAssessment(for: assessment)
        }

      case .silentSwitch:
        drivers[.physical]?.startAssessment(for: assessment) { [drivers] in
          continuation.yield(self.drivers[.physical]?.hasAssessmentPassed[assessment] ?? false)
          continuation.finish()
          drivers[.physical]?.stopAssessment(for: assessment)
        }

      case .powerButton:
        let backgroundPublisher = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
        let foregroundPublisher = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
        var isTurnedOff = false
        
        backgroundPublisher
          .map { _ in true }
          .sink { isTriggered in
            isTurnedOff = isTriggered
          }
          .store(in: &cancellables)
        
        foregroundPublisher
          .sink { _ in
            continuation.yield(isTurnedOff)
            continuation.finish()
            isTurnedOff = false
          }
          .store(in: &cancellables)

      case .camera:
        send(.present(assessment: assessment))
        
        NotificationCenter.default.publisher(for: Notifications.didCameraPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.present(assessment: nil))
          }
          .store(in: &cancellables)

      case .touchscreen:
        send(.present(assessment: assessment))
        
        NotificationCenter.default.publisher(for: Notifications.didTouchScreenPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.present(assessment: nil))
          }
          .store(in: &cancellables)

      case .cellular, .wifi, .bluetooth, .gps:
        drivers[.connectivity]?.startAssessment(for: assessment) { [drivers] in
          continuation.yield(drivers[.connectivity]?.hasAssessmentPassed[assessment] ?? false)
          continuation.finish()
          drivers[.connectivity]?.stopAssessment(for: assessment)
        }

      case .homeButton:
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
          .map { _ in true }
          .sink { isTriggered in
            continuation.yield(isTriggered)
            continuation.finish()
          }
          .store(in: &cancellables)

      case .mainSpeaker, .earSpeaker, .vibration:
        drivers[.physical]?.startAssessment(for: assessment) { value in
          guard let number = value as? Int else { return }
          self.state.randomCount = number
        }

        NotificationCenter.default.publisher(for: Notifications.didInputConfirmation)
          .sink { notification in
            guard let number = notification.object as? Int else { return }
            continuation.yield(self.state.randomCount == number)
            continuation.finish()
            self.drivers[.physical]?.stopAssessment(for: assessment)
          }
          .store(in: &cancellables)

      case .deadpixel:
        send(.present(assessment: assessment))

        NotificationCenter.default.publisher(for: Notifications.didDeadpixelPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.present(assessment: nil))
          }
          .store(in: &cancellables)

      case .rotation:
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
          .map { _ in true }
          .sink { isTriggered in
            continuation.yield(isTriggered)
            continuation.finish()
          }
          .store(in: &cancellables)

      case .multitouch:
        send(.present(assessment: assessment))

        NotificationCenter.default.publisher(for: Notifications.didMultitouchPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.present(assessment: nil))
          }
          .store(in: &cancellables)

      case .barometer:
        drivers[.physical]?.startAssessment(for: assessment) { [drivers] in
          if drivers[.physical]?.assessments[assessment] is Barometer {
            continuation.yield(true)
          } else {
            continuation.yield(false)
          }
          continuation.finish()
          drivers[.physical]?.stopAssessment(for: assessment)
        }
        
      case .compass:
        send(.present(assessment: assessment))

        NotificationCenter.default.publisher(for: Notifications.didCompassPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.present(assessment: nil))
          }
          .store(in: &cancellables)
        
      case .connector:
        drivers[.power]?.startAssessment(for: assessment) { [drivers] in
          if let isCharging = drivers[.power]?.hasAssessmentPassed[assessment] {
            continuation.yield(isCharging)
            continuation.finish()
          }
        }
        
      case .wirelessCharging:
        drivers[.power]?.startAssessment(for: assessment) { [drivers] in
          if let isCharging = drivers[.power]?.hasAssessmentPassed[assessment] {
            continuation.yield(isCharging)
            continuation.finish()
          }
        }

      case .torch:
        drivers[.physical]?.startAssessment(for: assessment) { [drivers] in
          if let isTorching = drivers[.physical]?.assessments[assessment] as? Bool {
            continuation.yield(isTorching)
            continuation.finish()
          }
        }
        
      case .nfc:
        drivers[.physical]?.startAssessment(for: assessment) { [drivers] in
          if let isCardRead = drivers[.physical]?.assessments[assessment] as? Bool {
            continuation.yield(isCardRead)
            continuation.finish()
          }
        }

      }
    }
  }
}

