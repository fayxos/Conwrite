//
//  ExportType.swift
//  Handwritting
//
//  Created by Felix Haag on 07.08.21.
//

import UIKit

enum ExportType {
    case Image
    case Drawing
    case Pdf
}

enum ProjectType {
    case Gallery
    case Photo
    case Text
}

enum AddFontErrorType: String {
    case Name = "Enter unique and valid name"
    case Empty = "Letter A is required"
    case Unknown = "There was an unexpected error"
}

enum AddProjectErrorType: String {
    case Name = "Enter unique and valid name"
    case Font = "You have to choose an handwriting"
    case Empty = "There is nothing to save"
    case Unknown = "There was an unexpected error"
}

enum BackgroundType: String {
    case White = ""
    case Quad = "kariert"
    case Ruled = "liniert"
}
