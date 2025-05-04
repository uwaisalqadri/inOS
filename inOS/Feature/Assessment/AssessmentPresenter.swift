//
//  AssessmentPresenter.swift
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
class AssessmentPresenter: ObservableObject {

  @Published var state = State()
  var assessmentTask: Task<Void, Never>?
  var batteryUpdater: Timer?
  var cancellables = Set<AnyCancellable>()

  lazy var drivers: [AssessmentTester.AssessmentDriverType: AssessmentDriver] = {
    let types: [AssessmentTester.AssessmentDriverType] = [.physical, .device, .connectivity, .power]
    return Dictionary(uniqueKeysWithValues: types.map { type in
      (type, AssessmentTester(driver: type).driver)
    })
  }()

  func send(_ action: Action) {
    switch action {
    case .loadStatus:
      loadDeviceStatus()
      
    case let .start(assessment):
      assessmentTask = Task {
        await beginAssessment(for: assessment, isSerial: false)
      }
      
    case .terminate:
      assessmentTask?.cancel()
      assessmentTask = nil
      state.serialState = .terminated
      state.currentAssessment.phase = .idle
      state.confirmationStatus = .none
      
    case .skip:
      skipAssessment()

    case let .showConfirmSerial(bool):
      state.serialState = bool ? .confirming : .idle

    case .runSerial:
      state.passedAssessments.removeAll()
      assessmentTask = Task {
        await startAssessmentsSerialized(from: .cpu)
      }
      
    case let .present(assessment):
      state.presentedAssessment = assessment
      
    case let .runConfirmed(bool):
      state.confirmationStatus = .needed
      if bool {
        state.confirmationStatus = .confirmed
      } else {
        send(.terminate)
      }
    }
  }
}

extension AssessmentPresenter {
  func startAssessmentsSerialized(from assessment: Assessment) async {
    state.serialState = .running

    let startingIndex = state.allAssessments.firstIndex(of: assessment) ?? 0
    for index in startingIndex..<state.allAssessments.count {
      await beginAssessment(for: state.allAssessments[index], isSerial: true)
      if Task.isCancelled { break }
    }
    
    state.serialState = .idle
  }
  
  func skipAssessment() {
    send(.terminate)
    guard let index = state.allAssessments.index(for: state.currentAssessment.assessment) else { return }
    assessmentTask = Task {
      await startAssessmentsSerialized(from: state.allAssessments[index + 1])
    }
  }

  func beginAssessment(for assessment: Assessment, isSerial: Bool) async {
    withAnimation(.easeIn) {
      state.currentAssessment = CurrentAssessment(assessment, phase: .running)
    }
    
    do {
      if !state.immediateAssessments.contains(assessment) {
        try await Task.sleep(for: .seconds(2))
      }
      
      if state.confirmationRequiredAssessments.contains(assessment) {
        state.confirmationStatus = .needed
        while state.confirmationStatus == .needed {
          try await Task.sleep(for: .seconds(1))
        }
      }
      
      for try await isAssessmentPassed in streamAssessment(for: assessment) {
        withAnimation(.easeOut) {
          state.currentAssessment = CurrentAssessment(assessment, phase: isAssessmentPassed ? .idle : .running)
        }
        state.passedAssessments[assessment] = isAssessmentPassed
      }
    } catch {
      state.passedAssessments[assessment] = false
    }
                
    UserDefaults.standard.set(
      state.passedAssessments
        .asPersisted()
        .toJSON(),
      forKey: .persistence(key: .passedAssessments)
    )

    if isSerial {
      state.scrollIndex += 0.8
    }
  }
  
  private func loadDeviceStatus() {
    var settingsLabel: String {
      if #available(iOS 17.0, *) {
        return "Settings"
      } else {
        return "More"
      }
    }
    
    state.deviceMetrics = [
      .cpu("-"),
      .memory("-"),
      .storage("-"),
      .battery("-"),
      .settings(settingsLabel)
    ]
    
    if let cpu = drivers[.device]?.assessments[.cpu] as? CPUInformation {
      state.deviceMetrics[0] = .cpu(cpu.frequency ?? "-")
    }
    
    drivers[.device]?.startAssessment(for: .storage) { [drivers] in
      if let storage = drivers[.device]?.assessments[.storage] as? Storage {
        self.state.deviceMetrics[1] = .memory(storage.totalRAM ?? "-")
        self.state.deviceMetrics[2] = .storage(storage.totalSpace ?? "-")
      }
    }
    
    batteryUpdater = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      Task { @MainActor in
        guard let self else { return }
        self.drivers[.power]?.startAssessment(for: .batteryStatus) {
          if let battery = self.drivers[.power]?.assessments[.batteryStatus] as? Battery {
            self.state.deviceMetrics[3] = .battery("~\(battery.percentage?.toPercentage() ?? "-")")
          }
        }
      }
    }
        
    if let string = UserDefaults.standard.string(forKey: .persistence(key: .passedAssessments)) {
      AssessmentPersisted.fromJSON(string)?.forEach {
        if let assessment = Assessment(rawValue: $0.assessmentKey) {
          state.passedAssessments[assessment] = $0.isPassed
        }
      }
    }
  }
  
  func isAssessmentConfirmationNeeded() -> Binding<Bool>{
    return Binding<Bool>(
      get: { self.state.confirmationStatus == .needed },
      set: { run in self.state.confirmationStatus = run ? .needed : .none }
    )
  }
  
  func isSerialConfirmationNeeded() -> Binding<Bool> {
    return Binding<Bool>(
      get: { self.state.serialState == .confirming },
      set: { run in self.state.serialState = run ? .confirming : .idle }
    )
  }
  
  func hasAssessmentTesting(within assessments: [Assessment]) -> Binding<Bool> {
    return Binding(
      get: {
        assessments.contains {
          self.state.currentAssessment == CurrentAssessment($0, phase: .running)
        }
      },
      set: { isPresenting in
        assessments.forEach {
          self.state.currentAssessment = CurrentAssessment($0, phase: isPresenting ? .running : .idle)
        }
      }
    )
  }
}
