//
//  AssessmentResult.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/05/25.
//

import inCore

struct AssessmentResult: Equatable, Codable {
  let assessment: Assessment
  let isPassed: Bool
}
