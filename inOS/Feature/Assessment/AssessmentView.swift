//
//  AssessmentView.swift
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

struct AssessmentView: View {

  @StateObject private var presenter: AssessmentPresenter
  @AppStorage(.persistence(key: .isDarkMode)) private var isDarkMode: Bool = false
  @Environment(\.presentationMode) var presentationMode
  
  var currentAssessment: CurrentAssessment {
    presenter.state.currentAssessment
  }
  
  init() {
    UIScrollView.appearance().bounces = false
    _presenter = StateObject(
      wrappedValue: AssessmentPresenter()
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
                DashboardMetricView(
                  deviceMetrics: $presenter.state.deviceMetrics,
                  isRunning: currentAssessment.phase == .running,
                  isSpecificationPresented: $presenter.state.isSpecificationPresented,
                  isBenchmarkPresented: $presenter.state.isBenchmarkPresented
                )
              }
              
              HStack(alignment: .top, spacing: 12) {
                ForEach(AssessmentPresenter.GridSide.allCases, id: \.self) { side in
                  VStack(spacing: 12) {
                    ForEach(Array(presenter.splitForGrid(side: side).enumerated()), id: \.offset) { index, item in
                      let isPassed = presenter.state.passedAssessments[item]
                      AssessmentRow(
                        item: item,
                        isTesting: currentAssessment.phase == .running && currentAssessment.assessment != item,
                        isPassed: isPassed,
                        onTestFunction: {
                          presenter.send(.start(from: item))
                        }
                      )
                      .id(Double(index))
                      .contextMenu {
                        Button {
                          presenter.send(.start(from: item))
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
          .onChange(of: presenter.state.scrollIndex) { _, index in
            withAnimation {
              proxy.scrollTo(index)
            }
          }
        }
        
        VStack(spacing: 24) {
          Button(action: {
            if currentAssessment.phase == .running {
              presenter.send(.terminate)
            } else {
              presenter.send(.runSerial)
            }
          }) {
            Image(systemName: currentAssessment.phase == .running ? "stop.fill" : "play.fill")
              .font(.system(size: 25))
              .contentShape(.rect)
          }.frame(width: 40, height: 40)
          
          if presenter.state.serialState == .running {
            Button(action: {
              presenter.send(.skip)
            }) {
              Image(systemName: "forward.fill")
                .font(.system(size: 25))
                .contentShape(.rect)
            }.frame(width: 40, height: 40)
          }
          
          if currentAssessment.phase == .running {
            ActivityIndicator(style: .large)
          }
        }
        .padding(16)
        .background(
          Blur()
            .clipShape(.rect(cornerRadius: Theme.current.cornerRadius))
        )
        .overlay(
          RoundedRectangle(cornerRadius: Theme.current.cornerRadius)
            .stroke(Color(.lightGray).opacity(0.5), lineWidth: 0.8)
        )
        .padding(.trailing, 20)
        .padding(.bottom, 10)
        .animation(.spring, value: presenter.state.serialState == .running)
        .animation(.spring, value: currentAssessment.phase == .running)
      }
      .onFirstAppear {
        presenter.send(.loadMetrics)
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
    .alert(isPresented: presenter.isSerialConfirmationNeeded()) {
      serialConfirmAlert()
    }
    .alert(isPresented: presenter.isAssessmentConfirmationNeeded()) {
      runConfirmAlert()
    }
    .textFieldAlert(
      isPresented: presenter.hasAssessmentTesting(within: [.vibration, .mainSpeaker, .earSpeaker]),
      title: "How many times?",
      text: $presenter.state.inputValue,
      placeholder: "Input here",
      onSubmit: { string in
        Notifications.didInputConfirmation.post(with: Int(string))
      },
      onRepeat: {
        presenter.send(.start(from: currentAssessment.assessment))
      }
    )
    .fullScreenCover(item: $presenter.state.presentedAssessment) { assessment in
      switch assessment {
      case .touchscreen:
        ScreenAssessmentView()
      case .multitouch:
        MultitouchAssessmentView()
      case .camera:
        CameraAssessmentView()
      case .deadpixel:
        DeadpixelAssessmentView()
      case .compass:
        CompassAssessmentView()
      default:
        EmptyView()
      }
    }
    .toast(
      isPresenting: presenter.hasAssessmentTesting(within: [.vibration, .mainSpeaker, .earSpeaker]),
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
        if presenter.state.serialState == .running {
          presenter.send(.skip)
        } else {
          presenter.send(.runConfirmed(false))
        }
      },
      secondaryButton: .default(Text("Run")) {
        presenter.send(.runConfirmed(true))
      }
    )
  }
}

struct AssessmentView_Previews: PreviewProvider {
  static var previews: some View {
    AssessmentView()
  }
}
