//
//  CollectionViewCell.swift
//  Demo
//
//  Created by Akash on 09/04/21.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblYear: UIButton!
    
   
    var onReuse: () -> Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewShadow.backgroundColor = .clear
        viewShadow.layer.masksToBounds = false
        viewShadow.layer.shadowColor = UIColor.black.cgColor
        viewShadow.layer.shadowOpacity = 0.2
        viewShadow.layer.shadowRadius = 5
        viewShadow.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        viewShadow.layer.shouldRasterize = true
        viewShadow.layer.rasterizationScale = UIScreen.main.scale
        
        viewContainer.roundCornersWithRadius(radius: 20)
        imgView.roundCornersWithRadius(radius: 12)
        
        lblYear.roundCorners()
        
        lblYear.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        self.imgView.cancelImageLoad()
    }
        
    var songModel: SongList?{
        didSet{
            lblTitle.text = songModel?.title
            lblType.text = songModel?.type?.uppercased()
            lblYear.setTitle(songModel?.year, for: .normal)
            
            if let imgUrl = songModel?.poster,
               let url = URL(string: imgUrl){
                self.imgView.loadImage(at: url)
            }
        }
    }
}

