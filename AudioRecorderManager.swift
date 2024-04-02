//
//  AudioManager.swift
//  Realm_database_test
//
//  Created by 양시관 on 4/2/24.
//


import Foundation

import AVFoundation
import Realm
import RealmSwift

class AudioRecorderManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
  /// 음성메모 녹음 관련 프로퍼티
  var audioRecorder: AVAudioRecorder?
  @Published var isRecording = false
  @Published var playbackProgress: Double = 0.0
  /// 음성메모 재생 관련 프로퍼티
  var audioPlayer: AVAudioPlayer?
  @Published var isPlaying = false
  @Published var isPaused = false
  
  /// 음성메모된 데이터
  var recordedFiles = [URL]()
}

// MARK: - 음성메모 녹음 관련 메서드
extension AudioRecorderManager {
  func startRecording() {
    let fileURL = getDocumentsDirectory().appendingPathComponent("recording-\(Date().timeIntervalSince1970).m4a")
    let settings = [
      AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
      AVSampleRateKey: 12000,
      AVNumberOfChannelsKey: 1,
      AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    do {
      audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
      audioRecorder?.record()
      self.isRecording = true
    } catch {
      print("녹음 중 오류 발생: \(error.localizedDescription)")
    }
  }
  
//  func stopRecording() {
//    audioRecorder?.stop()
//    self.recordedFiles.append(self.audioRecorder!.url)
//    self.isRecording = false
//
//  }
    func stopRecording() {
          audioRecorder?.stop()
          self.isRecording = false
          
          if let url = audioRecorder?.url {
              self.recordedFiles.append(url)
              
              // Realm에 녹음 파일 정보 저장
              let recording = Recording()
              recording.filePath = url.lastPathComponent // 또는 url.path를 사용해 전체 경로 저장
              recording.recordedDate = Date()
              
              do {
                  let realm = try Realm()
                  try realm.write {
                      realm.add(recording)
                  }
                  print("녹음 파일 정보가 성공적으로 저장되었습니다.")
                  print(Realm.Configuration.defaultConfiguration.fileURL)
              } catch {
                  print("Realm에 저장하는 동안 오류가 발생했습니다: \(error.localizedDescription)")
              }
          }
      }
  
  private func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
      
  }
}

// MARK: - 음성메모 재생 관련 메서드
extension AudioRecorderManager {
  func startPlaying(recordingURL: URL) {
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: recordingURL)
      audioPlayer?.delegate = self
      audioPlayer?.play()
      self.isPlaying = true
      self.isPaused = false
    } catch {
      print("재생 중 오류 발생: \(error.localizedDescription)")
    }
  }
  
  func stopPlaying() {
    audioPlayer?.stop()
    self.isPlaying = false
  }
  
  func pausePlaying() {
    audioPlayer?.pause()
    self.isPaused = true
  }
  
  func resumePlaying() {
    audioPlayer?.play()
    self.isPaused = false
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    self.isPlaying = false
    self.isPaused = false
  }
    
    private func updatePlaybackProgress() {
            guard let player = audioPlayer, player.duration > 0 else {
                return
            }

            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] (timer) in
                guard let self = self, self.isPlaying else {
                    timer.invalidate()
                    return
                }
                self.playbackProgress = player.currentTime / player.duration
            }
        }
}
