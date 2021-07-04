//
//  AlbumsViewModel.swift
//  AlbumApp
//
//  Created by iMac on 03/06/21.
//

import Foundation

class MoviesViewModel {
    
    var page: Int = 1
    var total_pages: Int = 2
    var total_results: Int = 1
    var arrMovie = [MovieModel]()
    var arrMovieFilter = [MovieModel]()
    var isApiCalling: Bool = false
    
    //MARK:- Fetch data from server
    func fetchData(completion: @escaping (_ status: Bool) -> Void) {
        
        isApiCalling = true
        
        let url = API_URL + "&" + "page=\(page)"
        print(url)
        
        ServiceManager.getRequest(url: url) { (dict, status) in
            
            self.isApiCalling = false
            
            // check for success
            if status {
                
                self.page = dict["page"] as? Int ?? 1
                self.total_pages = dict["total_pages"] as? Int ?? 1
                self.total_results = dict["total_results"] as? Int ?? 1
                
                if let arr = dict["results"] as? NSArray {
                    
                    print(arr.count)
                    do {
                        // JSON object to Data conversion
                        let data = try JSONSerialization.data(withJSONObject: arr, options: .prettyPrinted)
                        let result = try JSONDecoder().decode([MovieModel].self, from: data)
                        if self.page == 1 {
                            self.arrMovie = result
                        } else {
                            self.arrMovie.append(contentsOf: result)
                        }
                        self.page += 1
                        completion(true)
                    } catch {
                        print(error)
                        completion(false)
                    }
                } else {
                    self.page += 1
                    completion(false)
                }
            }
        }
    }
}
