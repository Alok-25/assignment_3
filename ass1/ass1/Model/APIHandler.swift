//
//  APIHandeler.swift
//  ass1
//
//  Created by Inito on 05/08/23.
//

import Foundation
import Alamofire
import FirebaseFirestore
import CoreData
import RealmSwift
struct APIHandler {
    static let sharedInstance = APIHandler()
    let db = Firestore.firestore()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let realm = try! Realm()
    
    
    func fetchingAPIData(completion: @escaping (Result<Void, Error>) -> Void) {
            let url = "https://www.inito.com/products/list"
            let request = AF.request(url)

        request.responseDecodable(of: Model.self) { response in
                switch response.result {
                case .success(let data):
                    if FirstViewController.storeInFirestore {
                        
                        let monitorDict = data.products.monitor.map { $0.dictionaryRepresentation() }
                        let monitorProDict = data.products.monitorPro.map { $0.dictionaryRepresentation() }
                        let replacementMonitorDict = data.products.replacementMonitor.map { $0.dictionaryRepresentation() }
                        let transmissiveStripDict = data.products.transmissiveStrip.map { $0.dictionaryRepresentation() }
                        let reflectiveStripDict = data.products.reflectiveStrip.map { $0.dictionaryRepresentation() }
                        let reflective_3T_stripDict = data.products.reflective_3T_strip.map { $0.dictionaryRepresentation() }
                        let clipDict = data.products.clip.map { $0.dictionaryRepresentation() }

                        
                        var productsDict: [String: Any] = [:]
                        productsDict["monitor"] = monitorDict
                        productsDict["monitor-pro"] = monitorProDict
                        productsDict["replacement-monitor"] = replacementMonitorDict
                        productsDict["transmissive-strip"] = transmissiveStripDict
                        productsDict["reflective-strip"] = reflectiveStripDict
                        productsDict["reflective_3T_strip"] = reflective_3T_stripDict
                        productsDict["clip"] = clipDict

                        
                        self.db.collection("products").addDocument(data: productsDict) { error in
                            if let error = error {
                                
                                completion(.failure(error))
                            } else {
                                
                                completion(.success(()))
                            }
                        }
                    }
                    else{
                        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CoreInfo")
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        
                        do {
                            try context.execute(deleteRequest)
                            try context.save()
                            print("Existing objects deleted from Core Data")
                        } catch {
                            print("Error deleting existing objects: \(error)")
                        }
                        do {
                            try realm.write {
                                realm.deleteAll()
                                print("Existing data deleted from Realm")
                            }
                        } catch {
                            print("Error deleting existing data from Realm: \(error)")
                        }
                        for category in [data.products.clip, data.products.monitor, data.products.monitorPro, data.products.reflectiveStrip, data.products.reflective_3T_strip, data.products.replacementMonitor, data.products.transmissiveStrip] {
                            for ele in category {
                                
                                // Create new item if not found
                                let newItem = CoreInfo(context: context)
                                newItem.product_id = ele.product_id
                                newItem.price = ele.price
                                newItem.disc = ele.disc
                                newItem.image_url = ele.image_url
                               
                                    let newInfo = RealmInfo()
                                    newInfo.button_text = ele.button_text
                                    newInfo.checkout_url = ele.checkout_url
                                    newInfo.product_id = ele.product_id
                                    newInfo.title = ele.title
                                    do{
                                        try context.save()
                                        try realm.write {
                                            realm.add(newInfo)
                                        }
                                    }catch{
                                        print("Error saving/updating context: \(error)")
                                        
                                    }
                                    
                                }
                                
                            
                            
                        }
                        completion(.success(()))
                    }
   
                case .failure(let error):
                    print("Faillllllled")
                    completion(.failure(error))
                }
            }
        }
    }





struct Model: Decodable{
    var products: Products
    
}
struct Products: Decodable {
    enum CodingKeys: String, CodingKey {
       case monitor
       case monitorPro = "monitor-pro"
       case replacementMonitor = "replacement-monitor"
       case transmissiveStrip = "transmissive-strip"
       case reflectiveStrip = "reflective-strip"
       case reflective_3T_strip = "reflective_3T_strip"
       case clip
     }

    var monitor: [Info]
    var monitorPro: [Info]
    var replacementMonitor: [Info]
    var transmissiveStrip: [Info]
    var reflectiveStrip: [Info]
    var reflective_3T_strip: [Info]
    var clip: [Info]
}

struct Info :Decodable{
    var image_url:String
    var price: String
    var title: String
    var disc: String
    var checkout_url: String
    var product_id: String
    var button_text: String
    
    enum CodingKeys: String, CodingKey {
       case image_url
       case price
       case title
       case disc = "description"
       case checkout_url = "checkout_url"
       case product_id
       case button_text
       
     }

}
extension Info {
    func dictionaryRepresentation() -> [String: Any] {
        return [
            "image_url": image_url,
            "price": price,
            "title": title,
            "description": disc,
            "checkout_url": checkout_url,
            "product_id": product_id,
            "button_text": button_text
        ]
    }
}
