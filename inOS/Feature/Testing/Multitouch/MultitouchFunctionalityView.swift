//
//  MultitouchFunctionalityView.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/11/24.
//

import SwiftUI

struct MultitouchFunctionalityView: View {
  @State private var circle1Color = Color.red
  @State private var circle2Color = Color.blue
  @State private var message = "Touch both circles 3 times simultaneously"
  @State private var touchCount = 0.0
  @State private var combinations: [Side] = []

  @StateObject private var timerPresenter = TimerCountdownPresenter()

  var isPassed: Bool {
    touchCount == 3.0 && combinations == [.left, .right, .left, .right, .left, .right]
  }

  var body: some View {
    VStack {
      Spacer()

      Text(message)
        .font(.headline)
        .padding()

      HStack {
        Button(action: {
          touchCount += 0.5
          combinations.append(.left)
          checkIfBothTouched()
          if touchCount == 1.5 {
            circle1Color = .green
          }
        }) {
          Circle()
            .fill(circle1Color)
            .frame(width: 100, height: 100)
        }

        Button(action: {
          touchCount += 0.5
          combinations.append(.right)
          checkIfBothTouched()
          if touchCount == 3.0 {
            circle2Color = .yellow
          }
        }) {
          Circle()
            .fill(circle2Color)
            .frame(width: 100, height: 100)
        }
      }

      Spacer()

      TimerCountdownText(
        presenter: timerPresenter,
        successCondition: isPassed,
        onSuccess: {
          Notifications.didMultitouchPassed.post(with: true)
        },
        onFailed: {
          Notifications.didMultitouchPassed.post(with: false)
        }
      )
      .countdown(10)
      .padding(.bottom, 18)

    }
  }

  private func checkIfBothTouched() {
    print("TOUCHED \(touchCount)")
    if isPassed {
      message = "Both circles touched!"
      Notifications.didMultitouchPassed.post(with: true)
    }
  }

  enum Side {
    case right
    case left
  }
}

struct MultitouchView_Previews: PreviewProvider {
  static var previews: some View {
    MultitouchFunctionalityView()
  }
}
