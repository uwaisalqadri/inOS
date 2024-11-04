//
//  TimerCountdownText.swift
//  inOS
//
//  Created by Uwais Alqadri on 30/10/24.
//

import SwiftUI

struct TimerCountdownText: View {
  @ObservedObject var presenter: TimerCountdownPresenter
  
  var countdown: Int {
    presenter._countdownValue
  }
  
  init(
    presenter: TimerCountdownPresenter,
    successCondition: Bool,
    onSuccess: @escaping () -> Void,
    onFailed: @escaping () -> Void
  ) {
    presenter.successCondition = successCondition
    presenter.onSuccess = onSuccess
    presenter.onFailed = onFailed
    self.presenter = presenter
  }
  
  var body: some View {
    Text("\(countdown)")
      .font(.system(size: presenter.fontSize, weight: .bold))
      .opacity(0.4)
      .onDisappear {
        presenter.timer?.invalidate()
      }
  }
}

extension TimerCountdownText {
  func countdown(_ value: Int) -> some View {
    self.onAppear {
      presenter.startCountdown(value)
    }
  }
  
  func fontSize(_ size: CGFloat) -> Self {
    let newSelf = self
    newSelf.presenter.fontSize = size
    return newSelf
  }
}

class TimerCountdownPresenter: ObservableObject {
  private var initialCountdown: Int = 0
  var fontSize: CGFloat = 96
  var successCondition: Bool = false
  
  @Published private(set) var _countdownValue: Int = 10
  @Published var timer: Timer?
  @Published var isTimerPaused: Bool = false
  
  var onSuccess: (() -> Void)?
  var onFailed: (() -> Void)?
  
  func resetCountdown() {
    startCountdown(initialCountdown)
  }
  
  func startCountdown(_ countdown: Int) {
    initialCountdown = countdown
    _countdownValue = countdown
    
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
      self.updateCountdown()
    }
  }
  
  func updateCountdown() {
    if !isTimerPaused {
      _countdownValue -= 1
      
      if _countdownValue == 0 {
        timer?.invalidate()
        onFailed?()
      }
      
      if successCondition {
        timer?.invalidate()
        onSuccess?()
      }
    }
  }
}
