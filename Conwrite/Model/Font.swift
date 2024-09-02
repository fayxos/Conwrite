//
//  Font.swift
//  Handwritting
//
//  Created by Felix Haag on 06.08.21.
//

import Foundation
import PencilKit

class Font: Encodable, Decodable {
    var id: String
    var name: String
        
    var characters: [String: [PKDrawing]]
    var variationCount = 0
    
    var imageData: Data?
    
    var basicCharactersCompleted: Bool = false
    
    init(name: String, characters: [String: [PKDrawing]] ) {
        self.name = name
        self.characters = characters
        self.id = UUID().uuidString
    }
    
    private func setImage() {
        // get drawing "a", save as image with name of font
        let drawing = characters["A"]![0]
        if drawing.bounds.width != 0 && drawing.bounds.width != 0 {
            imageData = (drawing.image(from: (drawing.bounds), scale: CGFloat(0)).pngData())!
        }
    }
    
    func addCharacter(character: String, drawing: PKDrawing, variation: Int) {
        
        // Add drawing to characters
        if characters[character]!.count-1 < variation {
            characters[character]!.append(PKDrawing())
        }
        
        characters[character]![variation] = drawing
        
        if character == "A" {
            setImage()
        }
        
        updateBasicCharactersCompleted()
    }
    
    func updateBasicCharactersCompleted() {
        if characters.count == Letter.getLetters().count {
            for letter in Letter.getBasicLetters() {
                // Check if there is a drawing
                
                if !characters[letter]!.isEmpty {
                    var hasLetter = false
                    for value in characters[letter]! {
                        if value.bounds.width != 0 && value.bounds.height != 0 {
                            hasLetter = true
                        }
                    }
                    
                    if hasLetter {
                        continue
                    }
                }
                
                basicCharactersCompleted = false
                return
            }
            basicCharactersCompleted = true
            
        } else {
            basicCharactersCompleted = false
        }
    }
    
    func saveToDatabase() {
        var fonts: [Font] = Font.loadFonts()
        var fontIDs: [String] = []
        for font in fonts {
            fontIDs.append(font.id)
        }
        if fontIDs.contains(self.id) {
            var i: Int = 0
            for font in fonts {
                if font.id == self.id {
                    fonts[i] = self
                }
                i += 1
            }
        } else {
            fonts.insert(self, at: 0)
        }
        
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(fonts)
            try data.write(to: fontFilePath!)
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func deleteFromDatabase() {
        var fonts: [Font] = Font.loadFonts()
        var fontIDs: [String] = []
        for font in fonts {
            fontIDs.append(font.id)
        }
        if fontIDs.contains(self.id) {
            var i: Int = 0
            for font in fonts {
                if font.id == self.id {
                    fonts.remove(at: i)
                }
                i += 1
            }
        }
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(fonts)
            try data.write(to: fontFilePath!)
        } catch {
            print("Error: \(error)")
        }
    }
    
    static func loadFonts() -> [Font] {
        var fonts: [Font] = []
        
        if let data = try? Data(contentsOf: fontFilePath!) {
            let decoder = PropertyListDecoder()
            
            print(data)
            
            do {
                fonts = try decoder.decode([Font].self, from: data)
            } catch {
                print("Error: \(error)")
            }
        }
        
        return fonts
    }
    
    // sucht font mit angegebenem namen
    static func getFont(name: String) -> Font? {
        let fonts: [Font] = Font.loadFonts()
        var fontNames: [String] = []
        for name in fontNames {
            fontNames.append(name)
        }
        if fontNames.contains(name) {
            for font in fonts {
                if font.name == name {
                    return font
                }
            }
        }
        
        return nil
    }
    
    // temporär um beim entwickeln die Datenbank zu leeren
    static func clearDatabase() {
        let encoder = PropertyListEncoder()
        do {
            let fonts: [Font] = []
            let data = try encoder.encode(fonts)
            try data.write(to: fontFilePath!)
        } catch {
            print("Error: \(error)")
        }
    }
    
    static func migrateOldFonts() {
        var oldFonts: [OldFont] = []
        
        if let data = try? Data(contentsOf: fontFilePath!) {
            let decoder = PropertyListDecoder()
            
            print(data)
            
            do {
                oldFonts = try decoder.decode([OldFont].self, from: data)
            } catch {
                print("Error: \(error)")
            }
        }
        
        if oldFonts.isEmpty { return }
        
        var newFonts = [Font]()
        for oldFont in oldFonts {
            var newCharacters = [String: [PKDrawing]]()
            for letter in Letter.getLetters() {
                newCharacters[letter] = []
                if oldFont.characters[letter] != nil {
                    newCharacters[letter]!.append(oldFont.characters[letter]!)
                }
            }
            for (key, value) in oldFont.characters {
                newCharacters[key] = [value]
            }
            
            let newFont = Font(name: oldFont.name, characters: newCharacters)
            newFont.id = oldFont.id
            newFont.imageData = oldFont.imageData
            newFont.updateBasicCharactersCompleted()
            
            newFonts.append(newFont)
        }
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(newFonts)
            try data.write(to: fontFilePath!)
        } catch {
            print("Error: \(error)")
        }
        
    }
    
}
