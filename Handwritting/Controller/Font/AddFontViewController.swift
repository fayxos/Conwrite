//
//  AddFontViewController.swift
//  Handwritting
//
//  Created by Felix Haag on 07.08.21.
//

import UIKit
import PencilKit

protocol fontDelegate {
    func updateFontView(font: Font)
}

class AddFontViewController: UIViewController, PKToolPickerObserver {

    //MARK: - Outlets
    @IBOutlet weak var fontNameTextField: UITextField!
    @IBOutlet weak var drawingsCollectionView: UICollectionView!
    @IBOutlet weak var pencilButton: UIButton!
    
    //MARK: - Attributes
    var letterDrawings: [String: PKDrawing?] = Letter.getEmptyLetterArray()
    var letters: [String] = Letter.getLetters()
    
    var font: Font? = nil
    let fonts: [Font] = Font.loadFonts()
    var fontDelegate: fontDelegate!
        
    var toolPicker: PKToolPicker = PKToolPicker()
    var toolPickerResponderView: PKCanvasView?
    var aCell: DrawingCell?
    
    var drawingIsEditing: Bool = true {
        didSet {
            if drawingIsEditing {
                pencilButton.setImage(UIImage(systemName: "pencil.slash"), for: .normal)
            } else {
                pencilButton.setImage(UIImage(systemName: "pencil"), for: .normal)
            }
            toolPicker.setVisible(drawingIsEditing, forFirstResponder: toolPickerResponderView!)
            toolPickerResponderView?.becomeFirstResponder()
        }
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fontNameTextField.layer.cornerRadius = 10
        fontNameTextField.layer.borderWidth = 1
        fontNameTextField.layer.borderColor = UIColor.white.cgColor
        
        drawingsCollectionView.delegate = self
        drawingsCollectionView.dataSource = self
        drawingsCollectionView.isEditing = true
        
        pencilButton.setImage(UIImage(systemName: "pencil.slash"), for: .normal)
        
        if selectedFont != nil {
            font = selectedFont
            fontNameTextField.text = font?.name
            for (key, value) in font!.characters {
                letterDrawings[key] = value
            }
            selectedFont = nil
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    //MARK: - TouchesBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        if toolPicker.isVisible == false {
            drawingIsEditing = true
        }
    }
    
    //MARK: - TF EditingBegan
    @IBAction func textFieldEditingBegan(_ sender: Any) {
        if drawingIsEditing == true {
            pencilButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        }
    }
    
    //MARK: - TF EditingDidChange
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        // Get all font names
        var fontNames: [String] = []
        for f in fonts {
            fontNames.append(f.name)
        }
        
