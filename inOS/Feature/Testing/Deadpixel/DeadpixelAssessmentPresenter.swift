//
//  DeadpixelFunctionalityPresenter.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import Foundation

@MainActor
class DeadpixelAssessmentPresenter: ObservableObject {

  @Published var state = State()

  func send(_ action: Action) {
    switch action {
    case .success:
      Notifications.didDeadpixelPassed.post(with: true)

    case .failed:
      Notifications.didDeadpixelPassed.post(with: false)

    case .setTimer:
      setTimer()
    }
  }
}

extension DeadpixelAssessmentPresenter {
  private func setTimer() {
    var timer: Timer?
    timer = Timer.scheduledTimer(withTimeInterval: state.totalCount, repeats: true) { @MainActor _ in
      if self.state.index < 4 {
        self.state.index += 1
      } else {
        self.send(.success)
        timer?.invalidate()
      }
    }
  }
}
