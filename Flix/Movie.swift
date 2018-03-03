//
//  Movie.swift
//  Flix
//
//  Created by David Tan on 3/2/18.
//  Copyright © 2018 DavidTan. All rights reserved.
//

import Foundation
import AlamofireImage

class Movie {
    var title: String
    var posterUrl: URL?
    var backdropUrl: URL?
    var overview: String
    var releaseDate: String
    
    init(dictionary: [String: Any]) {
        title = dictionary["title"] as? String ?? "No Title"
        overview = dictionary["overview"] as? String ?? "No Overview"
        
        let baseUrlString = "https://image.tmdb.org/t/p/w500"
        
        let posterPathString = dictionary["poster_path"] as! String
        posterUrl = URL(string: baseUrlString + posterPathString)!
        
        let backdropPathString = dictionary["backdrop_path"] as! String
        backdropUrl = URL(string: baseUrlString + backdropPathString)!
        
        releaseDate = dictionary["release_date"] as? String ?? "No Release Date"
    }
    
    class func movies(dictionaries: [[String: Any]]) -> [Movie] {
        var movies: [Movie] = []
        for dictionary in dictionaries {
            let movie = Movie(dictionary: dictionary)
            movies.append(movie)
        }
        
        return movies
    }
}