        // Check if name is nil
        if fontNameTextField.text == nil {
            fontNameTextField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        // Check if name is empty or not unique
        if fontNameTextField.text!.isEmpty || fontNameTextField.text?.first == " " || fontNames.contains(fontNameTextField.text!) {
            fontNameTextField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        fontNameTextField.layer.borderColor = UIColor.white.cgColor
    }
    
    //MARK: - TF EditingDidEnd
    @IBAction func textFieldEditingDidEnd(_ sender: UITextField) {
        if drawingIsEditing == true {
            pencilButton.setImage(UIImage(systemName: "pencil.slash"), for: .normal)
            toolPicker.setVisible(true, forFirstResponder: toolPickerResponderView!)
            toolPickerResponderView?.becomeFirstResponder()
        }
    }
    
    //MARK: - SwapEditingButton
    @IBAction func swapEditingButtonTapped(_ sender: UIButton) {
        drawingIsEditing = !drawingIsEditing
        
        
        
    }
    
    //MARK: - BackButton
    @IBAction func backButtonTapped(_ sender: UIButton) {
        print("Back button Tapped")
        
        toolPicker.setVisible(false, forFirstResponder: toolPickerResponderView!)
        toolPickerResponderView?.becomeFirstResponder()
        
        var message: String
        
        if font == nil {
            message = "Handwriting wasn't saved yet!"
        } else {
            message = "All changes get lost!"
        }
        
        let alert = UIAlertController(title: "Really want to return?", message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [self] (action) in
            self.toolPicker.setVisible(true, forFirstResponder: self.toolPickerResponderView!)
            self.toolPickerResponderView?.becomeFirstResponder()
        }
        
        let confirm = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - DeleteButton
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        
        toolPicker.setVisible(false, forFirstResponder: toolPickerResponderView!)
        toolPickerResponderView?.becomeFirstResponder()
        
        if font == nil {
            let alert = UIAlertController(title: "Handwriting wasn't created yet", message: "You can't delete a non-existing Handwriting", preferredStyle: .alert)
            
            let confirm = UIAlertAction(title: "Ok", style: .cancel, handler: nil)

            alert.addAction(confirm)
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Delete this font?", message: "Can't be restored", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)  { [self] (action) in
                self.toolPicker.setVisible(true, forFirstResponder: self.toolPickerResponderView!)
                self.toolPickerResponderView?.becomeFirstResponder()
            }
            
            let confirm = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                self.font?.deleteFromDatabase()
                self.fontDelegate.updateFontView(font: self.font!)
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - SaveButton
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Get all font names
        var fontNames: [String] = []
        for f in fonts {
            fontNames.append(f.name)
        }
        
        // Check if name is nil
        if fontNameTextField.text == nil {
            fontNameTextField.layer.borderColor = UIColor.red.cgColor
            showErrorAlert(errorType: .Name)
            return
        }
        
        // Check if name is empty
        if fontNameTextField.text!.isEmpty || fontNameTextField.text?.first == " "{
            fontNameTextField.layer.borderColor = UIColor.red.cgColor
            showErrorAlert(errorType: .Name)
            return
        }
        
        // Check if name is unique if new font
        if font == nil {
            if fontNames.contains(fontNameTextField.text!) {
                fontNameTextField.layer.borderColor = UIColor.red.cgColor
                showErrorAlert(errorType: .Name)
                return
            }
        } else {
            if fontNameTextField.text != font?.name {
                if fontNames.contains(fontNameTextField.text!) {
                    fontNameTextField.layer.borderColor = UIColor.red.cgColor
                    showErrorAlert(errorType: .Name)
                    return
                }
            }
        }
        
        // Check if A canvas view has drawing
        if aCell!.canvasView.drawing.bounds.height == 0 && aCell!.canvasView.drawing.bounds.width == 0 {
            aCell?.layer.borderColor = UIColor.red.cgColor
            showErrorAlert(errorType: .Empty)
            return
        }
        
        // Save changes to font
        if font == nil {
            var drawings: [String: PKDrawing] = [:]
            for (key, _) in letterDrawings {
                drawings[key] = PKDrawing()
            }
            font = Font(name: fontNameTextField.text!, characters: drawings)
        } else {
            font?.name = fontNameTextField.text!
        }
        
        // update letterDrawings
        let cells = drawingsCollectionView.visibleCells
        for cell in cells {
            let drawingCell = cell as! DrawingCell
            letterDrawings[drawingCell.letterLabel.text!] = drawingCell.canvasView.drawing
        }
        
        
        for (key, drawing) in letterDrawings {
            font?.addCharacter(character: key, drawing: drawing!)
        }
        
        
        // Save font
        font?.saveToDatabase()
        fontDelegate.updateFontView(font: font!)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - ErrorAlert
    func showErrorAlert(errorType: AddFontErrorType) {
        let alert = UIAlertController(title: "Cuoldn't save Handwriting", message: errorType.rawValue, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - ScrollViewBeginDragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let visibleCells = drawingsCollectionView.visibleCells
        for cell in visibleCells {
            let drawingCell = cell as! DrawingCell
            let drawing = drawingCell.canvasView.drawing
            letterDrawings[drawingCell.letterLabel.text!] = drawing
        }
    }
    
}

//MARK: - CV Delegate Extension
extension AddFontViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if toolPicker.isVisible == false {
            drawingIsEditing = true
        }
    }
}

//MARK: - CV DataSource Extension
extension AddFontViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return letters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = drawingsCollectionView.dequeueReusableCell(withReuseIdentifier: "drawingCell", for: indexPath) as! DrawingCell
        
        let character: String = letters[indexPath.row]
        
        cell.letterLabel.text = character

                
        if letterDrawings[character] != nil {
            let drawing: PKDrawing = letterDrawings[character]!!
            cell.canvasView.drawing = drawing
        } else {
            cell.canvasView.drawing = PKDrawing()
        }
        
        cell.canvasView.overrideUserInterfaceStyle = .dark
        
        cell.layer.cornerRadius = 15
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        
        if indexPath.row == 0 && cell.letterLabel.text == "A" {
            toolPickerResponderView = cell.canvasView
            toolPicker.setVisible(true, forFirstResponder: toolPickerResponderView!)
            cell.canvasView.becomeFirstResponder()
            
            aCell = cell
        }
        
        toolPicker.addObserver(cell.canvasView)
                    
        return cell
    }
}

extension AddFontViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 128)
    }
}

