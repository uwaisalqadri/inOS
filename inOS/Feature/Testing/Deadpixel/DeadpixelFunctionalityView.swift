//
//  DeadpixelFunctionalityView.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import SwiftUI
import AlertToast

struct DeadpixelFunctionalityView: View {
  @StateObject var presenter: DeadpixelFunctionalityPresenter
  @StateObject private var timerPresenter = TimerCountdownPresenter()

  private let colors: [Color] = [
    Color(.redDeadPixel),
    Color(.greenDeadPixel),
    Color(.blueDeadPixel),
    .black,
    .white
  ]
  
  init() {
    _presenter = StateObject(
      wrappedValue: DeadpixelFunctionalityPresenter()
    )
  }

  var body: some View {
    ZStack {
      colors[presenter.state.index]
      TimerCountdownText(
        presenter: timerPresenter,
        successCondition: false,
        onSuccess: {},
        onFailed: {}
      )
      .countdown(Int(presenter.state.totalCount))
      .foregroundColor(colors[presenter.state.index] == .black ? .white : .black)
    }
    .edgesIgnoringSafeArea(.all)
    .onChange(of: presenter.state.index) { _ in
      timerPresenter.startCountdown(Int(presenter.state.totalCount))
    }
    .onAppear {
      presenter.send(.setTimer)
    }
    .onTapGesture(count: 2) {
      presenter.send(.failed)
    }
    .toast(
      isPresenting: .constant(true),
      duration: .infinity,
      tapToDismiss: true,
      offsetY: 60
    ) {
      AlertToast(
        displayMode: .hud,
        type: .regular,
        title: "Double tap if you spot any deadpixel"
      )
    }
  }
}
