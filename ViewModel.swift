//
//  ViewModel.swift
//  Listen
//
//  Created by nokkun on 2022/01/19.
//

import Foundation
import AVKit
import ShazamKit
import CoreData
import SwiftUI

struct ShazamMedia: Decodable {
    let title: String?
    let subtitle: String?
    let artistName: String?
    let albumArtURL: URL?
    let genres: [String]
}

class ViewModel:NSObject,ObservableObject{
    
    @Published var shazamMedia =  ShazamMedia(title: "Title...",
                                              subtitle: "Subtitle...",
                                              artistName: "Artist Name...",
                                              albumArtURL: URL(string: "https://google.com"),
                                              genres: ["Pop"])
    @Published var isRecording = false
    
    private let audioEngine = AVAudioEngine()
    private let session = SHSession()
//    private let signatureGenerator = SHSignatureGenerator()
    var context: NSManagedObjectContext?
    @Published var showPrivacyConfirm = false
        
    override init() {
        super.init()
        session.delegate = self
    }
    
    public func stopListening(){
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
        
    public func startListening(context:NSManagedObjectContext) {
                
        self.context = context
        
        let audioSession = AVAudioSession.sharedInstance()
        
        audioSession.requestRecordPermission { granted in
            guard granted else {
                self.showPrivacyConfirm = true
                return
            }
            try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = self.audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0,
                                 bufferSize: 1024,
                                 format: recordingFormat) { (buffer: AVAudioPCMBuffer,
                                                             when: AVAudioTime) in
                self.session.matchStreamingBuffer(buffer, at: nil)
            }
            
            self.audioEngine.prepare()
            do {
                try self.audioEngine.start()
            } catch (let error) {
                assertionFailure(error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.isRecording = true
            }
        }
    }
}

extension ViewModel: SHSessionDelegate {
    
    func session(_ session: SHSession, didFind match: SHMatch) {
        
        stopListening()
        
        let mediaItems = match.mediaItems
        
        if let firstItem = mediaItems.first {
            let _shazamMedia = ShazamMedia(title: firstItem.title,
                                           subtitle: firstItem.subtitle,
                                           artistName: firstItem.artist,
                                           albumArtURL: firstItem.artworkURL,
                                           genres: firstItem.genres)
            
            //UIに表示させる
            DispatchQueue.main.async {
                self.shazamMedia = _shazamMedia
//                print(self.shazamMedia)
            }
            
            //DBに保存する            
            guard let context = context else { return }
            
            let newItem = Song(context: context)
            newItem.artist = firstItem.artist
            newItem.title = firstItem.title
            newItem.artURL = firstItem.artworkURL
            newItem.time = Date()
            
            try? context.save()
            
        }
    }
    
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {

        stopListening()
        
        let message = "Not Found"
        let _shazamMedia = ShazamMedia(title: message,
                                       subtitle: message,
                                       artistName: message,
                                       albumArtURL: nil,
                                       genres: [message])
        
        //UIに表示させる
        DispatchQueue.main.async {
            self.shazamMedia = _shazamMedia
        }
    }
}
