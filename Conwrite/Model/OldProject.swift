//
//  OldProject.swift
//  Handwritting
//
//  Created by Felix Haag on 07.08.21.
//

import UIKit
import PencilKit
import Vision

class OldProject: Encodable, Decodable {
    var id: String
    var name: String
    var drawings: [PKDrawing]
    
    var font: OldFont?
    var imageData: Data?
    var rawText: String?
    
    var settings: [CGFloat] = [20, 2, 1]
    
    init(name: String, drawings: [PKDrawing]) {
        self.name = name
        self.drawings = drawings
        self.id = UUID().uuidString
    }

}
