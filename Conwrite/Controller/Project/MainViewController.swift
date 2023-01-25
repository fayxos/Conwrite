//
//  MainViewController.swift
//  Handwritting
//
//  Created by Felix Haag on 04.08.21.
//

import UIKit

var selectedProject: Project?

class MainViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var projectCollectionView: UICollectionView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addProjectButton: UIBarButtonItem!
    @IBOutlet weak var topToolBar: UIToolbar!
    
    var dropDownIsOpen: Bool = false
    var dropDownHeight = NSLayoutConstraint()

    var projects: [Project] = Project.loadProjects()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        projectCollectionView.delegate = self
        projectCollectionView.dataSource = self
                
    }
    
        
    //MARK: - AddProject
    @IBAction func addProjectButtonTapped(_ sender: UIBarButtonItem) {
        let addProjectVC = storyboard?.instantiateViewController(identifier: "addProjectViewController") as! AddProjectViewController
        addProjectVC.projectDelegate = self
        present(addProjectVC, animated: true, completion: nil)
    }

}

//MARK: - Project Delegate Extension
extension MainViewController: projectDelegate {
    func updateProjectView(project: Project) {
        projects = Project.loadProjects()
        projectCollectionView.reloadData()
    }
}

//MARK: - CV Delegate Extension
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedProject = projects[indexPath.row]
        let addProjectVC = storyboard?.instantiateViewController(identifier: "addProjectViewController") as! AddProjectViewController
        addProjectVC.projectDelegate = self
        present(addProjectVC, animated: true, completion: nil)
    }
}

//MARK: - CV DataSource Extension
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = projectCollectionView.dequeueReusableCell(withReuseIdentifier: "projectCell", for: indexPath) as! ProjectCell
        
        // Image View Size: 230x230
        let image = UIImage(data: projects[indexPath.row].imageData!)
         
        cell.projectImageView.image = image
        cell.clipsToBounds = true
        cell.contentMode = .scaleAspectFit
        cell.projectImageView.clipsToBounds = true
        cell.projectImageView.contentMode = .scaleAspectFit
        
        cell.projectNameLabel.text = projects[indexPath.row].name
        
        return cell
    }
}
