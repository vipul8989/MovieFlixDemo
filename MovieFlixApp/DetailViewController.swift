//
//  DetailViewController.swift
//  MovieFlixApp
//
//  Created by iMac on 04/07/21.
//

import UIKit
import YouTubePlayer

class DetailViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet var playerView: YouTubePlayerView!
    @IBOutlet weak var ratingView: FloatRatingView!
    
    var movie: MovieModel?
    let trailerViewModel = TrailersViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchTrailers()
    }

    func setupUI() {
        
        ratingView.editable = false
        ratingView.type = .floatRatings
        self.title = "Details"

        guard let movie = movie else {
            return
        }
        
        self.title = movie.title
        lblTitle.text = movie.title
        lblDesc.text = movie.overview
        lblDate.text = "Release Date: \(movie.release_date ?? "")"
        trailerViewModel.id = movie.id ?? 0
        ratingView.rating = (movie.vote_average ?? 0.0) / 2.0
    }
    
    func fetchTrailers() {
        trailerViewModel.fetchData { [weak self] (status) in
            self?.loadVideo()
        }
    }
    
    func loadVideo() {
        
        guard trailerViewModel.arrTrailer.count > 0 else {
            return
        }
        
        playerView.playerVars = [
            "playsinline": "1",
            "controls": "0",
            "showinfo": "0"
            ] as YouTubePlayerView.YouTubePlayerParameters
        playerView.loadVideoID(trailerViewModel.arrTrailer.first!.key ?? "")
    }
}
