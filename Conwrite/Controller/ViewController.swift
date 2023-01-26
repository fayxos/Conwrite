//
//  ViewController.swift
//  Handwritting
//
//  Created by Felix Haag on 04.08.21.
//

import UIKit

// constanten für persistente datenspeicherung
let fontFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Fonts.plist")
let projectFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Projects.plist")

class ViewController: UIViewController {
        
    @IBOutlet weak var mainViewHost: UIView!
    
    var gestureRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Font.clearDatabase()
        //Project.clearDatabase()
    }
    
//    func addGestureRegonizer() {
//        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureFired(_:)))
//        gestureRecognizer!.numberOfTapsRequired = 1
//        gestureRecognizer!.numberOfTouchesRequired = 1
//
//        self.view.addGestureRecognizer(gestureRecognizer!)
//        self.view.isUserInteractionEnabled = true
//    }
//
//    @objc func gestureFired(_ gesture: UITapGestureRecognizer) {
//        print("Gesture Fired")
//        (mainViewController as! MainViewController).hideDropDown()
//        self.view.removeGestureRecognizer(gestureRecognizer!)
//    }

}

