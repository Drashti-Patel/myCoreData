//
//  DetailViewController.swift
//  myCoreData
//
//  Created by Drashti Jaykumar Jasani on 24.11.2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var artImage: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            request.returnsObjectsAsFaults = false
            
            let chosenUUID = chosenPaintingId?.uuidString
            request.predicate = NSPredicate(format: "id = %@", chosenUUID!)
            
            do {
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            artImage.image = UIImage(data: imageData)
                        }
                    }
                }
            }catch {
                print("")
            }
            
            
        }else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }

        artImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        artImage.addGestureRecognizer(tapGesture)
    }
    
    @objc func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        artImage.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSaveClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let painting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
       
        painting.setValue(nameText.text!, forKey: "name")
        painting.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!) {
            painting.setValue(year, forKey: "year")
        }
        painting.setValue(UUID(), forKey: "id")
        
        let imageData = artImage.image?.jpegData(compressionQuality: 0.5)
            painting.setValue(imageData, forKey: "image")
        
        do {
            try context.save()
        }catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: Notification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }

}
