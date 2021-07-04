//
//  ViewController.swift
//  MovieFlixApp
//
//  Created by iMac on 01/07/21.
//

import UIKit

class MovieFullCell: UICollectionViewCell {
    
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgThumbnail.layer.cornerRadius = 8.0
        imgThumbnail.clipsToBounds = true
        
        imgPlay.alpha = 0.8
        imgPlay.layer.shadowColor = UIColor.black.cgColor
        imgPlay.layer.shadowOffset = .zero
        imgPlay.layer.shadowRadius = 3.0
        imgPlay.layer.shadowOpacity = 0.6
        
        btnDelete.layer.shadowColor = UIColor.black.cgColor
        btnDelete.layer.shadowOffset = .zero
        btnDelete.layer.shadowRadius = 2.0
        btnDelete.layer.shadowOpacity = 0.6
    }
}

class MovieHalfCell: UICollectionViewCell {
    
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgThumbnail.layer.cornerRadius = 8.0
        imgThumbnail.clipsToBounds = true
        
        btnDelete.layer.shadowColor = UIColor.black.cgColor
        btnDelete.layer.shadowOffset = .zero
        btnDelete.layer.shadowRadius = 2.0
        btnDelete.layer.shadowOpacity = 0.6
    }
}

class ViewController: UIViewController {

    //MARK:- UI Components
    @IBOutlet weak var colMovies: UICollectionView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .white
        control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return control
    }()
    
    //MARK:- Variables
    let moviesViewModel = MoviesViewModel()
    let activityIndicator = UIActivityIndicatorView.init(style: .white)
    
    
    //MARK:- Life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchMovies()
    }

    func setupUI() {
        
        self.title = "Movies"
        
        viewSearch.layer.cornerRadius = 8.0
        viewSearch.clipsToBounds = true
        
        txtSearch.delegate = self
        txtSearch.addTarget(self, action: #selector(txtChanged(_:)), for: .editingChanged)
        
        colMovies.keyboardDismissMode = .onDrag
        colMovies.refreshControl = refreshControl

        let layout = colMovies.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = .zero
        
        colMovies.delegate = self
        colMovies.dataSource = self
    }
    
    @objc func txtChanged(_ textField: UITextField) {
        
        let str = textField.text ?? ""
        searchText(str: str)
    }
    
    func searchText(str: String) {
        
        if moviesViewModel.arrMovie.count == 0 {
            moviesViewModel.arrMovieFilter.removeAll()
            colMovies.reloadData()
            return
        }
        
        moviesViewModel.arrMovieFilter.removeAll()
        if str == "" {
            moviesViewModel.arrMovieFilter.append(contentsOf: moviesViewModel.arrMovie)
        } else {
            let arrFilter = moviesViewModel.arrMovie.filter { (movie) -> Bool in
                let name = movie.title ?? ""
                return name.localizedCaseInsensitiveContains(str)
            }
            moviesViewModel.arrMovieFilter.append(contentsOf: arrFilter)
        }
        colMovies.reloadData()
    }
    
    @objc func handleRefresh() {
        moviesViewModel.page = 1
        activityIndicator.startAnimating()
        colMovies.backgroundView = activityIndicator
        fetchMovies()
    }
    
    func fetchMovies() {
        
        guard !moviesViewModel.isApiCalling && moviesViewModel.page < moviesViewModel.total_pages else {
            return
        }
        
        moviesViewModel.fetchData { [weak self] (status) in
            self?.searchText(str: self?.txtSearch.text ?? "")
            self?.refreshControl.endRefreshing()
            self?.activityIndicator.stopAnimating()
            self?.colMovies.backgroundView = nil
        }
    }
    
    @objc func btnDeleteTapped(_ sender: UIButton) {
        
        var idx: IndexPath?
        if let cell = sender.superview?.superview?.superview as? MovieFullCell {
            idx = colMovies.indexPath(for: cell)
        } else if let cell = sender.superview?.superview?.superview as? MovieHalfCell {
            idx = colMovies.indexPath(for: cell)
        }
        
        if let idx = idx {
            colMovies.performBatchUpdates({ [weak self] in
                guard let self = self else { return }
                
                let id = self.moviesViewModel.arrMovieFilter[idx.item].id ?? 0
                self.moviesViewModel.arrMovieFilter.remove(at: idx.item)

                self.moviesViewModel.arrMovie.removeAll { (movie) -> Bool in
                    return (movie.id ?? 0) == id
                }
                
                let indexPath = IndexPath.init(item: idx.item, section: 0)
                self.colMovies.deleteItems(at: [indexPath])
            })
        }
        
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviesViewModel.arrMovieFilter.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let movie = moviesViewModel.arrMovieFilter[indexPath.item]
        let vote_average = movie.vote_average ?? 0.0
        
        if vote_average > 7.0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieFullCell", for: indexPath) as! MovieFullCell
            cell.imgThumbnail.loadImage(link: IMG_PATH_ORIGINAL + (movie.backdrop_path ?? ""), placeholder: "placeholderImage.png")
            
            cell.btnDelete.tag = indexPath.item
            cell.btnDelete.addTarget(self, action: #selector(btnDeleteTapped(_:)), for: .touchUpInside)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieHalfCell", for: indexPath) as! MovieHalfCell
            cell.lblTitle.text = movie.title
            cell.lblDesc.text = movie.overview
            cell.imgThumbnail.loadImage(link: IMG_PATH_342 + (movie.poster_path ?? ""), placeholder: "placeholderImage.png")
            
            cell.btnDelete.tag = indexPath.item
            cell.btnDelete.addTarget(self, action: #selector(btnDeleteTapped(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vcDetail = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vcDetail.movie = moviesViewModel.arrMovieFilter[indexPath.item]
        self.navigationController?.pushViewController(vcDetail, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let movie = moviesViewModel.arrMovieFilter[indexPath.item]
        let vote_average = movie.vote_average ?? 0.0
        
        if vote_average > 7.0 {
            return CGSize.init(width: WIDTH, height: WIDTH * 0.5)
        } else {
            return CGSize.init(width: WIDTH, height: WIDTH * 0.65)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.frame.height + scrollView.contentOffset.y) > scrollView.contentSize.height {
            fetchMovies()
        }
    }
}

