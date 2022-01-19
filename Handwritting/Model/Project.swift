//
//  Project.swift
//  Handwritting
//
//  Created by Felix Haag on 07.08.21.
//

import UIKit
import PencilKit
import Vision

class Project: Encodable, Decodable {
    var id: String
    var name: String
    var drawings: [PKDrawing]
    
    var font: Font?
    var imageData: Data?
    var rawText: String?
    
    var settings: [CGFloat] = [20, 2, 1]
    
    
    init(name: String, drawings: [PKDrawing]) {
        self.name = name
        self.drawings = drawings
        self.id = UUID().uuidString
    }

    func convertTextToDrawing(practiceScale: CGFloat, lineWidth: CGFloat, canvasHeight: CGFloat, backgroundType: BackgroundType) -> [PKDrawing] {
        
        drawings = [PKDrawing()]
        
        guard let text = rawText else { return drawings }
                
        var currentSide: Int = 0
        
        let drawingHeight = canvasHeight
        
        // constants
        let textMargin: CGFloat = 10
        var canvasHeight: CGFloat = 1116.0
        var lineWidth: CGFloat = 797.1428571428571
        var lineHeight: CGFloat
        var spaceWidth: CGFloat
        var letterSpacing: CGFloat
        var startPosition: CGPoint
        
        switch backgroundType {
        case .White: // weiß, passt
            canvasHeight = canvasHeight - 10
            lineWidth = lineWidth - 10
            lineHeight = 80 * practiceScale // 66.5 passt perfekt zu liniert, medium
            spaceWidth = 30 * practiceScale
            letterSpacing = 0.5
            startPosition = CGPoint(x: textMargin, y: 5)
        case .Quad: // kariert, passt alles perfekt
            canvasHeight = canvasHeight - 10
            lineWidth = lineWidth - 10
            lineHeight = 73.5 * 0.5
            spaceWidth = 30 * practiceScale
            letterSpacing = 0.5
            startPosition = CGPoint(x: textMargin, y: 15)
            switch practiceScale {
            case 0.3:
                startPosition.y = 33
            case 0.4:
                startPosition.y = 24
            case 0.5:
                startPosition.y = 15
            case 0.6:
                startPosition.y = 6
            case 0.7:
                startPosition.y = -3
            default:
                startPosition.y = 15
            }

            canvasHeight = canvasHeight - (5+(40-startPosition.y))
            
        case .Ruled: // liniert, passt alles perfekt
            lineWidth = lineWidth - 10
            lineHeight = 66.5 * 0.5
            spaceWidth = 30 * practiceScale
            letterSpacing = 0.5
            startPosition = CGPoint(x: textMargin, y: 20)
            switch practiceScale {
            case 0.3:
                startPosition.y = 38
            case 0.4:
                startPosition.y = 29
            case 0.5:
                startPosition.y = 20
            case 0.6:
                startPosition.y = 11
            case 0.7:
                startPosition.y = 2
            default:
                startPosition.y = 20
            }

            canvasHeight = canvasHeight - (5+(40-startPosition.y))
        }
                
        var letterPosition = startPosition
        var didJustWrap = false
        
        // Layout the text by lines.
        text.enumerateSubstrings(in: text.startIndex..., options: .byLines) { (line, _, _, _) in
            guard let line = line else { return }
                        
            // Should this line go on new page?
            if letterPosition.y + 2*lineHeight >= canvasHeight {
                letterPosition = startPosition
                self.drawings.append(PKDrawing())
                currentSide += 1
            }
            
            let words = line.split(separator: " ")
            for word in words {
                // Calculate the word width.
                let wordLength = word.reduce(CGFloat(0)) {
                    guard let letter = self.font!.characters[String($1)] else { return $0 }
                    return $0 + letter.bounds.width * practiceScale + letterSpacing
                }
                
                // Should this word wrap?
                if !didJustWrap && letterPosition.x + wordLength + textMargin > lineWidth {
                    // Should this word wrap on new page?
                    if letterPosition.y + 2*lineHeight >= canvasHeight {
                        letterPosition = startPosition
                        self.drawings.append(PKDrawing())
                        currentSide += 1
                    } else {
                        letterPosition.x = textMargin
                        letterPosition.y += lineHeight
                    }
                    didJustWrap = true
                } else {
                    didJustWrap = false
                }
                
                // Generate the letter.
                for character in word {
                    guard var letter = self.font!.characters[String(character)] else { continue }
                    
                    let bounds = letter.bounds
                    letterPosition.x -= bounds.minX*practiceScale
                                        
                    // Get the letter and align it.
                    letter.transform(using: CGAffineTransform(scaleX: practiceScale, y: practiceScale)
                                        .concatenating(CGAffineTransform(translationX: letterPosition.x, y: letterPosition.y)))
                    self.drawings[currentSide].append(letter)
                    
                    letterPosition.x += bounds.minX*practiceScale
                    
                    letterPosition.x += letter.bounds.width + letterSpacing
                }
                
                // Add a space.
                letterPosition.x += spaceWidth
            }
            
            // Add a line.
            letterPosition.y += lineHeight
            letterPosition.x = textMargin
        }
        
        var scaledDrawings: [PKDrawing] = []
        let scale = drawingHeight / 1116.0

        for drawing in drawings {
            var transformedDrawing: PKDrawing = drawing
            transformedDrawing.transform(using: CGAffineTransform(scaleX: scale, y: scale))
            scaledDrawings.append(transformedDrawing)
        }

        return scaledDrawings
        
    }

    
    func saveToDatabase() {
        var projects: [Project] = Project.loadProjects()
        var projectIDs: [String] = []
        for project in projects {
            projectIDs.append(project.id)
        }
        if projectIDs.contains(self.id) {
            var i: Int = 0
            for project in projects {
                if project.id == self.id {
                    projects[i] = self
                }
                i += 1
            }
        } else {
            projects.insert(self, at: 0)
        }
        
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(projects)
            try data.write(to: projectFilePath!)
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func deleteFromDatabase() {
        var projects: [Project] = Project.loadProjects()
        var projectIDs: [String] = []
        for project in projects {
            projectIDs.append(project.id)
        }
        if projectIDs.contains(self.id) {
            var i: Int = 0
            for project in projects {
                if project.id == self.id {
                    projects.remove(at: i)
                }
                i += 1
            }
        }
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(projects)
            try data.write(to: projectFilePath!)
        } catch {
            print("Error: \(error)")
        }
    }
    
    static func convertImageToRawText(image: UIImage) -> String? {
        var text: String? = nil
        
        guard let cgImage = image.cgImage else { return text }
        
        // Handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        // Request
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                return
            }

            text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: "\n")
        }


        // Process request
        do {
            try handler.perform([request])
        } catch {
            print(error)
            return nil
        }
        
        return text
    }

    
    static func loadProjects() -> [Project] {
        var projects: [Project] = []
        
        if let data = try? Data(contentsOf: projectFilePath!) {
            let decoder = PropertyListDecoder()
            
            do {
                projects = try decoder.decode([Project].self, from: data)
            } catch {
                print("Error: \(error)")
            }
        }
        
        return projects
    }
    
    // temporär um beim entwickeln die Datenbank zu leeren
    static func clearDatabase() {
        let encoder = PropertyListEncoder()
        do {
            let projects: [Project] = []
            let data = try encoder.encode(projects)
            try data.write(to: projectFilePath!)
        } catch {
            print("Error: \(error)")
        }
    }
}
