//
//  ImageDownloader.swift
//  ass1
//
//  Created by Inito on 22/08/23.
//

import Foundation
import Alamofire
class ImageDownloader{
    let imageURLArray = ["https://dqxth8lmt6m4r.cloudfront.net/assets/v1/reflective_monitor-5d3640f9e6550d48f3d12fb58af880b38a9d1345b35e7d2a1718386850af70d5.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/reflective_monitor-5d3640f9e6550d48f3d12fb58af880b38a9d1345b35e7d2a1718386850af70d5.png","https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_10_no_discount-c5ebe5488dffb7c5bf468093116f2c0224c4de191c364c029f8367cbdffd5538.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_10_no_discount-c5ebe5488dffb7c5bf468093116f2c0224c4de191c364c029f8367cbdffd5538.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_15_with_discount-20c3b131f10b2eac07c5bb16467a5da692d076869e46c83e8c1d01069218c689.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_25_with_discount-d66f0b9ad958a6135e8afb77c1a4f6e1123344180f324f346e713f383538ecc5.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_10_no_discount-c5ebe5488dffb7c5bf468093116f2c0224c4de191c364c029f8367cbdffd5538.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_15_with_discount-20c3b131f10b2eac07c5bb16467a5da692d076869e46c83e8c1d01069218c689.png", "https://dqxth8lmt6m4r.cloudfront.net/assets/v1/fertility_strips_pack_of_25_with_discount-d66f0b9ad958a6135e8afb77c1a4f6e1123344180f324f346e713f383538ecc5.png"
      ]
    var imageArray = [UIImage]()

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
            
            
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                    print("Downlaod image failed")
                }
            
        }.resume()
    }
    
    func downloadAllImages(_ index: Int, completion: @escaping (Result<Void, Error>) -> Void){
        for i in index..<(2*index){
            let imageUrlString = imageURLArray[i]
            downloadImage(from: imageUrlString) { image in
                if let image = image {
                   
                    self.imageArray.append(image)
                } else {
                   
                    completion(.failure(Error.self as! Error))
                    
                }
            }

        }
        print ("Number of images Downloaded \(index)")
        print("_______________________")
        completion(.success(()))
    }


    
}
