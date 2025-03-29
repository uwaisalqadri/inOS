//
//  FunctionalityView.swift
//  SpecAsessment
//
//  Created by Uwais Alqadri on 13/12/23.
//

import SwiftUI
import DeviceKit
import CoreMotion
import Combine
import AlertToast
import inCore

struct FunctionalityView: View {

  @StateObject private var presenter: FunctionalityPresenter
  @AppStorage("isDarkMode") private var isDarkMode: Bool = false
  @Environment(\.presentationMode) var presentationMode
  
  init() {
    UIScrollView.appearance().bounces = false
    _presenter = StateObject(
      wrappedValue: FunctionalityPresenter()
    )
  }

  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing) {
        ScrollViewReader { proxy in
          ScrollView(.vertical) {
            VStack(spacing: 12) {
              DashboardStatusView(
                deviceStatuses: presenter.state.deviceStatuses,
                isSpecificationPresented: $presenter.state.isSpecificationPresented
              )
              
              HStack(alignment: .top, spacing: 12) {
                ForEach(FunctionalityPresenter.GridSide.allCases, id: \.self) { side in
                  VStack(spacing: 12) {
                    ForEach(Array(presenter.splitForGrid(side: side).enumerated()), id: \.offset) { index, item in
                      let isPassed = presenter.state.passedAssessments[item]
                      let currentAssessment = presenter.state.currentAssessment
                      FunctionalityRow(
                        item: item,
                        isTesting: currentAssessment.isRunning && currentAssessment.assessment != item,
                        isPassed: isPassed,
                        onTestFunction: {
                          presenter.send(.start(assessment: item))
                        }
                      )
                      .id(Double(index))
                      .contextMenu {
                        Button {
                          presenter.send(.start(assessment: item))
                        } label: { Label(item.title, systemImage: item.icon) }
                      }
                    }
                  }
                }
              }
            }
            .padding(.horizontal, 12)
            .padding(.top, 20)
            .padding(.bottom, 40)
          }
          .onChange(of: presenter.state.scrollIndex) { index in
            withAnimation {
              proxy.scrollTo(index)
            }
          }
          .navigation(isPresented: $presenter.state.isSpecificationPresented) {
            SpecificationView()
          }
          .navigation(isPresented: $presenter.state.isBenchmarkPresented) {
            BenchmarkView()
          }
        }
        
        ActivityIndicator(style: .large)
          .padding(16)
          .background(
            Blur(style: .systemThinMaterial)
              .clipShape(.rect(cornerRadius: Theme.current.cornerRadius))
          )
          .padding(.trailing, 20)
          .padding(.bottom, 10)
          .opacity(presenter.state.isSerialRunning ? 1.0 : 0.0)
      }
      .onFirstAppear {
        presenter.send(.loadStatus)
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          DeviceView(
            isShimmer: true,
            onTapGesture: {
              presenter.state.isBenchmarkPresented = true
            }
          )
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: {
            isDarkMode.toggle()
            UIApplication.shared.windows.first?
              .rootViewController?
              .overrideUserInterfaceStyle = isDarkMode ? .dark : .light
          }) {
            Image(systemName: isDarkMode ? "moon.stars" : "sun.min")
              .font(.system(size: 20))
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
      }
    }
    .navigationViewStyle(.stack)
    .sheet(isPresented: $presenter.state.isIntroduction) {
      IntroductionView(onStart: {
        presenter.state.isIntroduction = false
      })
    }
    .alert(isPresented: $presenter.state.isConfirmSerial) {
      serialConfirmAlert()
    }
    .textFieldAlert(
      isPresented: presenter.isFunctionalityPresenting(for: [.vibration, .mainSpeaker, .earSpeaker]),
      title: "How many times?",
      text: $presenter.state.inputValue,
      placeholder: "Input here",
      onSubmit: { string in
        Notifications.didInputConfirmation.post(with: Int(string))
      },
      onRepeat: {
        let currentAssessment = presenter.state.currentAssessment.assessment
        presenter.send(.start(assessment: currentAssessment))
      }
    )
    .fullScreenCover(isPresented: $presenter.state.isTouchscreenPresented) {
      ScreenFunctionalityView()
    }
    .fullScreenCover(isPresented: $presenter.state.isMultitouchPresented) {
      MultitouchFunctionalityView()
    }
    .fullScreenCover(isPresented: $presenter.state.isCameraPresented) {
      CameraFunctionalityView()
    }
    .fullScreenCover(isPresented: $presenter.state.isDeadpixelPresented) {
      DeadpixelFunctionalityView()
    }
    .fullScreenCover(isPresented: $presenter.state.isCompassPresented) {
      CompassFunctionalityView()
    }
    .toast(
      isPresenting: $presenter.state.currentAssessment.isTesting,
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
    .ignoresSafeArea(.keyboard)
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
