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
  @State private var isCircle1Pressing = false
  @State private var isCircle2Pressing = false
  
  @StateObject private var timerPresenter = TimerCountdownPresenter()
  
  var isPassed: Bool {
    isCircle1Pressing && isCircle2Pressing &&
    [circle1Color, circle2Color] == [.green, .yellow]
  }
  
  var body: some View {
    VStack {
      Spacer()
      Text("Touch both circles 3 times simultaneously")
        .font(.headline)
        .padding()
      
      HStack {
        Circle()
          .fill(circle1Color)
          .frame(width: 100, height: 100)
          .scaleEffect(isCircle1Pressing ? 0.9 : 1.0)
          .animation(.easeInOut(duration: 0.2), value: isCircle1Pressing)
          .onLongPressGesture(minimumDuration: 4.0) {
            circle1Color = .red
          } onPressingChanged: { isPressing in
            circle1Color = .green
            isCircle1Pressing = isPressing
            checkIfBothTouched()
            timerPresenter.isTimerPaused = isPressing
          }
        
        Spacer()
        
        Circle()
          .fill(circle2Color)
          .frame(width: 100, height: 100)
          .scaleEffect(isCircle2Pressing ? 0.9 : 1.0)
          .animation(.easeInOut(duration: 0.2), value: isCircle2Pressing)
          .onLongPressGesture(minimumDuration: 4.0) {
            circle2Color = .blue
          } onPressingChanged: { isPressing in
            circle2Color = .yellow
            isCircle2Pressing = isPressing
            checkIfBothTouched()
            timerPresenter.isTimerPaused = isPressing
          }
      }.padding([.top, .horizontal], 20)
      
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
    delay(bySeconds: 2.0) {
      if isPassed {
        Notifications.didMultitouchPassed.post(with: isPassed)
      }
    }
  }
}

extension MultitouchFunctionalityView {
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
