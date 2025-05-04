//
//  PassedAssessmentCollection.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/05/25.
//

import inCore

struct PassedAssessmentCollection {
  private(set) var results: [Assessment: Bool] = [:]

  subscript(assessment: Assessment) -> Bool? {
    get {
      results[assessment]
    }
    set {
      results[assessment] = newValue
    }
  }
  
  mutating func set(_ assessment: Assessment, passed: Bool) {
    results[assessment] = passed
  }

  func asPersisted() -> [AssessmentPersisted] {
    results.map { .init(assessmentKey: $0.key.rawValue, isPassed: $0.value) }
  }
  
  mutating func removeAll() {
    results = [:]
  }
}
