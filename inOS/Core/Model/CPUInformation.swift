//
//  CPUInformation.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 20/3/24.
//

import Foundation

public struct CPUInformation {
  public var model: String?
  public var coreCount: Int?
  public var architecture: String?
  public var frequency: String?
  public var usage: ProcessorUsage?
  
  public init(
    model: String? = nil,
    coreCount: Int? = nil,
    architecture: String? = nil,
    frequency: String? = nil,
    usage: ProcessorUsage? = nil
  ) {
    self.model = model
    self.coreCount = coreCount
    self.architecture = architecture
    self.frequency = frequency
    self.usage = usage
  }
}
