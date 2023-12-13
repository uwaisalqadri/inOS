//
//  Delay.swift
//  inOS
//
//  Created by Uwais Alqadri on 27/10/24.
//

import Foundation

func delay(bySeconds seconds: Double, completion: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
    completion()
  }
}
