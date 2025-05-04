//
//  FunctionalityPresenter+StateAction.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 03/09/24.
//

import Foundation
import DeviceKit
import inCore
import SwiftUI

extension AssessmentPresenter {
  struct State {
    var presentedAssessment: Assessment? = nil
    var serialState: SerialState = .idle
    var confirmationStatus: ConfirmationStatus = .none
    var isSpecificationPresented = false
    var isBenchmarkPresented = false
    var inputValue = ""
    var randomCount = 0
    var scrollIndex: Double = 0
    var passedAssessments = PassedAssessmentCollection()
    var assessmentFrame: [Assessment: CGRect] = [:]
    var deviceMetrics: [DeviceMetric] = []
    var remoteConfig = RemoteConfig()
    var currentAssessment: CurrentAssessment = .empty
    var deviceStatus: DeviceMetric = .phone(Device.current.safeDescription)
    var allAssessments: [Assessment] {
      Assessment.allEnabledCases(remoteConfig: remoteConfig)
    }
    var immediateAssessments: [Assessment] {
      allAssessments.filter { $0.mode == .immediate }
    }
    var confirmationRequiredAssessments: [Assessment] {
      allAssessments.filter { $0.mode == .needsConfirmation }
    }
    var toastContents: (finished: String, testing: String) {
      let assessment = currentAssessment.assessment
      return (assessment.finishedMessage, assessment.testingMessage)
    }
  }
  
  enum Action {
    case loadStatus
    case start(from: Assessment)
    case terminate
    case skip
    case showConfirmSerial(_ state: Bool)
    case runSerial
    case present(assessment: Assessment?)
    case runConfirmed(_ state: Bool)
  }
}

extension AssessmentPresenter {
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
