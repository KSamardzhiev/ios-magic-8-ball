//
//  ViewController.swift
//  Magic8Ball
//
//  Created by Kostadin Samardzhiev on 21.12.21.
//

import UIKit

class ViewController: UIViewController {

    let ballImages = [
        UIImage(named: "ball1"),
        UIImage(named: "ball2"),
        UIImage(named: "ball3"),
        UIImage(named: "ball4"),
        UIImage(named: "ball5")
    ]
    
    @IBOutlet weak var ballImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func askButtonAction(_ sender: UIButton) {
        self.answerQuestion()
    }
    
    func answerQuestion() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        self.ballImageView.image = ballImages.randomElement()!
    }
    
}

