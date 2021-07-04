//
//  ServiceManager.swift
//  AlbumApp
//
//  Created by iMac on 03/06/21.
//

import Foundation

//MARK:- ServiceManager
class ServiceManager: NSObject {
    
    class func getRequest(url:String, completion: @escaping (_ result: NSDictionary, _ status: Bool) -> Void) {
        
        guard let apiUrl = URL(string: url) else {
            completion(["error": "Invalid url"], false)
            return
        }
        
        // Request
        let task = URLSession.shared.dataTask(with: apiUrl) {(data, response, error) in
            
            DispatchQueue.main.async {
                
                guard let data = data else { return }
                
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        
                        completion(jsonResult, true)
                    }
                } catch let error as NSError {
                    
                    print(error.localizedDescription)
                    completion(["error": error.localizedDescription, "data": ""], false)
                }
            }
        }
        task.resume()
    }
}
