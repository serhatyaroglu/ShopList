//
//  DetailsViewController.swift
//  ShopList
//
//  Created by serhat yaroglu on 20.01.2021.
//

import UIKit
import CoreData
class DetailsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var kaydetbutton: UIButton!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var PriceTextField: UITextField!
    
    @IBOutlet weak var BedenTextField: UITextField!
    var secilenUrunIsmi = ""
    var secilenUrunUUID : UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if secilenUrunIsmi != "" {
            kaydetbutton.isHidden = true
            // core data secilen urun bilgilerini goster
            
            if   let uuidString = secilenUrunUUID?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject]{
                            if let name = sonuc.value(forKey: "name") as? String{
                                NameTextField.text = name
                            }
                            if let price = sonuc.value(forKey: "price") as? Int{
                                PriceTextField.text = String(price)
                            }
                            if let beden = sonuc.value(forKey: "beden") as? String{
                                BedenTextField.text = beden
                            }
                            if let imagesData = sonuc.value(forKey: "images") as? Data{
                                let image = UIImage(data: imagesData)
                                imageView.image = image
                            }
                            
                        }
                    }
                }catch{
                    
                    print("hata var ")
                
                }
            }
            
        }else{
            kaydetbutton.isHidden = false
            kaydetbutton.isEnabled = false
            NameTextField.text = ""
            BedenTextField.text = ""
            PriceTextField.text = ""
        }
        
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeKapat))
        view.addGestureRecognizer(gestureRecognizer)
        imageView.isUserInteractionEnabled = true
        let imageGEstureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(imageGEstureRecognizer)
        
    }
    @objc func gorselSec(){
        let picker = UIImagePickerController()
            picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        kaydetbutton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    @objc func klavyeKapat(){
        view.endEditing(true)
    }
    @IBAction func SaveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        shopping.setValue(NameTextField.text, forKey: "name")
        shopping.setValue(BedenTextField.text, forKey: "beden")
        if let price = Int(PriceTextField.text!){
            shopping.setValue(price, forKey: "price")
        }
        shopping.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        shopping.setValue(data, forKey: "images")
        do{
            try context.save()
            print("kayit edildi")
            
        }
        catch{
            print("hata")
            
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veri girildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
   
}
