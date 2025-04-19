//
//  FunctionalityPresenter+StateAction.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 03/09/24.
//

import Foundation
import DeviceKit
import inCore

extension Assessment {
  static func allEnabledCases(remoteConfig: RemoteConfig) -> [Assessment] {
    let enabledCases: [Assessment] = allCases.compactMap { assessment in
      if !remoteConfig.isAssessmentEnabled(assessment) {
        return nil
      }
      if Device.current.isPad && [.vibration, .nfc, .cellular, .wirelessCharging].contains(assessment) {
        return nil
      }
      if Device.current.hasActionButton && [.silentSwitch].contains(assessment) {
        return nil
      }
      return assessment
    }
    
    return enabledCases.isEmpty ? allCases : enabledCases
  }
}

extension FunctionalityPresenter {
  struct State {
    var currentAssessment: CurrentAssessment = .empty
    var isAssessmentPassed = false
    var isTouchscreenPresented = false
    var isCameraPresented = false
    var isDeadpixelPresented = false
    var isCompassPresented = false
    var isSpecificationPresented = false
    var isBenchmarkPresented = false
    var isMultitouchPresented = false
    var isSerialRunning = false
    var isConfirmSerial = false
    var isNeedConfirmAssessment = false
    var isRunAssessmentConfirmed = false
    var isIntroduction = true
    var inputValue = ""
    var randomCount = 0
    var scrollIndex: Double = 0
    var passedAssessments: [Assessment: Bool] = [:]
    var assessmentFrame: [Assessment: CGRect] = [:]
    var deviceStatuses: [Status] = []
    var deviceStatus: Status {
      .init(.phone, value: Device.current.safeDescription)
    }
    let remoteConfig = RemoteConfig()
    var allAssessments: [Assessment] {
      Assessment.allEnabledCases(remoteConfig: remoteConfig)
    }
    var undelayedAssessments: [Assessment] = [.volumeUp, .volumeDown, .silentSwitch, .connector, .touchscreen, .compass]
    var needConfirmationAssessments: [Assessment] = [.camera, .touchscreen, .multitouch, .cellular, .wifi, .compass, .deadpixel]
    var toastContents: (finished: String, testing: String) {
      let assessment = currentAssessment.assessment
      return (assessment.finishedMessage, assessment.testingMessage)
    }
  }
  
  struct CurrentAssessment: Equatable {
    var assessment: Assessment
    var isTesting: Bool
    var isRunning: Bool
    
    static var empty: Self = .init(.cpu, false, false)
    
    init(_ assessment: Assessment, _ isTesting: Bool, _ isRunning: Bool) {
      self.assessment = assessment
      self.isTesting = isTesting
      self.isRunning = isRunning
    }
  }
  
  enum Action {
    case loadStatus
    case start(assessment: Assessment)
    case showConfirmSerial(_ state: Bool)
    case runSerial
    case terminateSerial
    case shouldShow(assessment: Assessment, isPresented: Bool)
    case runConfirmation(_ state: Bool)
  }
}

extension FunctionalityPresenter {
  struct Status: Equatable {
    let spec: Specs
    let value: String
    var isOther: Bool {
      return spec == .other && value == "More"
    }
    var isSettings: Bool {
      return spec == .settings && value == "Settings"
    }
    
    init(_ spec: Specs, value: String) {
      self.spec = spec
      self.value = value
    }

    enum Specs: Equatable, Hashable {
      case phone
      case cpu
      case memory
      case storage
      case battery
      case settings
      case other

      static func == (lhs: Specs, rhs: Specs) -> Bool {
        lhs.description == rhs.description
      }

      var description: String { String(describing: Self.self) }

      var icon: String {
        switch self {
        case .phone:
          switch true {
          case !Device.current.isWithoutHomeButton && !Device.current.isPad:
            return "iphone.homebutton"
          case Device.current.isPad:
            return "ipad"
          default:
            return "iphone"
          }
        case .cpu:
          return "cpu"
        case .memory:
          return "memorychip"
        case .storage:
          return "internaldrive"
        case .battery:
          return "battery.0"
        case .other:
          return "chevron.up.square.fill"
        case .settings:
          return "gear"
        }
      }
    }
  }
}

extension FunctionalityPresenter {
  enum GridSide: CaseIterable {
    case right, left
  }
  
  func splitForGrid(side: GridSide) -> [Assessment] {
    var firstColumn: [Assessment] = []
    var secondColumn: [Assessment] = []
    
    state.allAssessments.enumerated().forEach { index, item in
      if index % 2 == 0 {
        firstColumn.append(item)
      } else {
        secondColumn.append(item)
      }
    }
    
    switch side {
    case .right:
      return firstColumn
    case .left:
      return secondColumn
    }
  }
}
