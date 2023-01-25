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

    private var myKey: String = "myKey"
    
    //MARK: - Outlets
    @IBOutlet weak var fontNameTextField: UITextField!
    @IBOutlet weak var drawingsCollectionView: UICollectionView!
    @IBOutlet weak var pencilButton: UIButton!

    
    //MARK: - Attributes
    var letterDrawings: [String: PKDrawing?]
    {
        set {
            let encoder = PropertyListEncoder()
            do {
                try encoder.encode(newValue).write(to: letterDrawingsPath!)
            } catch {
                print("Error: \(error)")
            }
        }
        get {
            if let data = try? Data(contentsOf: letterDrawingsPath!) {
                let decoder = PropertyListDecoder()
                
                do {
                    return try decoder.decode([String: PKDrawing?].self, from: data)
                } catch {
                    print("Error: \(error)")
                }
            }

            return [:]
        }
    }
    
    
    //= Letter.getEmptyLetterArray()
    var letters: [String] = Letter.getLetters()
    
    var font: Font? = nil
    let fonts: [Font] = Font.loadFonts()
    var fontDelegate: fontDelegate!
        
    var toolPicker: PKToolPicker = PKToolPicker()
    var toolPickerResponderView: PKCanvasView?
    
    var activeCell: DrawingCell?
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
        
        letterDrawings = Letter.getEmptyLetterArray()
        
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
    
    /*
    func getLetter(letter: String) -> PKDrawing? {
        if let data = try? Data(contentsOf: letterDrawingsPath!) {
            let decoder = PropertyListDecoder()
            
            do {
                return try decoder.decode([String: PKDrawing?].self, from: data)[letter]!
            } catch {
                print("Error: \(error)")
            }
        }

        return nil
    }
    
    func setLetter(letter: String, drawing: PKDrawing) {
        let encoder = PropertyListEncoder()
        do {
            let decoder = PropertyListDecoder()
            
            do {
                return try decoder.decode([String: PKDrawing?].self, from: data)[letter]!
            } catch {
                print("Error: \(error)")
            }
            let data = try encoder.encode()
            try data.write(to: letterDrawingsPath!)
        } catch {
            print("Error: \(error)")
        }
    }
     */
    
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
        
        // Save active cell
        let visibleCells = drawingsCollectionView.visibleCells
        for cell in visibleCells {
            let drawingCell = cell as! DrawingCell
            if drawingCell.isActive {
                letterDrawings[drawingCell.letterLabel.text!] = drawingCell.drawingView?.drawing
            }
        }
        
        // Check if A canvas view has drawing
        if let drawing = letterDrawings["A"] {
            if drawing!.bounds.height == 0 && drawing!.bounds.width == 0 {
                aCell?.layer.borderColor = UIColor.red.cgColor
                showErrorAlert(errorType: .Empty)
                return
            }
        } else {
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
        
        
        // Store drawings in font
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
            if drawingCell.isActive {
                let drawing = drawingCell.drawingView!.drawing
                letterDrawings[drawingCell.letterLabel.text!] = drawing
                drawingCell.canvasView.image = drawing.image(from: CGRect(x: 0, y: 0, width: 100, height: 128), scale: 1)
                
                // show image
                drawingCell.canvasView.isHidden = false
                
                // clear drawing
                drawingCell.drawingView!.drawing = PKDrawing()
                drawingCell.drawingView!.isHidden = true
                
                cell.layer.borderColor = UIColor.white.cgColor
                drawingCell.layer.borderWidth = 1
                
                drawingCell.isActive = false
            }
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
extension AddFontViewController: UICollectionViewDataSource, PKCanvasViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return letters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = drawingsCollectionView.dequeueReusableCell(withReuseIdentifier: "drawingCell", for: indexPath) as! DrawingCell
        
        let character: String = letters[indexPath.row]
        
        cell.letterLabel.text = character
                
        if letterDrawings[character] != nil {
            let drawing: PKDrawing = letterDrawings[character]!!
            cell.canvasView.image = drawing.image(from: CGRect(x: 0, y: 0, width: 100, height: 128), scale: 1)
        }
        
        cell.canvasView.overrideUserInterfaceStyle = .dark
        
        cell.layer.cornerRadius = 15
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        
        // show image
        cell.canvasView.isHidden = false
        
        
        cell.isActive = false
        
        if indexPath.row == 0 && cell.letterLabel.text == "A" {
            
            cell.drawingView = PKCanvasView()
            cell.insertSubview(cell.drawingView!, at: 1)
            cell.drawingView!.frame = CGRect(x: 0, y: 0, width: 100, height: 128)
            cell.drawingView!.backgroundColor = .clear
            
            if letterDrawings["A"] != nil {
                cell.drawingView!.drawing = letterDrawings["A"]!!
            }
            
            // Handling new active cell
            cell.drawingView!.isHidden = false
            cell.canvasView.isHidden = true
                        
            toolPickerResponderView = cell.drawingView
            toolPicker.setVisible(true, forFirstResponder: toolPickerResponderView!)
            toolPicker.addObserver(cell.drawingView!)
            cell.canvasView.becomeFirstResponder()
             
            cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
            cell.layer.borderWidth = 2
            
            cell.isActive = true
            activeCell = cell
            aCell = cell
        }
        

        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
                    
        return cell
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer?) {
        let cell: DrawingCell = sender?.view as! DrawingCell
        if !cell.isActive {
            
            // Handling previous active cell
            if let activeCell = activeCell {
                // save drawing
                let drawing = activeCell.drawingView!.drawing
                letterDrawings[activeCell.letterLabel.text!] = drawing
                activeCell.canvasView.image = drawing.image(from: CGRect(x: 0, y: 0, width: 100, height: 128), scale: 1)
                
                // show image
                activeCell.canvasView.isHidden = false
                
                // clear drawing
                activeCell.drawingView!.drawing = PKDrawing()
                activeCell.drawingView = nil
                activeCell.willRemoveSubview(activeCell.subviews[1])
                
                activeCell.layer.borderColor = UIColor.white.cgColor
                activeCell.layer.borderWidth = 1
                
                activeCell.isActive = false
            }
            
            cell.drawingView = PKCanvasView()
            cell.insertSubview(cell.drawingView!, at: 1)
            cell.drawingView!.frame = CGRect(x: 0, y: 0, width: 100, height: 128)
            cell.drawingView!.backgroundColor = .clear
            
            // Handling new active cell
            let draw = letterDrawings[cell.letterLabel.text!]
            if draw != nil {
                cell.drawingView!.drawing = draw!!
            }
            
            cell.drawingView!.isHidden = false
            cell.canvasView.isHidden = true
            
            
            toolPickerResponderView = cell.drawingView
            toolPicker.setVisible(true, forFirstResponder: toolPickerResponderView!)
            cell.canvasView.becomeFirstResponder()
            toolPicker.addObserver(cell.drawingView!)
            
            cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
            cell.layer.borderWidth = 2
            
            cell.isActive = true
            activeCell = cell
        }
    }
     
}



extension AddFontViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 128)
    }
}

