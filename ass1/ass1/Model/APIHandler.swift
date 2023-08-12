//
//  APIHandeler.swift
//  ass1
//
//  Created by Inito on 05/08/23.
//

import Foundation
import Alamofire
import FirebaseFirestore

struct APIHandler {
    static let sharedInstance = APIHandler()
    let db = Firestore.firestore()
    
    func fetchingAPIData(completion: @escaping (Result<Void, Error>) -> Void) {
            let url = "https://www.inito.com/products/list"
            let request = AF.request(url)

            request.responseDecodable(of: Model.self) { response in
                switch response.result {
                case .success(let data):
                    
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
                case .failure(let error):
                    
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
    var description: String
    var checkout_url: String
}
extension Info {
    func dictionaryRepresentation() -> [String: Any] {
        return [
            "image_url": image_url,
            "price": price,
            "title": title,
            "description": description,
            "checkout_url": checkout_url
        ]
    }
}
