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
import inCore

@MainActor
class FunctionalityPresenter: ObservableObject {

  @Published var state = State()
  private var assessmentTask: Task<Void, Never>?
  private var batteryUpdater: Timer?

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

    case let .showConfirmSerial(bool):
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
      state.currentAssessment.isTesting = false
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
      
    case let .runConfirmation(bool):
      if bool {
        state.isRunAssessmentConfirmed = true
        state.isNeedConfirmAssessment = false
      } else {
        state.isRunAssessmentConfirmed = false
        state.isNeedConfirmAssessment = false
      }
    }
  }
}

extension FunctionalityPresenter {
  func startAssessmentsSerialized() async {
    withAnimation { state.isSerialRunning = true }

    for assessment in Assessment.allEnabledCases(remoteConfig: state.remoteConfig) {
      await beginAssessment(for: assessment, isSerial: true)
      if Task.isCancelled { break }
    }

    withAnimation { state.isSerialRunning = false }
  }

  func beginAssessment(for assessment: Assessment, isSerial: Bool) async {
    withAnimation(.easeIn) {
      state.currentAssessment = CurrentAssessment(assessment, !assessment.testingMessage.isEmpty, true)
    }
    
    state.isAssessmentPassed = false
    state.isSerialRunning = true

    do {
      if !state.undelayedAssessments.contains(assessment) {
        try await Task.sleep(nanoseconds: 2_000_000_000)
      }
      
      if state.needConfirmationAssessments.contains(assessment) {
        state.isNeedConfirmAssessment = true
        
        while state.isNeedConfirmAssessment {
          try await Task.sleep(nanoseconds: 100_000_000)
        }
        
        if !state.isRunAssessmentConfirmed {
          send(.terminateSerial)
          return
        }
      }
      
      for try await isAssessmentPassed in streamAssessment(for: assessment) {
        withAnimation(.easeOut) {
          state.currentAssessment = CurrentAssessment(assessment, false, false)
          state.isAssessmentPassed = isAssessmentPassed
        }
        state.passedAssessments[assessment] = isAssessmentPassed
      }
      
    } catch {
      state.isAssessmentPassed = false
      state.passedAssessments[assessment] = false
    }
    
    state.isSerialRunning = false
    
    UserDefaults.standard.set(state.passedAssessments.map {
      AssessmentPersisted(assessmentKey: $0.key.rawValue, isPassed: $0.value)
    }.toJSON(), forKey: "passed_assessments")

    if isSerial {
      state.scrollIndex += 0.8
    }
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
  
  private func loadDeviceStatus() {
    state.deviceStatuses = [
      Status(.cpu, value: "-"),
      Status(.memory, value: "-"),
      Status(.storage, value: "-"),
      Status(.battery, value: "-"),
      Status(.other, value: "More")
    ]
    
    if let cpu = drivers[.device]?.assessments[.cpu] as? CPUInformation {
      state.deviceStatuses[0] = Status(.cpu, value: cpu.frequency ?? "-")
    }
    
    drivers[.device]?.startAssessment(for: .storage) { [drivers] in
      if let storage = drivers[.device]?.assessments[.storage] as? Storage {
        self.state.deviceStatuses[1] = Status(.memory, value: storage.totalRAM ?? "-")
        self.state.deviceStatuses[2] = Status(.storage, value: storage.totalSpace ?? "-")
      }
    }
    
    batteryUpdater = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      Task { @MainActor in
        guard let self else { return }
        self.drivers[.power]?.startAssessment(for: .batteryStatus) {
          if let battery = self.drivers[.power]?.assessments[.batteryStatus] as? Battery {
            self.state.deviceStatuses[3] = Status(.battery, value: "~\(battery.percentage?.toPercentage() ?? "-")")
          }
        }
      }
    }
        
    if let string = UserDefaults.standard.string(forKey: "passed_assessments") {
      AssessmentPersisted.fromJSON(string)?.forEach {
        if let assessment = Assessment(rawValue: $0.assessmentKey) {
          state.passedAssessments[assessment] = $0.isPassed
        }
      }
    }
  }
  
  func isFunctionalityPresenting(for functions: [Assessment]) -> Binding<Bool> {
    return Binding(
      get: {
        functions.contains {
          self.state.currentAssessment == CurrentAssessment($0, true, true)
        }
      },
      set: { value in
        functions.forEach {
          self.state.currentAssessment = CurrentAssessment($0, value, value)
        }
      }
    )
  }
}
