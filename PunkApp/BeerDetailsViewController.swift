//
//  DetailsViewController.swift
//  PunkApp
//
//  Created by Giuseppe Mazzilli on 21/11/21.
//

import UIKit

class BeerDetailsViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var beerImage: UIImageView!
    @IBOutlet weak var firstBrewed: UILabel!
    @IBOutlet weak var pairingTips: UILabel!
    @IBOutlet weak var brewersTips: UILabel!
    
    var beer: PunkBeer?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = beer?.name
        // Do any additional setup after loading the view.
        setupContentView()
    }
    
    func setupContentView() {
        guard let beer = beer else { return }
        
        if let imageData = beer.imageData, let image = UIImage(data: imageData) {
            beerImage.image = image
        } else {
            beerImage.image = UIImage(named: "noImageAvailable")
        }
        
        firstBrewed.text = beer.firstBrewed
        pairingTips.text = beer.foodPairing.map { " ° \($0)" }.joined(separator: "\n")
        brewersTips.text = beer.brewersTips
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}

