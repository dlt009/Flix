//
//  PopularViewController.swift
//  Flix
//
//  Created by David Tan on 2/12/18.
//  Copyright © 2018 DavidTan. All rights reserved.
//

import UIKit

class PopularViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies: [[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        
        // Determine poster imageView layout for collection view
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        
        let cellsPerLine: CGFloat = 2
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = (collectionView.frame.size.width / cellsPerLine) - (interItemSpacingTotal / cellsPerLine)
        let height = width * 3/2
        layout.itemSize = CGSize(width: width, height: height)
        
        fetchMovies()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)->Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)-> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        let movie = movies[indexPath.item]
        if let posterPathString = movie["poster_path"] as? String {
            let baseURLString = "https://image.tmdb.org/t/p/w500"
            let posterURL = URL(string: baseURLString + posterPathString)!
            cell.posterImageView.af_setImage(withURL: posterURL)
            
        }
        return cell
    }
    
    // Fetch movies
    func fetchMovies() {
        
        // Create alert for internet connection failure
        let alertController = UIAlertController(title: "Cannot Get Movies", message: "The internet connection appears to be offline.", preferredStyle: .alert)
        
        // Create an OK action
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // Handle response here.
        }
        // Add the OK action to the alert controller
        alertController.addAction(OKAction)
        
        
        // Network handling
        let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
                
                // Show alert if we cannot load movies
                self.present(alertController, animated: true) {
                    // optional code for what happens after the alert controller has finished presenting
                    
                }
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                // Get the array of movies
                let movies = dataDictionary["results"] as! [[String:Any]]
                
                // Store the movies in a property to use elsewhere
                self.movies = movies
                
                // Reload your collection view data
                self.collectionView.reloadData()
                
                // Stop refreshing
                //self.refreshControl.endRefreshing()
            }
        }
        task.resume()
    }
    
    // Respond to user clicks on cells
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell) {
            let movie = movies[indexPath.row]
            let detailViewController = segue.destination as! DetailsViewController
            detailViewController.movie = movie
        }
    }
    
}
