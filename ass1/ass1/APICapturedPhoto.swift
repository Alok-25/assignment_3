//
//  APICapturedPhoto.swift
//  ass1
//
//  Created by Inito on 19/08/23.
//

import Foundation
import Alamofire
struct AuthResponse: Codable {
    var id: Int?
}
struct NeededResponse{
    var accessToken: String = ""
    var uid: String = ""
    var client: String = ""
}



class APICapturedPhoto{
    
    var authResponse = NeededResponse()
    let headers: HTTPHeaders = [
        "Content-Type": "application/json"
    ]
    
    let parameters: Parameters = [
        "truevault_id": "5f69b581-00d1-4378-b353-b20fd9a71c35",
        "truevault_access_token": "v2.000f6984ea614ef3868c74b4ffa9d8f9.30b1e5ec943ab18fb3eb5fb5a405c32cd8c5e2ee4827781a5c311a6b976ec75f"
    ]
    
    
//    func postMethod()  {
//
//        let url = "http://apistaging.inito.com/api/v2/auth/sign_in/"
//
//
//        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//            .validate(statusCode: 200..<300)
//            .responseDecodable(of: AuthResponse.self) { response in
//                switch response.result {
//                case .success(let _):
//
//                    let accessToken = response.response?.allHeaderFields["access-token"] as? String
//                    let uid = response.response?.allHeaderFields["uid"] as? String
//                    let client = response.response?.allHeaderFields["client"] as? String
//
//
//
//                    self.authResponse.accessToken = accessToken!
//                    self.authResponse.uid = uid!
//                    self.authResponse.client = client!
//
//                    print("Authentication response:", self.authResponse)
//
//                case .failure(let error):
//
//                    print("Error:", error)
//                }
//            }
//
//    }
    
    func postMethod(completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let url = "http://apistaging.inito.com/api/v2/auth/sign_in/"
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: AuthResponse.self) { response in
                switch response.result {
                case .success(let authResponse):
                    let accessToken = response.response?.allHeaderFields["access-token"] as? String
                    let uid = response.response?.allHeaderFields["uid"] as? String
                    let client = response.response?.allHeaderFields["client"] as? String
                    
                    self.authResponse.accessToken = accessToken!
                    self.authResponse.uid = uid!
                    self.authResponse.client = client!
                    
                    print("Authentication response:", self.authResponse)
                    completion(.success(authResponse))
                    
                case .failure(let error):
                    print("Error:", error)
                    completion(.failure(error))
                }
            }
    }

    
    func postImage(_ image: UIImage, completion: @escaping (Result<String,Error>) -> Void)  {
        let url = "http://apistaging.inito.com/api/v1/tests"
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "access-token": authResponse.accessToken,
            "uid": authResponse.uid,
            "client": authResponse.client
            
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: Date())
        print("YO")
        

           AF.upload(multipartFormData: { multipartFormData in
               if let imageData = image.jpegData(compressionQuality: 0.8) {
                   multipartFormData.append(imageData, withName: "test[images_attributes][][pic]", fileName: "image.jpg", mimeType: "image/jpeg")
                   
                   let doneDateData = "Test[done_date]:\(currentDateString)".data(using: .utf8)
                          multipartFormData.append(doneDateData!, withName: "Test[done_date]")
                   let batchQrCodeData = "XAN".data(using: .utf8)
                   multipartFormData.append(batchQrCodeData!, withName: "test[batch_qr_code]")
                   
               }
           }, to: url,method: .post,headers: headers).response { response in
               switch response.result {
               case .success(let data):
                   if let jsonData = data {
                       completion(.success("Done"))
                      print("Test Done!!")
                   }
               case .failure(let error):
                   completion(.failure(error))
                  print(error)
               }
           }
    }
}
