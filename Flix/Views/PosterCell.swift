//
//  PosterCell.swift
//  Flix
//
//  Created by David Tan on 2/11/18.
//  Copyright © 2018 DavidTan. All rights reserved.
//

import UIKit

class PosterCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    var movie: Movie! {
        didSet {
            if let posterUrl = movie.posterUrl {
                posterImageView.af_setImage(withURL: posterUrl)
            }
        }
    }
    
    
}
