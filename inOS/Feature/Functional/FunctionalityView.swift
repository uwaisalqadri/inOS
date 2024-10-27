//
//  FunctionalityView.swift
//  SpecAsessment
//
//  Created by Uwais Alqadri on 13/12/23.
//

import SwiftUI
import DeviceKit
import CoreMotion
import AlertToast

struct FunctionalityView: View {

  @StateObject var presenter: FunctionalityPresenter
  @AppStorage("isIntroduction") var isIntroduction: Bool = true
  @AppStorage("isDarkMode") var isDarkMode: Bool = false
  
  init() {
    _presenter = StateObject(
      wrappedValue: FunctionalityPresenter()
    )
  }

  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing) {
        ScrollView {
          VStack {
            DashboardStatusView(
              deviceStatuses: presenter.state.deviceStatuses,
              isSpecificationPresented: $presenter.state.isSpecificationPresented
            ).padding(.bottom, 6)
            
            HStack(alignment: .top) {
              ForEach(FunctionalityPresenter.GridSide.allCases, id: \.self) { side in
                VStack(spacing: 12) {
                  ForEach(Array(presenter.splitForGrid(side: side).enumerated()), id: \.offset) { _, item in
                    let isPassed = presenter.state.passedAssessments[item]
                    FunctionalityRow(item: item, isPassed: isPassed, onTestFunction: {
                      presenter.send(.start(assessment: item))
                    })
                    .contextMenu {
                      Button {
                        presenter.send(.start(assessment: item))
                      } label: { Label(item.title, systemImage: item.icon) }
                    }
                    .padding(.horizontal, 3)
                  }
                }
              }
            }
          }
          .padding(.horizontal, 12)
          .padding(.top, 30)
          .padding(.bottom, 40)
        }
        
        let rotation: Double = presenter.state.isSerialRunning ? 360 : 0
        Image(systemName: "goforward")
          .font(.system(size: 40))
          .foregroundColor(.blue)
          .rotationEffect(.degrees(rotation))
          .animation(
            presenter.state.isSerialRunning ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
            value: rotation
          )
          .padding(16)
          .background(Blur(style: .systemThinMaterial).clipShape(.circle))
          .padding(.trailing, 20)
          .padding(.bottom, 10)
          .opacity(presenter.state.isSerialRunning ? 1.0 : 0.0)
      }
      .onFirstAppear {
        presenter.send(.loadStatus)
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          let device = presenter.state.deviceStatus
          HStack(spacing: 4) {
            Image(systemName: device.spec.icon)
              .font(.system(size: 20))
              .foregroundColor(.blue)
            Text(device.value)
              .font(.system(size: 14, weight: .semibold))
          }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: {
            if presenter.state.isSerialRunning {
              presenter.send(.terminateSerial)
            } else {
              presenter.send(.shouldConfirmSerial(true))
            }
          }) {
            Image(systemName: presenter.state.isSerialRunning ? "stop" : "play")
              .font(.system(size: 20))
          }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: {
            isDarkMode.toggle()
            UIApplication.shared.windows.first?
              .rootViewController?
              .overrideUserInterfaceStyle = isDarkMode ? .dark : .light
          }) {
            Image(systemName: isDarkMode ? "sun.max" : "moon")
              .resizable()
              .scaleEffect(1)
          }
        }
      }
    }
    .sheet(isPresented: $isIntroduction) {
      IntroductionView(onStart: {
        isIntroduction = false
      })
    }
    .alert(isPresented: $presenter.state.isConfirmSerial) {
      serialConfirmAlert()
    }
    .fullScreenCover(isPresented: $presenter.state.isTouchscreenPresented) {
      ScreenFunctionalityView()
    }
    .fullScreenCover(isPresented: $presenter.state.isCameraPresented) {
      CameraFunctionalityView()
    }
    .fullScreenCover(isPresented: $presenter.state.isDeadpixelPresented) {
      DeadpixelFunctionalityView()
    }
    .toast(
      isPresenting: $presenter.state.currentAssessment.isRunning,
      duration: .infinity,
      tapToDismiss: true,
      offsetY: 60
    ) {
      AlertToast(
        displayMode: .hud,
        type: .regular,
        title: presenter.state.toastContents.testing
      )
    }
  }
  
  private func serialConfirmAlert() -> Alert {
    Alert(
      title: Text("Serial Tests"),
      message: Text("This is a serial tests, all test will automatically start one after another"),
      primaryButton: .default(Text("Start")) {
        presenter.send(.runSerial)
        presenter.send(.shouldConfirmSerial(false))
      },
      secondaryButton: .cancel()
    )
  }
}

struct FunctionalityView_Previews: PreviewProvider {
  static var previews: some View {
    FunctionalityView()
  }
}
