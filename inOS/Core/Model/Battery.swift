//
//  Battery.swift
//  DeviceAssessment
//
//  Created by Uwais Alqadri on 20/3/24.
//

public struct Battery {
  public var voltage: String?
  public var technology: String?
  public var remainingTime: String?
  public var percentage: Float?
  public var health: String?
  public var temperature: String?
  
  public init(
    voltage: String? = nil,
    technology: String? = nil,
    remainingTime: String? = nil,
    percentage: Float? = nil,
    health: String? = nil,
    temperature: String? = nil
  ) {
    self.voltage = voltage
    self.technology = technology
    self.remainingTime = remainingTime
    self.percentage = percentage
    self.health = health
    self.temperature = temperature
  }
}
