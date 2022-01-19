//
//  DrawingCell.swift
//  Handwritting
//
//  Created by Felix Haag on 07.08.21.
//

import UIKit
import PencilKit

class DrawingCell: UICollectionViewCell, PKCanvasViewDelegate {

        
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var letterLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        canvasView.delegate = self
        
        canvasView.alwaysBounceVertical = true
        //canvasView.allowsFingerDrawing = true
            
    }
    
    

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
