//
//  CurrentAssessments.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/05/25.
//

import inCore
import SwiftUI

struct CurrentAssessment: Equatable {
  var assessment: Assessment
  var phase: AssessmentPhase = .idle
  
  static var empty: Self = .init(.cpu, phase: .idle)
  
  init(_ assessment: Assessment, phase: AssessmentPhase) {
    self.assessment = assessment
    self.phase = phase
  }
}
