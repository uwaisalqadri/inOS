//
//  SerialAssessmentControl.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/05/25.
//

import inCore

enum SerialAssessmentControl {
  case run(from: Assessment)
  case skip(current: Assessment)
  case confirm(Bool)
  case terminate
}
