//
//  OldFont.swift
//  Handwritting
//
//  Created by Felix Haag on 06.08.21.
//

import Foundation
import PencilKit

class OldFont: Encodable, Decodable {
    var id: String
    var name: String
        
    var characters: [String: PKDrawing]
    var normalizedCharacters: [String: PKDrawing] = [:]
    
    var imageData: Data?
    
    var allCharactersCompleted: Bool = false
    
    init(name: String, characters: [String: PKDrawing] ) {
        self.name = name
        self.characters = characters
        self.id = UUID().uuidString
    }
    
}
