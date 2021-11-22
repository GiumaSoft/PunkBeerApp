//
//  BeerTableViewCell.swift
//  PunkApp
//
//  Created by Giuseppe Mazzilli on 20/11/21.
//

import UIKit

class BeerTableViewCell: UITableViewCell {

    @IBOutlet weak var beerImage: UIImageView!
    @IBOutlet weak var beerName: UILabel!
    @IBOutlet weak var beerDescription: UILabel!
    @IBOutlet weak var beerAbv: UILabel!
    @IBOutlet weak var beerIbu: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }
    
    override func prepareForReuse() {
        beerImage.image = UIImage(named: "noImageAvailable")
        beerName.text = nil
        beerDescription.text = nil
        beerAbv.text = nil
        beerIbu.text = nil
    }

}
