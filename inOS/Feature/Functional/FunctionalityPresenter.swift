//
//  FunctionalityPresenter.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 6/1/24.
//

import SwiftUI
import Combine
import DeviceKit
import AudioToolbox
import Foundation

@MainActor
class FunctionalityPresenter: ObservableObject {

  @Published var state = State()
  private var assessmentTask: Task<Void, Never>?

  private lazy var drivers: [AssessmentTester.AssessmentDriverType: AssessmentDriver] = {
    let types: [AssessmentTester.AssessmentDriverType] = [.physical, .device, .connectivity, .power]
    return Dictionary(uniqueKeysWithValues: types.map { type in
      (type, AssessmentTester(driver: type).driver)
    })
  }()

  private var cancellables = Set<AnyCancellable>()

  func send(_ action: Action) {
    switch action {
    case .loadStatus:
      loadDeviceStatus()
      
    case let .start(assessment):
      assessmentTask = Task {
        await beginAssessment(for: assessment, isSerial: false)
      }

    case let .shouldConfirmSerial(bool):
      state.isConfirmSerial = bool

    case .runSerial:
      state.passedAssessments.removeAll()
      assessmentTask = Task {
        await startAssessmentsSerialized()
      }
      
    case .terminateSerial:
      assessmentTask?.cancel()
      assessmentTask = nil
      state.isSerialRunning = false
      state.currentAssessment.isRunning = false
      state.scrollIndex = 0
      
    case let .shouldShow(assessment, isPresented):
      switch assessment {
      case .camera:
        state.isCameraPresented = isPresented
      case .deadpixel:
        state.isDeadpixelPresented = isPresented
      case .touchscreen:
        state.isTouchscreenPresented = isPresented
      case .compass:
        state.isCompassPresented = isPresented
      case .multitouch:
        state.isMultitouchPresented = isPresented
      default:
        break
      }
    }
  }
}

extension FunctionalityPresenter {
  func startAssessmentsSerialized() async {
    state.isSerialRunning = true

    for assessment in Assessment.allCases {
      await beginAssessment(for: assessment, isSerial: true)
      if Task.isCancelled { break }
    }

    state.isSerialRunning = false
  }

  func beginAssessment(for assessment: Assessment, isSerial: Bool) async {
    state.currentAssessment = (assessment, !assessment.testingMessage.isEmpty)
    state.isAssessmentPassed = false

    do {
      for try await isAssessmentPassed in streamAssessment(for: assessment) {
        state.currentAssessment = (assessment, false)
        state.isAssessmentPassed = isAssessmentPassed
        state.passedAssessments[assessment] = isAssessmentPassed
      }
    } catch {
      state.passedAssessments[assessment] = false
    }

    if isSerial {
      scrollWithFeedback()
      try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
    }
  }
  
  private func scrollWithFeedback() {
    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    state.scrollIndex += 0.5
  }

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
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
          .map { _ in true }
          .sink { isTriggered in
            let oldBrightness = UIScreen.main.brightness
            let newBrightness = max(0.01, min(1.0, oldBrightness + (oldBrightness <= 0.01 ? 0.01 : -0.01)))
            UIScreen.main.brightness = newBrightness
            continuation.yield(abs(oldBrightness - newBrightness) > 0.001)
            continuation.finish()
          }
          .store(in: &cancellables)

      case .camera:
        send(.shouldShow(assessment: assessment, isPresented: true))
        
        NotificationCenter.default.publisher(for: Notifications.didCameraPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.shouldShow(assessment: assessment, isPresented: false))
          }
          .store(in: &cancellables)

      case .touchscreen:
        send(.shouldShow(assessment: assessment, isPresented: true))
        
        NotificationCenter.default.publisher(for: Notifications.didTouchScreenPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.shouldShow(assessment: assessment, isPresented: false))
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
        send(.shouldShow(assessment: assessment, isPresented: true))

        NotificationCenter.default.publisher(for: Notifications.didDeadpixelPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.shouldShow(assessment: assessment, isPresented: false))
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
        send(.shouldShow(assessment: assessment, isPresented: true))

        NotificationCenter.default.publisher(for: Notifications.didMultitouchPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.shouldShow(assessment: assessment, isPresented: false))
          }
          .store(in: &cancellables)

      case .barometer:
        break
        
      case .compass:
        send(.shouldShow(assessment: assessment, isPresented: true))

        NotificationCenter.default.publisher(for: Notifications.didCompassPassed)
          .sink { notification in
            guard let isPassed = notification.object as? Bool else { return }
            continuation.yield(isPassed)
            continuation.finish()
            self.send(.shouldShow(assessment: assessment, isPresented: false))
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

      }
    }
  }
  
  private func loadDeviceStatus() {
    state.deviceStatuses.removeAll()
    
    if let cpu = drivers[.device]?.assessments[.cpu] as? CPUInformation {
      state.deviceStatuses.append(.init(.cpu, value: cpu.frequency ?? "-"))
    }
    
    drivers[.device]?.startAssessment(for: .storage) { [drivers] in
      if let storage = drivers[.device]?.assessments[.storage] as? Storage {
        self.state.deviceStatuses.append(.init(.memory, value: storage.totalRAM ?? "-"))
        self.state.deviceStatuses.append(.init(.storage, value: storage.totalSpace ?? "-"))
      }
    }
    
    drivers[.power]?.startAssessment(for: .batteryStatus) { [drivers] in
      if let battery = drivers[.power]?.assessments[.batteryStatus] as? Battery {
        self.state.deviceStatuses.append(.init(.battery(percentage: battery.percentage ?? 0.0), value: battery.percentage?.toPercentage() ?? "-"))
      }
    }
    
    state.deviceStatuses.append(.init(.other, value: "Others"))
    
    if let passedAssessments = UserDefaults.standard.dictionary(forKey: "passed_assessments") as? [Assessment: Bool] {
      state.passedAssessments = passedAssessments
    }
  }
}
