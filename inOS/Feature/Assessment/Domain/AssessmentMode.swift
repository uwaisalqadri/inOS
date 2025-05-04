//
//  AssessmentMode.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/05/25.
//

import inCore

enum AssessmentMode {
  case immediate
  case needsConfirmation
  case regular
}

extension Assessment {
  var mode: AssessmentMode {
    switch self {
    case .volumeUp, .volumeDown, .silentSwitch, .connector, .compass:
      return .immediate
    case .camera, .touchscreen, .multitouch, .cellular, .wifi, .deadpixel:
      return .needsConfirmation
    default:
      return .regular
    }
  }
}
