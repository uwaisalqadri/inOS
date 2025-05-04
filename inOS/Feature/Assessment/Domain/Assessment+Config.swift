//
//  Assessment+Config.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/05/25.
//

import inCore
import DeviceKit

extension Assessment {
  static func allEnabledCases() -> [Assessment] {
    let remoteConfig = RemoteConfig()
    let enabledCases: [Assessment] = allCases.compactMap { assessment in
      if !remoteConfig.isAssessmentEnabled(assessment) {
        return nil
      }
      if Device.current.isPad && [.vibration, .nfc, .cellular, .wirelessCharging].contains(assessment) {
        return nil
      }
      if Device.current.hasActionButton && [.silentSwitch].contains(assessment) {
        return nil
      }
      return assessment
    }
    
    return enabledCases.isEmpty ? allCases : enabledCases
  }
}
