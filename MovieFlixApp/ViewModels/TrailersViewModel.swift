//
//  TrailersViewModel.swift
//  MovieFlixApp
//
//  Created by iMac on 04/07/21.
//

import Foundation


class TrailersViewModel {
    
    var id: Int = 1
    var arrTrailer = [TrailerModel]()
    
    //MARK:- Fetch data from server
    func fetchData(completion: @escaping (_ status: Bool) -> Void) {
        
        let url = TrailerUrl + "\(id)" + TrailerApi
        print(url)
        
        ServiceManager.getRequest(url: url) { (dict, status) in
            
            // check for success
            if status {
                
                if let arr = dict["results"] as? NSArray {
                    
                    print(arr)
                    do {
                        // JSON object to Data conversion
                        let data = try JSONSerialization.data(withJSONObject: arr, options: .prettyPrinted)
                        let result = try JSONDecoder().decode([TrailerModel].self, from: data)
                        self.arrTrailer = result
                        completion(true)
                    } catch {
                        print(error)
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
}
