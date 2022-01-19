//
//  Button.swift
//  Handwritting
//
//  Created by Felix Haag on 03.09.21.
//

import Foundation
import UIKit

extension UIButton {
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .red : .green
        }
    }
}
