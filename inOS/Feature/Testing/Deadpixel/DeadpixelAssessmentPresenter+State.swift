//
//  DeadpixelFunctionalityPresenter+StateAction.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import Foundation

extension DeadpixelAssessmentPresenter {
  struct State {
    var index = 0
    var isDialogShown = false
    var retryCount = 3
    var totalCount: Double = 5
  }

  enum Action {
    case success
    case failed
    case setTimer
  }
}
