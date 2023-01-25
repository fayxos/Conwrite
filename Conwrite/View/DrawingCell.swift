//
//  DrawingCell.swift
//  Handwritting
//
//  Created by Felix Haag on 07.08.21.
//

import UIKit
import PencilKit

class DrawingCell: UICollectionViewCell, PKCanvasViewDelegate {

        
    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var canvasView: UIImageView!
    
    var drawingView: PKCanvasView?
    
    var isActive: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawingView!.delegate = self
        drawingView!.alwaysBounceVertical = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
