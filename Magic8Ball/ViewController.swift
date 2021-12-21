//
//  ViewController.swift
//  Magic8Ball
//
//  Created by Kostadin Samardzhiev on 21.12.21.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController {

    let ballImages = [
        UIImage(named: "ball1"),
        UIImage(named: "ball2"),
        UIImage(named: "ball3"),
        UIImage(named: "ball4"),
        UIImage(named: "ball5")
    ]
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var speechTranscribeAllowed = false
    
    @IBOutlet weak var ballImageView: UIImageView!
    

    @IBOutlet weak var askButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        recordingSession = AVAudioSession.sharedInstance()
        requestTranscribePermissions()
        requestMicrophonePermissions()

        if(recordingSession.recordPermission == .granted && SFSpeechRecognizer.authorizationStatus() == .authorized) {
            askButton.setTitle("Ask Aloud", for: .normal)
        }
        
    }

    @IBAction func askButtonAction(_ sender: UIButton) {
        self.answerQuestion()
    }
    
    func answerQuestion() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        self.ballImageView.image = ballImages.randomElement()!
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed == .authorized {
                    print("Transcription permission allowed.")
                    self.speechTranscribeAllowed = true
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }
    
    func requestMicrophonePermissions() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            print("Microphone permissions allowed.")
                        } else {
                            print("Microphone permissions was declined.")
                        }
                    }
                }
        } catch {
            
        }
        
    }
    
}

