//
//  GeneratedDrawingCell.swift
//  Handwritting
//
//  Created by Felix Haag on 27.08.21.
//

import UIKit
import PencilKit

class GeneratedDrawingCell: UITableViewCell {

    var canvasView: PKCanvasView = PKCanvasView()
    var backgroundImageView: UIImageView = UIImageView()
    
    override func layoutSubviews() {
        self.addSubview(backgroundImageView)
        self.addSubview(canvasView)
    }
}
