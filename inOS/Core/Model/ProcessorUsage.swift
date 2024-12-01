//
//  ProcessorUsage.swift
//  inOS
//
//  Created by Uwais Alqadri on 01/12/24.
//

import Foundation

extension CPUInformation {
  public struct ProcessorUsage {
    public var user: Double
    public var system: Double
    public var idle: Double
    public var nice: Double
  }
}
