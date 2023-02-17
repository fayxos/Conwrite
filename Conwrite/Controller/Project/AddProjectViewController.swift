//
//  AddProjectViewController.swift
//  Handwritting
//
//  Created by Felix Haag on 10.08.21.
//

import UIKit
import PencilKit
import Vision
import VisionKit
import PDFKit
import StoreKit

protocol projectDelegate {
    func updateProjectView(project: Project)
}

class AddProjectViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private let scrollView = UIScrollView()
    
    //MARK: - Attributes
    var project: Project? = nil
    let projects: [Project] = Project.loadProjects()
    var projectDelegate: projectDelegate!
    
    var projectFont: Font?
    let fonts: [Font] = Font.loadFonts()
    
    let sizeOptions: [String] = ["X-Small", "Small", "Medium", "Large", "X-Large"]
    let paperOptions: [String] = ["Quad", "White", "Ruled"]
    var backgroundPaper: BackgroundType = .White
    var letterSize: CGFloat = 0.5
    
    var drawings: [PKDrawing] = [PKDrawing()]
    
    var toolPicker: PKToolPicker = PKToolPicker()
    var toolPickerResponderView: PKCanvasView?
    
    var wasEdited = false
    
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
    
    let tableViewOptions: [(UIImage, String)] = [
        (UIImage(systemName: "photo")!, "Select image from Gallery"),
        (UIImage(systemName: "camera")!, "Take photo with Camera"),
        (UIImage(systemName: "xmark")!, "Project without image")
    ]
    
    
    //MARK: - View Attributes
    var startView: UIView = UIView()
    var imageLabel = UILabel()
    var imageClearButton = UIButton()
    var cameraButton = UIButton()
    var galleryButton = UIButton()
    var scanButton = UIButton()
    var textLabel = UILabel()
    var textClearButton = UIButton()
    var textStepper = UIStepper()
    var fontPickerCollection: UICollectionView?
    var imageView = UIImageView()
    var textView = UITextView()
    var sizeSelector = UISegmentedControl()
    var paperSelector = UISegmentedControl()
    var generateDrawingButton = UIButton()
    
    var drawingView: UIView = UIView()
    var exportLabel = UILabel()
    var pdfButton = UIButton()
    var pngButton = UIButton()
    var copyButton = UIButton()
    var zoomView = UIScrollView()
    var paperImageView = UIImageView()
    var canvasTableView = UITableView()
    
    var canvasHeight: CGFloat = 5656
    var canvasWidth: CGFloat = 4000
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)
        
        projectNameTextField.layer.cornerRadius = 10
        projectNameTextField.layer.borderWidth = 1
        projectNameTextField.layer.borderColor = UIColor.white.cgColor
        
        pencilButton.setImage(UIImage(), for: .normal)
        
        if selectedProject != nil {
            project = selectedProject
            projectNameTextField.text = project?.name
            drawings = project!.drawings
            for font in fonts {
                if font.id == project?.font?.id {
                    projectFont = font
                    break
                }
            }
            selectedProject = nil
        } else {
            var names: [String] = []
            for p in projects {
                names.append(p.name)
            }
            
            var i = 2
            while(names.contains(projectNameTextField.text!)) {
                projectNameTextField.text = "New Project" + String(i)
                i += 1
            }
        }
        
        scrollView.backgroundColor = .none
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        configureViews()
        
        if project != nil {
            textStepper.value = Double(project!.settings[0])
            textView.font = UIFont(name: "Arial", size: project!.settings[0])
            sizeSelector.selectedSegmentIndex = Int(project!.settings[1])
            sizeSelectorValueChanged(sizeSelector)
            paperSelector.selectedSegmentIndex = Int(project!.settings[2])
            paperSelectorValueChanged(paperSelector)
        }
    }
    
    //MARK: - Configure Views
    private func configureViews() {
        // Start View
        startView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height-200))
        startView.backgroundColor = .none
        startView.isUserInteractionEnabled = true
        
        // Labels
        imageLabel = UILabel(frame: CGRect(x: 30, y: 14, width: 120, height: 32))
        imageLabel.text = "Select Image"
        imageLabel.textAlignment = .center
        imageLabel.backgroundColor = .systemGray3
        imageLabel.layer.cornerRadius = 10
        imageLabel.clipsToBounds = true
        
        textLabel = UILabel(frame: CGRect(x: startView.frame.size.width/2+15, y: 14, width: 120, height: 32))
        textLabel.text = "Write Text"
        textLabel.textAlignment = .center
        textLabel.backgroundColor = .systemGray3
        textLabel.layer.cornerRadius = 10
        textLabel.clipsToBounds = true
        
        // Buttons
        
        galleryButton = UIButton(frame: CGRect(x: 160, y: 14, width: 50, height: 32))
        galleryButton.backgroundColor = .systemGray
        galleryButton.layer.cornerRadius = 10
        galleryButton.clipsToBounds = true
        galleryButton.setImage(UIImage(systemName: "photo"), for: .normal)
        galleryButton.tintColor = .systemBackground
        galleryButton.addTarget(self, action: #selector(selectImageFromGallery(_:)), for: .touchUpInside)
        
        cameraButton = UIButton(frame: CGRect(x: 220, y: 14, width: 50, height: 32))
        cameraButton.backgroundColor = .systemGray
        cameraButton.layer.cornerRadius = 10
        cameraButton.clipsToBounds = true
        cameraButton.setImage(UIImage(systemName: "camera"), for: .normal)
        cameraButton.tintColor = .systemBackground
        cameraButton.addTarget(self, action: #selector(selectImageFromCamera(_:)), for: .touchUpInside)
        
        scanButton = UIButton(frame: CGRect(x: 280, y: 14, width: 50, height: 32))
        scanButton.backgroundColor = .systemGray
        scanButton.layer.cornerRadius = 10
        scanButton.clipsToBounds = true
        scanButton.setImage(UIImage(systemName: "doc.text.viewfinder"), for: .normal)
        scanButton.tintColor = .systemBackground
        scanButton.addTarget(self, action: #selector(selectImageFromScan(_:)), for: .touchUpInside)
        
        imageClearButton = UIButton(frame: CGRect(x: startView.frame.size.width/2-15-50, y: 14, width: 50, height: 32))
        imageClearButton.backgroundColor = .systemGray
        imageClearButton.layer.cornerRadius = 10
        imageClearButton.clipsToBounds = true
        imageClearButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        imageClearButton.tintColor = .systemBackground
        imageClearButton.addTarget(self, action: #selector(clearImage(_:)), for: .touchUpInside)
        
        textStepper = UIStepper(frame: CGRect(x: startView.frame.size.width/2+15+120+10, y: 14, width: 100, height: 30))
        textStepper.backgroundColor = .systemGray
        textStepper.layer.cornerRadius = 10
        textStepper.clipsToBounds = true
        textStepper.minimumValue = 10
        textStepper.maximumValue = 50
        textStepper.value = 20
        textStepper.stepValue = 2
        textStepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .touchUpInside)
        
        textClearButton = UIButton(frame: CGRect(x: startView.frame.size.width-30-50, y: 14, width: 50, height: 32))
        textClearButton.backgroundColor = .systemGray
        textClearButton.layer.cornerRadius = 10
        textClearButton.clipsToBounds = true
        textClearButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        textClearButton.tintColor = .systemBackground
        textClearButton.addTarget(self, action: #selector(clearText(_:)), for: .touchUpInside)
        
        // Image View
        imageView = UIImageView(frame: CGRect(x: 30, y: 50, width: startView.frame.size.width/2-45, height: (startView.frame.size.width/2-45)/5*7))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "placeholder")!
        if project != nil {
            if project?.imageData != nil {
                imageView.image = UIImage(data: (project?.imageData)!)!
            }
        }
        
        // Text View
        textView = UITextView(frame: CGRect(x: startView.frame.size.width/2+15, y: 50, width: startView.frame.size.width/2-45, height: (startView.frame.size.width/2-45)/5*7))
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.layer.cornerRadius = 15
        textView.font = UIFont(name: "Arial", size: 20)
        textView.delegate = self
        if project != nil {
            textView.text = project!.rawText!
        }

        
        // Font Picker Collection View
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.itemSize = CGSize(width: 88, height: 88)
        collectionViewLayout.minimumInteritemSpacing = 10
        
        fontPickerCollection = UICollectionView(frame: CGRect(x: 30, y: 50+50+((startView.frame.size.width/2-45)/5*7), width: startView.frame.size.width-60, height: 108), collectionViewLayout: collectionViewLayout)
        fontPickerCollection?.translatesAutoresizingMaskIntoConstraints = false
        fontPickerCollection!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        fontPickerCollection!.backgroundColor = .none
        fontPickerCollection!.delegate = self
        fontPickerCollection!.dataSource = self

        // Size selection
        sizeSelector = UISegmentedControl(items: sizeOptions)
        sizeSelector.selectedSegmentIndex = 2
        sizeSelector.translatesAutoresizingMaskIntoConstraints = false
        sizeSelector.backgroundColor = .systemGray4
        sizeSelector.tintColor = .systemGray2
        sizeSelector.addTarget(self, action: #selector(sizeSelectorValueChanged(_:)), for: .valueChanged)
        
        // Paper selector
        paperSelector = UISegmentedControl(items: paperOptions)
        paperSelector.selectedSegmentIndex = 1
        paperSelector.translatesAutoresizingMaskIntoConstraints = false
        paperSelector.backgroundColor = .systemGray4
        paperSelector.tintColor = .systemGray2
        paperSelector.addTarget(self, action: #selector(paperSelectorValueChanged(_:)), for: .valueChanged)
        
        // Button
        generateDrawingButton = UIButton()
        generateDrawingButton.translatesAutoresizingMaskIntoConstraints = false
        generateDrawingButton.setTitle("Generate Drawing", for: .normal)
        generateDrawingButton.titleLabel?.font = UIFont(name: "Arial", size: 28)
        generateDrawingButton.setTitleColor(UIColor(red: 50/255, green: 48/255, blue: 49/255, alpha: 1), for: .normal)
        generateDrawingButton.backgroundColor = UIColor(displayP3Red: 255/255, green: 200/255, blue: 87/255, alpha: 1)
        generateDrawingButton.layer.cornerRadius = 15
        generateDrawingButton.isUserInteractionEnabled = true
        generateDrawingButton.addTarget(self, action: #selector(generateDrawing(_:)), for: .touchUpInside)
                        
        // Add subviews
        startView.addSubview(imageLabel)
        startView.addSubview(textLabel)
        startView.addSubview(imageClearButton)
        startView.addSubview(textClearButton)
        startView.addSubview(textStepper)
        startView.addSubview(cameraButton)
        startView.addSubview(galleryButton)
        startView.addSubview(scanButton)
        startView.addSubview(imageView)
        startView.addSubview(textView)
        startView.addSubview(fontPickerCollection!)
        startView.addSubview(generateDrawingButton)
        startView.addSubview(sizeSelector)
        startView.addSubview(paperSelector)
        
        sizeSelector.centerXAnchor.constraint(equalTo: startView.centerXAnchor).isActive = true
        sizeSelector.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 30).isActive = true
        
        paperSelector.centerXAnchor.constraint(equalTo: startView.centerXAnchor).isActive = true
        paperSelector.topAnchor.constraint(equalTo: sizeSelector.bottomAnchor, constant: 30).isActive = true
        
        generateDrawingButton.widthAnchor.constraint(equalToConstant: 280).isActive = true
        generateDrawingButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        generateDrawingButton.centerXAnchor.constraint(equalTo: startView.centerXAnchor).isActive = true
        generateDrawingButton.bottomAnchor.constraint(equalTo: startView.bottomAnchor).isActive = true
        
        fontPickerCollection!.heightAnchor.constraint(equalToConstant: 108).isActive = true
        fontPickerCollection!.widthAnchor.constraint(equalToConstant: CGFloat(fonts.count*88+10*(fonts.count-1))).isActive = true
        fontPickerCollection!.centerXAnchor.constraint(equalTo: startView.centerXAnchor).isActive = true
        fontPickerCollection!.topAnchor.constraint(equalTo: paperSelector.bottomAnchor, constant: 30).isActive = true
        
        // Drawing View
        drawingView = UIView(frame: CGRect(x: view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height-200))
        drawingView.backgroundColor = .none
        drawingView.isUserInteractionEnabled = true
        
        // Canvas Table View
        canvasTableView = UITableView()
        canvasTableView.translatesAutoresizingMaskIntoConstraints = false
        canvasTableView.backgroundColor = .clear
        canvasTableView.rowHeight = drawingView.frame.size.height-40
        canvasTableView.separatorStyle = .singleLine
        canvasTableView.separatorInset = .zero
        canvasTableView.separatorColor = .darkGray
        canvasTableView.allowsSelection = false
        canvasTableView.dataSource = self
        
        // Zoom View (not used right now)
        zoomView = UIScrollView()
        zoomView.translatesAutoresizingMaskIntoConstraints = false
        zoomView.isScrollEnabled = true
        zoomView.addSubview(canvasTableView)
        
        // Export
        exportLabel = UILabel()
        exportLabel.text = "Edit Drawing"
        exportLabel.textAlignment = .center
        exportLabel.backgroundColor = .systemGray3
        exportLabel.clipsToBounds = true
        exportLabel.layer.cornerRadius = 10
        exportLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pdfButton = UIButton()
        pdfButton.setTitle("PDF", for: .normal)
        pdfButton.setTitleColor(.systemBackground, for: .normal)
        pdfButton.backgroundColor = .systemGray
        pdfButton.clipsToBounds = true
        pdfButton.layer.cornerRadius = 10
        pdfButton.translatesAutoresizingMaskIntoConstraints = false
        pdfButton.addTarget(self, action: #selector(exportPdf(_:)), for: .touchUpInside)
        
        pngButton = UIButton()
        pngButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        pngButton.tintColor = .systemBackground
        pngButton.backgroundColor = .systemGray
        pngButton.clipsToBounds = true
        pngButton.layer.cornerRadius = 10
        pngButton.translatesAutoresizingMaskIntoConstraints = false
        pngButton.addTarget(self, action: #selector(exportPng(_:)), for: .touchUpInside)
        
        copyButton = UIButton()
        copyButton.setImage(UIImage(systemName: "square.on.square"), for: .normal)
        copyButton.tintColor = .systemBackground
        copyButton.backgroundColor = .systemGray
        copyButton.clipsToBounds = true
        copyButton.layer.cornerRadius = 10
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        drawingView.addSubview(exportLabel)
        drawingView.addSubview(pngButton)
        drawingView.addSubview(zoomView)
        
        zoomView.topAnchor.constraint(equalTo: drawingView.topAnchor, constant: 50).isActive = true
        zoomView.centerXAnchor.constraint(equalTo: drawingView.centerXAnchor).isActive = true
        zoomView.heightAnchor.constraint(equalToConstant: drawingView.frame.size.height-40).isActive = true
        zoomView.widthAnchor.constraint(equalToConstant: (drawingView.frame.size.height-50)/7*5).isActive = true
        
        canvasTableView.topAnchor.constraint(equalTo: drawingView.topAnchor, constant: 50).isActive = true
        canvasTableView.centerXAnchor.constraint(equalTo: drawingView.centerXAnchor).isActive = true
        canvasTableView.heightAnchor.constraint(equalToConstant: drawingView.frame.size.height-40).isActive = true
        canvasTableView.widthAnchor.constraint(equalToConstant: (drawingView.frame.size.height-50)/7*5).isActive = true
        
        exportLabel.leadingAnchor.constraint(equalTo: zoomView.leadingAnchor).isActive = true
        exportLabel.topAnchor.constraint(equalTo: zoomView.topAnchor, constant: -36).isActive = true
        exportLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true
        exportLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        pngButton.trailingAnchor.constraint(equalTo: zoomView.trailingAnchor).isActive = true
        pngButton.heightAnchor.constraint(equalTo: exportLabel.heightAnchor).isActive = true
        pngButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pngButton.topAnchor.constraint(equalTo: exportLabel.topAnchor).isActive = true
        
        
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        textView.font = UIFont(name: "Arial", size: CGFloat(sender.value))
    }
    
    @objc func sizeSelectorValueChanged(_ sender: UISegmentedControl) {
        wasEdited = true
        
        switch sender.selectedSegmentIndex {
        case 0:
            letterSize = 0.3
        case 1:
            letterSize = 0.4
        case 2:
            letterSize = 0.5
        case 3:
            letterSize = 0.6
        case 4:
            letterSize = 0.7
        default:
            letterSize = 0.5
        }
    }
    
    @objc func paperSelectorValueChanged(_ sender: UISegmentedControl) {
        wasEdited = true
        
        switch sender.selectedSegmentIndex {
        case 0:
            backgroundPaper = .Quad
        case 1:
            backgroundPaper = .White
        case 2:
            backgroundPaper = .Ruled
        default:
            letterSize = 0.5
        }
    }
    
    //MARK: - Select Image Functions
    @objc func clearImage(_ : UIButton) {
        wasEdited = true
        
        imageView.image = UIImage(named: "placeholder")
    }
    
    @objc func selectImageFromGallery(_ sender : UIButton) {
        wasEdited = true
        
        sender.backgroundColor = .systemGray
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @objc func selectImageFromCamera(_ : UIButton) {
        wasEdited = true
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @objc func selectImageFromScan(_ : UIButton) {
        wasEdited = true
        
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    @objc func clearText(_ : UIButton) {
        wasEdited = true
        
        textView.text = ""
    }
    
    //MARK: - Export Image Functions
    @objc func exportPdf(_ sender: UIButton) {
        
    }
    
    @objc func exportPng(_ sender: UIButton) {
        
        let images = getImages()
        
        let activity = UIActivityViewController(activityItems: images, applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = drawingView
        activity.popoverPresentationController?.sourceRect = CGRect(x: drawingView.frame.width/2-50, y: 0, width: 100, height: 100)
        activity.title = "Drawing.png"
        present(activity, animated: true, completion: nil)
        
        
    }
    
    func getImages() -> [UIImage] {
        var images: [UIImage] = []
        for drawing in drawings {
            let canvasSize = (canvasTableView.visibleCells[0] as! GeneratedDrawingCell).canvasView.frame.size
            
            
            UIGraphicsBeginImageContextWithOptions(canvasSize, false, UIScreen.main.scale)
            if backgroundPaper != .White {
                let backgroundImage = UIImage(named: backgroundPaper.rawValue)
                backgroundImage?.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
            }
            
            let drawingImage = drawing.image(from: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height), scale: 10)
            drawingImage.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            if image != nil {
                images.append(image!)
            }
        }
        
        return images
    }
    
    //MARK: - Generate Drawing
    @objc func generateDrawing(_ : UIButton) {
        wasEdited = true
        
        // Save changes to project
        if project == nil {
            project = Project(name: "", drawings: drawings)
        }
        
        // Check if there is any text
        if textView.text == nil {
            showAlert(alert: getErrorAlert(title: "Couldn't generate Drawing", message: "Enter some text"))
            return
        } else if textView.text!.isEmpty || textView.text! == "Enter Text" {
            showAlert(alert: getErrorAlert(title: "Couldn't generate Drawing", message: "Enter some text"))
            return
        } else {
            project?.rawText = textView.text
        }
        
        // Check if font is selected
        if projectFont == nil {
            showAlert(alert: getErrorAlert(title: "Couldn't generate Drawing", message: "Select an handwriting"))
            return
        } else {
            project?.font = projectFont!
        }
        
        // Change Pages
        scrollView.setContentOffset(CGPoint(x: CGFloat(1) * view.frame.size.width, y: 0), animated: true)
        
        // Generate Drawing
        drawings = project!.convertTextToDrawing(practiceScale: letterSize, lineWidth: (drawingView.frame.size.height-50)/7*5, canvasHeight: drawingView.frame.size.height-50, backgroundType: backgroundPaper)
        canvasTableView.reloadData()
        
    }
    
    
    //MARK: - page control value changed
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        wasEdited = true
        
        let current = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(current) * view.frame.size.width, y: 0), animated: true)
    }
    
    //MARK: - ViewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 120, width: view.frame.size.width, height: view.frame.size.height-200)
        
        if scrollView.subviews.count == 2 {
            configureScrollView()
        }
    }
    
    //MARK: - Configure ScrollView
    private func configureScrollView() {
        scrollView.contentSize = CGSize(width: view.frame.size.width*2, height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        scrollView.addSubview(startView)
        scrollView.addSubview(drawingView)
    }
    
    //MARK: - Touches Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - TF Begin Editing
    @IBAction func textFiledEditingDidBegin(_ sender: UITextField) {
    }
    
    //MARK: - TF Editing Change
    @IBAction func textFiledEditingChanged(_ sender: UITextField) {
        wasEdited = true
        
        // Get all projects names
        var projectNames: [String] = []
        for p in projects {
            projectNames.append(p.name)
        }
        
        // Check if name is nil
        if projectNameTextField.text == nil {
            projectNameTextField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        // Check if name is empty or not unique
        if projectNameTextField.text!.isEmpty || projectNameTextField.text?.first == " " || projectNames.contains(projectNameTextField.text!) {
            projectNameTextField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        projectNameTextField.layer.borderColor = UIColor.white.cgColor
    }
    
    //MARK: - TF End Edtiting
    @IBAction func textFieldDidEndEditing(_ sender: UITextField) {
    }
    
    //MARK: - SwapEditingButton
    @IBAction func swapEditingButtonTapped(_ sender: UIButton) {
        drawingIsEditing = !drawingIsEditing
    }
    
    //MARK: - BackButton
    @IBAction func backButtonTappeds(_ sender: UIButton) {
        if !wasEdited {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        var message: String
        
        if project == nil {
            message = "Project wasn't saved yet!"
        } else {
            message = "All changes get lost!"
        }
        
        let alert = UIAlertController(title: "Really want to return?", message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in

        }
        
        let confirm = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - BackButton
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if project == nil {
            self.dismiss(animated: true, completion: nil)
            return
        } else {
            let alert = UIAlertController(title: "Delete this project?", message: "Can't be restored", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)  { (action) in
 
            }
            
            let confirm = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                self.project?.deleteFromDatabase()
                self.projectDelegate.updateProjectView(project: self.project!)
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(cancel)
            alert.addAction(confirm)
            present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - SaveButton
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Get all project names
        var projectNames: [String] = []
        for p in projects {
            projectNames.append(p.name)
        }
        
        // Check if name is nil
        if projectNameTextField.text == nil {
            projectNameTextField.layer.borderColor = UIColor.red.cgColor
            showAlert(alert: getErrorAlert(title: "Couldn't save Project", message: AddProjectErrorType.Name.rawValue))
            return
        }
        
        // Check if name is empty
        if projectNameTextField.text!.isEmpty || projectNameTextField.text?.first == " "{
            projectNameTextField.layer.borderColor = UIColor.red.cgColor
            showAlert(alert: getErrorAlert(title: "Couldn't save Project", message: AddProjectErrorType.Name.rawValue))
            return
        }
        
        // Check if name is unique if new font
        if project == nil {
            if projectNames.contains(projectNameTextField.text!) {
                projectNameTextField.layer.borderColor = UIColor.red.cgColor
                showAlert(alert: getErrorAlert(title: "Couldn't save Project", message: AddProjectErrorType.Name.rawValue))
                return
            }
        } else {
            if projectNameTextField.text != project?.name {
                if projectNames.contains(projectNameTextField.text!) {
                    projectNameTextField.layer.borderColor = UIColor.red.cgColor
                    showAlert(alert: getErrorAlert(title: "Couldn't save Project", message: AddProjectErrorType.Name.rawValue))
                    return
                }
            }
        }
        
        // Check if there is there is anything to save
        if projectFont == nil && textView.text == nil {
            showAlert(alert: getErrorAlert(title: "Couldn't save Project", message: AddProjectErrorType.Empty.rawValue))
            return
        } else if textView.text!.isEmpty {
            showAlert(alert: getErrorAlert(title: "Couldn't save Project", message: AddProjectErrorType.Empty.rawValue))
            return
        }
        
        // Save changes to project
        if project == nil {
            project = Project(name: projectNameTextField.text!, drawings: drawings)
        } else {
            project?.name = projectNameTextField.text!
            project?.drawings = drawings
        }
        
        // Update Settings
        let settings = [CGFloat(textStepper.value), CGFloat(sizeSelector.selectedSegmentIndex), CGFloat(paperSelector.selectedSegmentIndex)]
        project?.settings = settings
        
        // Update font
        if projectFont != nil {
            project?.font = projectFont!
        }

        // Update image
        if imageView.image != nil {
            project?.imageData = imageView.image!.pngData()
        } else {
            project?.imageData = UIImage(named: "placeholder")!.pngData()
        }
        
        // Update raw text
        if textView.text != nil && !textView.text.isEmpty && textView.text != "Enter Text" {
            project?.rawText = textView.text
        }
        
        
        // App Store Review ?
        // If the app doesn't store the count, this returns 0.
        var count = UserDefaults.standard.integer(forKey: "processCompletedCountKey")
        count += 1
        UserDefaults.standard.set(count, forKey: "processCompletedCountKey")
        print("Process completed \(count) time(s).")

        // Keep track of the most recent app version that prompts the user for a review.
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersionPromptedForReviewKey")
        
        // Get the current bundle version for the app.
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary.") }
                
         // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
         if count >= 2 && currentVersion != lastVersionPromptedForReview {
             
             Task { @MainActor [weak self] in
                 // Delay for two seconds to avoid interrupting the person using the app.
                 // Use the equation n * 10^9 to convert seconds to nanoseconds.
                 try? await Task.sleep(nanoseconds: UInt64(2e9))
                 if let windowScene = self?.navigationController?.topViewController?.view.window?.windowScene {
                     SKStoreReviewController.requestReview(in: windowScene)
                     UserDefaults.standard.set(currentVersion, forKey: "lastVersionPromptedForReviewKey")
                }
             }
         }
        
        // Save project
        project?.saveToDatabase()
        projectDelegate.updateProjectView(project: project!)
        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - showAlert
    func showAlert(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Scan Extension
extension AddProjectViewController: VNDocumentCameraViewControllerDelegate {
    
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        if scan.pageCount > 1 {
            let alert = UIAlertController(title: "Too much scans", message: "Only the first scan will be used", preferredStyle: .alert)
            
            let confirm = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        
            alert.addAction(confirm)
            present(alert, animated: true, completion: nil)
        }
            
        let image = scan.imageOfPage(at: 0)
            
        // Text erkennen
        let detectedText = Project.convertImageToRawText(image: image)
        
        if let text = detectedText {
            if !text.isEmpty {
                
                // text in text view speichern
                textView.text = text
                
                imageView.image = image
                                    
                controller.dismiss(animated: true, completion: nil)
                return
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
        
        // Alert -> kein text erkannt
        let alert = UIAlertController(title: "Something went wrong", message: "AI couldn't find any text", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK: - CTV DataSource Extension
extension AddProjectViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drawings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = GeneratedDrawingCell()
                
        cell.backgroundColor = UIColor(red: 50/255, green: 48/255, blue: 49/255, alpha: 1)
        cell.isUserInteractionEnabled = true
        
        cell.backgroundColor = .clear
        
        cell.backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: (drawingView.frame.size.height-50)/7*5, height: drawingView.frame.size.height-50))
        cell.backgroundImageView.image = UIImage(named: backgroundPaper.rawValue)
        
        cell.canvasView = PKCanvasView(frame: CGRect(x: 0, y: 0, width: (drawingView.frame.size.height-50)/7*5, height: drawingView.frame.size.height-50))
        cell.canvasView.overrideUserInterfaceStyle = .dark
        if backgroundPaper == .White {
            cell.canvasView.backgroundColor = .white
        } else {
            cell.canvasView.backgroundColor = .clear
        }
        cell.canvasView.alwaysBounceVertical = true
        cell.canvasView.drawing = drawings[indexPath.row]
        
        cell.canvasView.delegate = self
                
        if indexPath.row == 0 {
            toolPickerResponderView = cell.canvasView
        }
        toolPicker.addObserver(cell.canvasView)
        
        return cell
    }

}

//MARK: - CV Delegate Extension
extension AddProjectViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let cell = (canvasView.superview as! GeneratedDrawingCell)
        let indexPath = canvasTableView.indexPath(for: cell)
        drawings[indexPath!.row] = canvasView.drawing
    }
}


//MARK: - IP Delegate Extension
extension AddProjectViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            
            var detectedText: String?
            
            detectedText = Project.convertImageToRawText(image: image)
            
            if detectedText != nil {
                if !detectedText!.isEmpty {
                    textView.text = detectedText
                    
                    imageView.image = image
                    
                    return
                }
            }
                                            
            // Alert -> kein text erkannt
            let alert = UIAlertController(title: "Something went wrong", message: "AI couldn't find any text", preferredStyle: .alert)
            
            let confirm = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        
            alert.addAction(confirm)
            present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - SV Delegate Extension
extension AddProjectViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.size.width)))
        if page == 1 {
            view.endEditing(true)
            drawingIsEditing = true
        } else {
            if drawingIsEditing {
                drawingIsEditing = false
            }
            pencilButton.setImage(UIImage(), for: .normal)
        }
        pageControl.currentPage = page
    }
}

//MARK: - CV Delegate Extension
extension AddProjectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let font = fonts[indexPath.row]
        if font.allCharactersCompleted {
            projectFont = font
            
            fontPickerCollection!.reloadData()
        }

    }
}

//MARK: - CV DataSource Extension
extension AddProjectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fonts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = fontPickerCollection!.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let image = UIImage(data: fonts[indexPath.row].imageData!)
        let resizedImage = getResizedImage(image: image!, imgWidth: 58, imgHeight: 58)
        
        let backgroundImageView = UIImageView(frame: CGRect(x: 15, y: 15, width: 58, height: 58))
        backgroundImageView.image = UIImage(named: "FontBackground")!
        
        let imageView = UIImageView(frame: CGRect(x: 15, y: 15, width: 58, height: 58))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = resizedImage
        
        cell.addSubview(backgroundImageView)
        cell.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.cornerRadius = 44
        cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        if fonts[indexPath.row].allCharactersCompleted == false {
            cell.layer.borderColor = UIColor.red.cgColor
        } else if fonts[indexPath.row].id == projectFont?.id {
            cell.layer.borderWidth = 4
            cell.layer.borderColor = UIColor(displayP3Red: 255/255, green: 200/255, blue: 87/255, alpha: 1).cgColor
        }
                
        return cell
        
    }
    
    
}


//MARK: - TV Delegate Extension
extension AddProjectViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        wasEdited = true
    }
}
