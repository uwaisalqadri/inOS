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

struct FunctionalityView: View {

  @StateObject private var presenter: FunctionalityPresenter
  @AppStorage("isDarkMode") private var isDarkMode: Bool = false

  @Environment(\.presentationMode) var presentationMode

  init() {
    _presenter = StateObject(
      wrappedValue: FunctionalityPresenter()
    )
  }

  var body: some View {
    NavigationView {
      ZStack(alignment: .bottomTrailing) {
        ScrollViewReader { proxy in
          ScrollView {
            VStack {
              DashboardStatusView(
                deviceStatuses: presenter.state.deviceStatuses,
                isSpecificationPresented: $presenter.state.isSpecificationPresented
              ).padding(.bottom, 6)
              
              HStack(alignment: .top) {
                ForEach(FunctionalityPresenter.GridSide.allCases, id: \.self) { side in
                  VStack(spacing: 12) {
                    ForEach(Array(presenter.splitForGrid(side: side).enumerated()), id: \.offset) { index, item in
                      let isPassed = presenter.state.passedAssessments[item]
                      FunctionalityRow(
                        item: item,
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
              .clipShape(.rect(cornerRadius: 12))
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
          Menu {
            Button("Benchmark", systemImage: "speedometer") {
              presenter.state.isBenchmarkPresented = true
            }
          } label: {
            let device = presenter.state.deviceStatus
            HStack(spacing: 4) {
              Image(systemName: device.spec.icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
              Text(device.value)
                .font(.system(size: 14, weight: .semibold))
            }
          }.foregroundColor(isDarkMode ? .white : .black)
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
    .sheet(isPresented: $presenter.state.isIntroduction) {
      IntroductionView(onStart: {
        presenter.state.isIntroduction = false
      })
    }
    .alert(isPresented: $presenter.state.isConfirmSerial) {
      serialConfirmAlert()
    }
    .textFieldAlert(
      isPresented: isFunctionalityPresented(in: [.vibration, .mainSpeaker, .earSpeaker]),
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

  private func isFunctionalityPresented(in functions: [Assessment]) -> Binding<Bool> {
    return Binding(
      get: {
        functions.contains {
          presenter.state.currentAssessment == ($0, true)
        }
      },
      set: { value in
        functions.forEach {
          presenter.state.currentAssessment = ($0, value)
        }
      }
    )
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
