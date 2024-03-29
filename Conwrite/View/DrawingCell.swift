//
//  DrawingCell.swift
//  Handwritting
//
//  Created by Felix Haag on 07.08.21.
//

import UIKit
import PencilKit

class DrawingCell: UICollectionViewCell {

    @IBOutlet weak var letterLabel: UILabel!
    @IBOutlet weak var canvasView: UIImageView!
    
    var isActive = false
    var index = 0;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, index: Int) {
        self.init(frame: frame)
        self.index = index
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
