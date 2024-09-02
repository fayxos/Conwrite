//
//  Letter.swift
//  Handwritting
//
//  Created by Felix Haag on 07.08.21.
//

import Foundation
import PencilKit

class Letter {
    static let letters: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
                                    "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f",
                                    "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
                                    "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", ",",
                                    "!", "¡", "?", "¿", ":", ";", "\"", "(", ")", "/", "+", "-", "=", "*", "&", "@", "%", "#",
                                    "[", "]", "{", "}", "|", "<", ">", "§", "$", "€", "_", "'",
                                    "Ä", "Ö", "Ü", "ä", "ö", "ü", "ß",
                                    "À", "Á", "Â", "Ã", "Å", "Æ", "Ç", "È", "É", "Ê", "Ë", "Ì", "Í", "Î", "Ï", "Ñ",
                                    "Ò", "Ó", "Ô", "Õ", "Ø", "Ù", "Ú", "Û", "Ý", "Þ",
                                    "à", "á", "â", "ã", "å", "æ", "ç", "è", "é", "ê", "ë", "ì", "í", "î", "ï", "ñ",
                                    "ò", "ó", "ô", "õ", "ø", "ù", "ú", "û", "ý", "þ", "ÿ"]
    
    static let basicLetters: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
                                    "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f",
                                    "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v",
                                    "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", ",",
                                    "!", "¡", "?", "¿", ":", ";", "\"", "(", ")", "/", "+", "-", "=", "*", "&", "@", "%", "#",
                                    "[", "]", "{", "}", "|", "<", ">", "§", "$", "€", "_", "'",]
    
    
    static func getLetters() -> [String] {
        return letters
    }
    
    static func getBasicLetters() -> [String] {
        return basicLetters
    }
    
    static func getEmptyLetterArray() -> [String: [PKDrawing]] {
        
        var letterArray: [String: [PKDrawing]] = [:]
        for letter in letters {
            letterArray[letter] = []
        }
        
        return letterArray
    }
    
    static func getEmptyCellArray() -> [String: [DrawingCell]] {
        
        var letterArray: [String: [DrawingCell]] = [:]
        for letter in letters {
            letterArray[letter]! = []
        }
        
        return letterArray
    }
}
