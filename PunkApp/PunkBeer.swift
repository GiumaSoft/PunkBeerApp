//
//  PunkBeer.swift
//  PunkApp
//
//  Created by Giuseppe Mazzilli on 20/11/21.
//

import UIKit

struct PunkBeer: Codable {
    
    let id: Int
    let name: String
    let tagline: String?
    let firstBrewed: String?
    let description: String?
    let imageUrl: String?
    var imageData: Data? = nil
    let abv: Double
    let ibu: Double?
    let targetFg: Double?
    let targetOg: Double?
    let ebc: Double?
    let srm: Double?
    let ph: Double?
    let attenuationLevel: Double?
    let volume: UnitValue
    let boilVolume: UnitValue
    let method: Method
    let ingredients: Ingredients
    let foodPairing: [String]
    let brewersTips: String?
    let contributedBy: String?
    
    struct Ingredients: Codable {
        let malt: [Malt]
        let hops: [Hop]
        let yeast: String?
        
        struct Malt: Codable {
            let name: String
            let amount: UnitValue
        }
        
        struct Hop: Codable {
            let name: String
            let amount: UnitValue
            let add: String
            let attribute: String
        }
    }
    
    struct Method: Codable {
        let mashTemp: [Mash]
        let fermentation: Fermentation
        let twist: String?
        
        struct Mash: Codable {
            let temp: UnitValue
            let duration: Int?
        }
        
        struct Fermentation: Codable {
            let temp: UnitValue
        }
        
        enum CodingKeys: String, CodingKey {
            case fermentation, twist
            case mashTemp = "mash_temp"
        }
        
    }

    struct UnitValue: Codable {
        let value: Double?
        let unit: String
    }

    enum CodingKeys: String, CodingKey {
        case id, name, tagline, description, abv, ibu, ebc, srm, ph, volume, method, ingredients
        case imageUrl = "image_url"
        case targetFg = "target_fg"
        case targetOg = "target_og"
        case attenuationLevel = "attenuation_level"
        case boilVolume = "boil_volume"
        case firstBrewed = "first_brewed"
        case foodPairing = "food_pairing"
        case brewersTips = "brewers_tips"
        case contributedBy = "contributed_by"
    }
    
}

