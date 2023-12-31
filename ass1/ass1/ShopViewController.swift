//
//  ShopViewController.swift
//  ass1
//
//  Created by Inito on 05/08/23.
//

import UIKit
import Alamofire
import FirebaseFirestore
class ShopViewController: UIViewController{
    let db = Firestore.firestore()
    var products: [Products] = []
    var infos:[Info] = []
    
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ReusableCell", bundle: nil), forCellReuseIdentifier: "Reuse")
        
        APIHandler.sharedInstance.fetchingAPIData { result in
            switch result {
            case .success:
                print("Data fetched and saved successfully!")
                self.loadProducts { error in
                    if let error = error {
                        
                        print("There was an error loading products: \(error)")
                        }
                    else {
                        print("Data loaded successfully")
                        self.infos = []
                        self.numberOfRows()
                        print(self.infos.count)
                        DispatchQueue.main.async {
                            self.tableView.dataSource = self
                            self.tableView.reloadData()
                        }
                        
                        
                    }
                    }
            case .failure(let error):
                print("Error fetching and saving data: \(error)")
                
                }
            }
       
        
        
        }
        
    

    func loadProducts(completion: @escaping ( Error?) -> Void) {
        self.db.collection("products").getDocuments { querySnapshot, error in
            if let e = error {
                completion(e)
            } else {
               
                for document in querySnapshot?.documents ?? [] {
                    let data = document.data()
                    if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
                        do {
                            let product = try JSONDecoder().decode(Products.self, from: jsonData)
                            
                            self.products.append(product)
                        } catch {
                            print("Error decoding product: \(error)")
                        }
                    }
                }
                completion(nil)
            }
        }
    }

    func numberOfRows(){
        let product = products[0]
        for inf in product.clip{
            infos.append(inf)
        }
        for inf in product.monitorPro{
            infos.append(inf)
        }
        for inf in product.reflectiveStrip{
            infos.append(inf)
        }
        for inf in product.reflective_3T_strip{
            infos.append(inf)
        }
        for inf in product.replacementMonitor{
            infos.append(inf)
        }
        for inf in product.transmissiveStrip{
            infos.append(inf)
        }
        for inf in product.monitor{
            infos.append(inf)
        }
        print(infos[0])
    }
    

    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }.resume()
    }

        
}

extension ShopViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(infos.count)
        return infos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = infos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Reuse" , for: indexPath) as! ReusableCell
        cell.descriptionOfProduct.text = data.description
        cell.priceOfProduct.text = data.price
        cell.titleOfProduct.text = data.title
        let imageUrlString = data.image_url
                downloadImage(from: imageUrlString) { image in
                    if let image = image {
                        cell.imageOfProduct.image = image
                    } else {
                        // Handle the case where the image couldn't be downloaded or is invalid.
                        // For example, you can set a placeholder image or show an error message.
                        cell.imageOfProduct.image = UIImage(named: "placeholder_image")
                    }
                }
        
        
        return cell
    }


}



