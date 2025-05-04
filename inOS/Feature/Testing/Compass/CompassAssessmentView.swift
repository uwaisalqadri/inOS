//
//  CompassAssessmentView.swift
//  inOS
//
//  Created by Uwais Alqadri on 29/10/24.
//

import SwiftUI

struct CompassAssessmentView: View {
  @StateObject private var presenter = CompassAssessmentPresenter()
  @StateObject private var timerPresenter = TimerCountdownPresenter()
  
  var body: some View {
    ZStack {
      VStack {
        Text("Rotate Full Circle")
          .font(.system(size: 20, weight: .bold))
          .frame(maxWidth: .infinity)
          .padding(.horizontal)
          .padding(.top, 40)

        TimerCountdownText(
          presenter: timerPresenter,
          successCondition: presenter.state.progress == 1.0,
          onSuccess: {
            presenter.send(.success)
          },
          onFailed: {
            presenter.send(.failed)
          }
        )
        .fontSize(50)
        .countdown(15)
        
        Spacer()
      }
      
      let height = UIScreen.main.bounds.width - 55
      CircularProgress(progress: $presenter.state.progress)
        .frame(width: height, height: height)
      
      Image(systemName: "arrow.up")
        .font(.system(size: 30))
        .foregroundColor(.blue)
        .rotationEffect(Angle(degrees: presenter.state.heading))
    }
    .onAppear {
      presenter.send(.startUpdating)
    }
    .onDisappear {
      presenter.send(.stopUpdating)
    }
  }
}

struct CircularProgress: View {
  @Binding var progress: Double
  
  var body: some View {
    ZStack {
      Circle()
        .stroke(Color.gray.opacity(0.1), lineWidth: 20)
      
      Circle()
        .trim(from: 0, to: CGFloat(progress))
        .stroke(Color.blue, lineWidth: 20)
        .rotationEffect(.degrees(-90))
        .animation(.easeInOut, value: progress)
    }
  }
}
