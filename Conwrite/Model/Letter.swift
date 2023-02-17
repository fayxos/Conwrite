//
//  Letter.swift
//  Handwritting
//
//  Created by Felix Haag on 07.08.21.
//

import Foundation
import PencilKit

class Letter {
    static let letters: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Ä", "Ö", "Ü", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "ß", "ä", "ö", "ü", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", ",", "!", "?", ":", ";", "\"", "(", ")", "/", "+", "-", "=", "*", "&", "@", "%", "#", "[", "]", "{", "}", "|", "<", ">", "§", "$", "€", "_", "'"]
    
    static func getLetters() -> [String] {
        return letters
    }
    
    static func getEmptyLetterArray() -> [String: PKDrawing?] {
        
        var letterArray: [String: PKDrawing?] = [:]
        for letter in letters {
            letterArray[letter] = nil
        }
        
        return letterArray
    }
    
    static func getEmptyCellArray() -> [String: DrawingCell?] {
        
        var letterArray: [String: DrawingCell?] = [:]
        for letter in letters {
            letterArray[letter] = nil
        }
        
        return letterArray
    }
}
