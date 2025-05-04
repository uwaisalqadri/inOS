//
//  ScreenFunctionalityView.swift
//  DeviceFunctionality
//
//  Created by Uwais Alqadri on 8/9/24.
//

import SwiftUI

struct ScreenFunctionalityView: View {
  @AppStorage(.persistence(key: .isDarkMode)) var isDarkMode: Bool = false
  @StateObject var presenter = ScreenFunctionalityPresenter()
  @StateObject var timerPresenter = TimerCountdownPresenter()

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 1) {
        ForEach(0..<presenter.state.rows, id: \.self) { row in
          HStack(spacing: 1) {
            ForEach(0..<presenter.state.columns, id: \.self) { column in
              Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(presenter.state.boxes[presenter.indexFor(row: row, column: column)])
                .gesture(
                  TapGesture().onEnded { _ in
                    presenter.send(.handleTap(
                      row: row,
                      column: column,
                      onResetTimer: {
                        timerPresenter.resetCountdown()
                      }
                    ))
                  }
                )
            }
          }
        }
      }
      .onAppear {
        presenter.send(.onAppear(darkmode: isDarkMode))
      }
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { gesture in
            presenter.send(.handleDragGesture(
              gesture: gesture,
              geometry: geometry,
              onUpdateTimer: {
                timerPresenter.isTimerPaused = true
                timerPresenter.updateCountdown()
              },
              onResetTimer: {
                timerPresenter.isTimerPaused = false
                timerPresenter.resetCountdown()
              }
            ))
          }
          .onEnded { _ in
            timerPresenter.isTimerPaused = false
          }
      )
    }
    .ignoresSafeArea(.all)
    .overlay(
      TimerCountdownText(
        presenter: timerPresenter,
        successCondition: presenter.state.boxes.allSatisfy({ $0 == presenter.state.touchedColor }),
        onSuccess: {
          presenter.send(.success)
        },
        onFailed: {
          presenter.send(.failed)
        }
      )
      .fontSize(96)
      .countdown(10)
    )
  }
}
