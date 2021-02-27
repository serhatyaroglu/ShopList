//
//  ViewController.swift
//  ShopList
//
//  Created by serhat yaroglu on 20.01.2021.
//
import UIKit
import CoreData
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    var secilenIsim = ""
    var secilenUUID : UUID?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(eklemeButonTiklandi))
        
        verileriAl()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name(rawValue: "veri girildi"), object: nil)
    }
  @objc  func verileriAl(){
    isimDizisi.removeAll(keepingCapacity: false)
    idDizisi.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
        fetchRequest.returnsObjectsAsFaults = false
        do {
             let sonuclar = try context.fetch(fetchRequest)
            if sonuclar.count > 0 {
                for sonuc in   sonuclar as! [NSManagedObject]{
                   if let name = sonuc.value(forKey: "name") as? String
                    {
                        isimDizisi.append(name)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idDizisi.append(id)
                    }
            }
                tableView.reloadData()
        }
            
            
            
        }catch{
            print("hata var")
        }
        
        
    }
    @objc func eklemeButonTiklandi(){
        secilenIsim = ""
        performSegue(withIdentifier: "ToDetailVC", sender: nil)
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDetailVC"
        {
            let destinationVc = segue.destination as! DetailsViewController
            destinationVc.secilenUrunIsmi = secilenIsim
            destinationVc.secilenUrunUUID = secilenUUID
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenIsim = isimDizisi[indexPath.row]
        secilenUUID = idDizisi[indexPath.row]
        
        performSegue(withIdentifier: "ToDetailVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
            let uuidString = idDizisi[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let sonuclar = try context.fetch(fetchRequest)
                if sonuclar.count > 0 {
                    for sonuc in sonuclar as! [NSManagedObject]
                    {
                        if let id = sonuc.value(forKey: "id") as? UUID {
                            if  id == idDizisi[indexPath.row] {
                                context.delete(sonuc)
                                isimDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do{
                                   try context.save()
                                }catch{}
                                break
                            }
                        }
                    }
                    
                }
            }
            catch{
                
            }
        }
    }

}

