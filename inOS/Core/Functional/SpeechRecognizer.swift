//
//  SpeechRecognizer.swift
//  Data
//
//  Created by Uwais Alqadri on 12/2/24.
//

import Foundation
import Speech

class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate {
  static let shared = SpeechRecognizer()
  
  private let audioEngine = AVAudioEngine()
  private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  var voiceDetectedCallback: ((Error?) -> Void)?
  
  override init() {
    super.init()
    speechRecognizer?.delegate = self
  }
  
  func startRecording() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      self.voiceDetectedCallback?(error)
    }
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
    let inputNode = audioEngine.inputNode
    guard let recognitionRequest = recognitionRequest else { return }
    
    recognitionRequest.shouldReportPartialResults = true
    
    self.recognitionTask = speechRecognizer?.recognitionTask(
      with: recognitionRequest,
      resultHandler: { [weak self] result, error in
        if let result = result, !result.bestTranscription.formattedString.isEmpty {
          self?.voiceDetectedCallback?(nil)
          if result.isFinal {
            self?.stopRecording()
          }
        } else {
          self?.stopRecording()
        }
        
        if let error = error, error.localizedDescription.contains("denied") {
          self?.voiceDetectedCallback?(PermissionFailed.microphoneNotPermitted)
        }
      }
    )
    
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    do {
      try audioEngine.start()
    } catch {
      self.voiceDetectedCallback?(error)
    }
  }
  
  func stopRecording() {
    audioEngine.stop()
    audioEngine.inputNode.removeTap(onBus: 0)
    recognitionRequest?.endAudio()
    recognitionTask?.cancel()
    recognitionRequest = nil
    recognitionTask = nil
  }
  
  func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if !available {
      stopRecording()
    }
  }
}
