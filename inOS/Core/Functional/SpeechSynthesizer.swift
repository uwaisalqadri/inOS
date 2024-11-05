//
//  SpeechSynthesizer.swift
//  Data
//
//  Created by Uwais Alqadri on 12/2/24.
//

import AVFoundation
import Foundation

class SpeechSynthesizer {
  static let shared = SpeechSynthesizer()
  private let synthesizer = AVSpeechSynthesizer()
  private var audioSession = AVAudioSession.sharedInstance()
  
  func speak(_ text: String, useEarSpeaker: Bool, language: String = "en-US") {
    do {
      if useEarSpeaker {
        try audioSession.setCategory(.playAndRecord, options: .duckOthers)
      } else {
        try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
      }
      try audioSession.setActive(true)
    } catch {
      print("Error setting audio session category: \(error.localizedDescription)")
    }
    
    let utterance = AVSpeechUtterance(string: text)
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate // Speech rate (0.0 to 1.0)
    utterance.voice = AVSpeechSynthesisVoice(language: language) // Voice language
    
    synthesizer.speak(utterance)
  }
  
  func stopSpeaking() {
    synthesizer.stopSpeaking(at: .immediate)
    
    do {
      try audioSession.setActive(false)
    } catch {
      print("Error deactivating audio session: \(error.localizedDescription)")
    }
  }
}
