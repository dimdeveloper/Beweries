//
//  BreweryModel.swift
//  BreweriesList
//
//  Created by DimMac on 15.12.2023.
//

import Foundation

struct Brewery: Codable {
    let id: String
    let name: String
    let breweryType: String?
    let addres1: String?
    let addres2: String?
    let addres3: String?
    let city: String?
    let stateProvince: String?
    let postalCode: String?
    let country: String?
    let longtitude: String?
    let latitude: String?
    let phone: String?
    let websiteUrl: String?
    let  state: String?
    let street: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case breweryType = "brewery_type"
        case addres1 = "address_1"
        case addres2 = "address_2"
        case addres3 = "address_3"
        case city
        case stateProvince = "state_province"
        case postalCode = "postal_code"
        case country
        case longtitude = "longitude"
        case latitude
        case phone
        case websiteUrl = "website_url"
        case state
        case street
    }
}
