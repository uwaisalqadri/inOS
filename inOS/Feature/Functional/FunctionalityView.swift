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
  
  var currentAssessment: FunctionalityPresenter.CurrentAssessment {
    presenter.state.currentAssessment
  }
  
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
              if #available(iOS 17.0, *) {
                EmptyView()
              } else {
                DashboardStatusView(
                  deviceStatuses: presenter.state.deviceStatuses,
                  isTesting: currentAssessment.isRunning,
                  isSpecificationPresented: $presenter.state.isSpecificationPresented,
                  isBenchmarkPresented: $presenter.state.isBenchmarkPresented
                )
              }
              
              HStack(alignment: .top, spacing: 12) {
                ForEach(FunctionalityPresenter.GridSide.allCases, id: \.self) { side in
                  VStack(spacing: 12) {
                    ForEach(Array(presenter.splitForGrid(side: side).enumerated()), id: \.offset) { index, item in
                      let isPassed = presenter.state.passedAssessments[item]
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
                      .zIndex(1)
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
        }
        
        VStack(spacing: 24) {
          Button(action: {
            if presenter.state.isSerialRunning {
              presenter.send(.terminateSerial)
            } else {
              presenter.send(.runSerial)
            }
          }) {
            Image(systemName: presenter.state.isSerialRunning ? "stop.fill" : "play.fill")
              .font(.system(size: 25))
              .contentShape(.rect)
          }.frame(width: 40, height: 40)
          
          if presenter.state.isSerialRunning {
            Button(action: {
              print("SKIP")
            }) {
              Image(systemName: "forward.fill")
                .font(.system(size: 25))
                .contentShape(.rect)
            }.frame(width: 40, height: 40)
            
            ActivityIndicator(style: .large)
          }
        }
        .padding(16)
        .background(
          Blur()
            .clipShape(.rect(cornerRadius: Theme.current.cornerRadius))
        )
//        .overlay(
//          RoundedRectangle(cornerRadius: Theme.current.cornerRadius)
//            .stroke(Color(.lightGray), lineWidth: 0.8)
//        )
        .padding(.trailing, 20)
        .padding(.bottom, 10)
        .zIndex(2)
      }
      .onFirstAppear {
        presenter.send(.loadStatus)
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          DeviceView(
            isShimmer: true,
            onTapGesture: {
              presenter.state.isSpecificationPresented = true
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
            Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.min.fill")
              .font(.system(size: 20))
          }
        }
      }
      .navigation(isPresented: $presenter.state.isSpecificationPresented) {
        SpecificationView()
      }
    }
    .navigationViewStyle(.stack)
    .alert(isPresented: $presenter.state.isConfirmSerial) {
      serialConfirmAlert()
    }
    .alert(isPresented: $presenter.state.isNeedConfirmAssessment) {
      runConfirmAlert()
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
        presenter.send(.start(assessment: currentAssessment.assessment))
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
      primaryButton: .default(Text("Cancel")) {
        presenter.send(.showConfirmSerial(false))
      },
      secondaryButton: .default(Text("Start")) {
        presenter.send(.runSerial)
        presenter.send(.showConfirmSerial(false))
      }
    )
  }
  
  private func runConfirmAlert() -> Alert {
    Alert(
      title: Text("Run Test?"),
      message: Text("Are you sure you want to run this test now?"),
      primaryButton: .default(Text("Cancel")) {
        presenter.send(.runConfirmation(false))
      },
      secondaryButton: .default(Text("Run")) {
        presenter.send(.runConfirmation(true))
      }
    )
  }
}

struct FunctionalityView_Previews: PreviewProvider {
  static var previews: some View {
    FunctionalityView()
  }
}
