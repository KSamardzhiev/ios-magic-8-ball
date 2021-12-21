//
//  ViewController.swift
//  Magic8Ball
//
//  Created by Kostadin Samardzhiev on 21.12.21.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {

    let ballImages = [
        UIImage(named: "ball0"),
        UIImage(named: "ball1"),
        UIImage(named: "ball2"),
        UIImage(named: "ball3"),
        UIImage(named: "ball4"),
        UIImage(named: "ball5")
    ]
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var ballImageView: UIImageView!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var askButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        ballImageView.image = ballImages[0]
        recordingSession = AVAudioSession.sharedInstance()
        requestTranscribePermissions()
        requestMicrophonePermissions()
        questionLabel.text = ""
        if(recordingSession.recordPermission == .granted && SFSpeechRecognizer.authorizationStatus() == .authorized) {
            askButton.setTitle("Ask Aloud", for: .normal)
        }
        
    }

    @IBAction func askButtonAction(_ sender: UIButton) {
        if(recordingSession.recordPermission == .granted && SFSpeechRecognizer.authorizationStatus() == .authorized) {
            if audioRecorder == nil {
                startRecording()
            } else {
                finishRecording(success: true)
            }
        } else {
            self.answerQuestion()
            self.questionLabel.text = "Answer of your question is"
        }
        
    }
    
    func answerQuestion() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        self.ballImageView.image = ballImages[Int.random(in: 1...5)]
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed == .authorized {
                    print("Transcription permission allowed.")
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
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            askButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        self.transcribeAudio(url: getDocumentsDirectory().appendingPathComponent("recording.m4a"))
        if success {
            askButton.setTitle("Tap to Re-Ask", for: .normal)
        } else {
            askButton.setTitle("Tap to Ask", for: .normal)
            // recording failed :(
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func transcribeAudio(url: URL) {
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)

        // start recognition!
        recognizer?.recognitionTask(with: request) { [unowned self] (result, error) in
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
                return
            }

            // if we got the final transcription back, print it
            if result.isFinal {
                // pull out the best transcription...
                print(result.bestTranscription.formattedString)
                self.questionLabel.text = result.bestTranscription.formattedString
            }
        }
    }
}

