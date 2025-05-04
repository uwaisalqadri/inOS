//
//  MainApp.swift
//  SpecAsessment
//
//  Created by Uwais Alqadri on 13/12/23.
//

import SwiftUI
import CoreMotion
import IOSSecuritySuite
import AlertToast
import inCore

@main
struct MainApp: App {
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @AppStorage(.persistence(key: .isDarkMode)) private var isDarkMode: Bool = false
  @StateObject private var remoteConfig = RemoteConfig()
  
  var body: some Scene {
    WindowGroup {
      ZStack {
        switch true {
        case !remoteConfig.isLoaded:
          Color(.splashBlue)
            .ignoresSafeArea(.all)
          AlertToast(displayMode: .alert, type: .loading)
          
        case remoteConfig.isMaintenance():
          MaintenanceView(type: .maintenance)
          
        case remoteConfig.isForceUpdate():
          MaintenanceView(type: .forceUpdate)
          
        case IOSSecuritySuite.amIDebugged() &&
          IOSSecuritySuite.amIReverseEngineered() &&
          IOSSecuritySuite.amIRunInEmulator():
          MaintenanceView(type: .secured)
          
        default:
          if #available(iOS 17.0, *) {
            MainView()
          } else {
            AssessmentView()
          }
        }
      }
      .preferredColorScheme(isDarkMode ? .dark : .light)
    }
  }
}
