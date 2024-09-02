//
//  TopBarViewController.swift
//  Handwritting
//
//  Created by Felix Haag on 04.08.21.
//

import UIKit

var selectedFont: Font?

class TopBarViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var fontCollectionView: UICollectionView!
    
    var fonts: [Font] = Font.loadFonts()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fontCollectionView.delegate = self
        fontCollectionView.dataSource = self
    }
    
    @IBAction func addFontButtonTapped(_ sender: UIButton) {
        let addFontVC = storyboard?.instantiateViewController(identifier: "addFontViewController") as! AddFontViewController
        addFontVC.fontDelegate = self
        present(addFontVC, animated: true, completion: nil)
            
    }
    
}

extension TopBarViewController: fontDelegate {
    func updateFontView(font: Font) {
        fonts = Font.loadFonts()
        fontCollectionView.reloadData()
    }
}

extension TopBarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFont = fonts[indexPath.row]
        let addFontVC = storyboard?.instantiateViewController(identifier: "addFontViewController") as! AddFontViewController
        addFontVC.fontDelegate = self
        present(addFontVC, animated: true, completion: nil)
    }
}

extension TopBarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fonts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = fontCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FontCell
        
        let image = UIImage(data: fonts[indexPath.row].imageData!)
        let resizedImage = getResizedImage(image: image!, imgWidth: 58, imgHeight: 58)
        cell.fontImageView.image = resizedImage
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.cornerRadius = 44
        cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        if fonts[indexPath.row].basicCharactersCompleted == false {
            cell.layer.borderColor = UIColor.red.cgColor
        } 
                
        return cell
        
    }
    
    
}
