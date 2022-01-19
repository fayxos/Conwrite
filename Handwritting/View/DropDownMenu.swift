//
//  DropDownMenu.swift
//  Handwritting
//
//  Created by Felix Haag on 10.08.21.
//

import UIKit

protocol dropDownDelegate {
    func dropDownItemPressed(selectedOption: ProjectType)
}

class dropDownView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var dropDownOptions: [(UIImage, String)]
    
    var tableView = UITableView()
    
    var dDDelegate: dropDownDelegate!
        
    init(frame: CGRect, dropDownOptions: [(UIImage, String)]) {
        self.dropDownOptions = dropDownOptions
        super.init(frame: frame)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.lightGray
        
        self.backgroundColor = UIColor.lightGray
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        
        self.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        tableView.isScrollEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.dropDownOptions = [(UIImage, String)]()
        super.init(coder: aDecoder)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
                
        cell.imageView?.image = dropDownOptions[indexPath.row].0
        cell.textLabel?.text = dropDownOptions[indexPath.row].1
        cell.textLabel?.textColor = UIColor.systemBlue
        cell.backgroundColor = UIColor.lightGray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let options: [ProjectType] = [.Gallery, .Photo, .Text]
        dDDelegate.dropDownItemPressed(selectedOption: options[indexPath.row])
    }
    
}
