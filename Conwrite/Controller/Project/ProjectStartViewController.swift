//
//  ProjectStartViewController.swift
//  Handwritting
//
//  Created by Felix Haag on 13.08.21.
//

import UIKit

class ProjectStartViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fontPickerView: UIPickerView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet public weak var contentView: UIView!
    
    var content: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        content = contentView
    }

    @IBAction func generateDrawingButtonTapped(_ sender: UIButton) {
    }
}
