//
//  MoviesViewController.swift
//  Flix
//
//  Created by David Tan on 2/4/18.
//  Copyright © 2018 DavidTan. All rights reserved.
//

import UIKit
import AlamofireImage

class MoviesViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate{

    var movies: [[String: Any]] = []
    var filteredMovies: [[String: Any]] = []
    
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var noResultsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide results label
        noResultsLabel.isHidden = true
        
        // Start loading activity
        activityIndicator.startAnimating()
        
        tableView.dataSource = self
        movieSearchBar.delegate = self
        
        // Add refresh when user pulls
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        fetchMovies()
        
        // End loading activity
        activityIndicator.stopAnimating()
    }
    
    // Refresh occured
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchMovies()
    }
    
    // Fetch now playing movies
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
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
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
                
                self.filteredMovies = self.movies
                
                // Reload your table view data
                self.tableView.reloadData()
                
                // Stop refreshing
                self.refreshControl.endRefreshing()
            }
        }
        task.resume()
    }
    
    // Number of cells in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return movies.count
        return filteredMovies.count
    }
    
    // Determine what cells look like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        //let movie = movies[indexPath.row]
        let movie = filteredMovies[indexPath.row]
        
        let posterPathString = movie["poster_path"] as! String
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        let posterURL = URL(string: baseURLString + posterPathString)!
        
        cell.titleLabel.text = (movie["title"] as! String)
        cell.overviewLabel.text = (movie["overview"] as! String)
        
        // Place holder image
        let placeholderImg = UIImage(named: "placeholder.png")
        
        cell.posterImageView.af_setImage(withURL: posterURL, placeholderImage: placeholderImg)
        
        return cell
    }
    
    // Update based on the text in the Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        filteredMovies = searchText.isEmpty ? movies : movies.filter{(movie: [String:Any]) -> Bool in
            return (movie["title"] as! String).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        if (filteredMovies.count == 0) {
            noResultsLabel.isHidden = false
        }
        else {
            noResultsLabel.isHidden = true
        }
        
        self.tableView.reloadData()
    }
    
    // Show cancel button on the Search Bar
    func searchBarTextDidBeginEditing(_ movieSearchBar: UISearchBar) {
        self.movieSearchBar.showsCancelButton = true
    }
    
    // Clear the Search Bar when canceling
    func searchBarCancelButtonClicked(_ movieSearchBar: UISearchBar) {
        movieSearchBar.showsCancelButton = false
        movieSearchBar.text = ""
        movieSearchBar.resignFirstResponder()
        
        filteredMovies = movies
        noResultsLabel.isHidden = true
        self.tableView.reloadData()
    }
    
    // Respond to user clicks on cells
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            let movie = movies[indexPath.row]
            let detailViewController = segue.destination as! DetailsViewController
            detailViewController.movie = movie
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
