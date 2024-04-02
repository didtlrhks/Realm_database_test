//
//  ContentView.swift
//  Realm_database_test
//
//  Created by 양시관 on 4/2/24.
//

import SwiftUI
import Realm
import RealmSwift

struct ContentView: View {
    @ObservedObject var audioRecorderManager = AudioRecorderManager()
       @State private var recordings = [Recording]()
       
       var body: some View {
           
           VStack {
                    if audioRecorderManager.isRecording {
                        Button("Stop Recording") {
                            // 녹음 중지
                            audioRecorderManager.stopRecording()
                        }
                        .foregroundColor(.red)
                        .padding()
                        .background(Circle().fill(Color.blue))
                    } else {
                        Button("Start Recording") {
                            // 녹음 시작
                            audioRecorderManager.startRecording()
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.red))
                    }
                }
           
           List(recordings, id: \.id) { recording in
               VStack(alignment: .leading) {
                   Text(recording.filePath)
                   Text(recording.recordedDate, style: .date)

               }
           }
           .onAppear(perform: loadRecordings)
          
       }
       
       private func loadRecordings() {
           do {
               let realm = try Realm()
               recordings = Array(realm.objects(Recording.self).sorted(byKeyPath: "recordedDate", ascending: false))
           } catch {
               print("Realm에서 녹음 파일을 로드하는 동안 오류가 발생했습니다: \(error.localizedDescription)")
           }
       }
  
}

#Preview {
    ContentView()
}
