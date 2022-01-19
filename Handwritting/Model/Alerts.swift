//
//  Alerts.swift
//  Handwritting
//
//  Created by Felix Haag on 25.08.21.
//

import UIKit

func getErrorAlert(title: String, message: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let confirm = UIAlertAction(title: "Ok", style: .cancel, handler: nil)

    alert.addAction(confirm)
    
    return alert
}


