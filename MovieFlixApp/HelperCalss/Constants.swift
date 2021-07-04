//
//  Constants.swift
//  AlbumApp
//
//  Created by iMac on 03/06/21.
//

import UIKit
import Foundation

// Screen sizes
let WIDTH = UIScreen.main.bounds.width
let HEIGHT = UIScreen.main.bounds.height

// End point
let API_URL = "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"

let TrailerUrl = "https://api.themoviedb.org/3/movie/"
let TrailerApi = "/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"

let IMG_PATH_342 = "https://image.tmdb.org/t/p/w342"
let IMG_PATH_ORIGINAL = "https://image.tmdb.org/t/p/original"

// for image caches
let imageCache = NSCache<NSString, UIImage>()

