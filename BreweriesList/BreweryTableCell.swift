//
//  BreweryTableCell.swift
//  BreweriesList
//
//  Created by DimMac on 16.12.2023.
//

import Foundation
import UIKit

class BreweryTableCell: UITableViewCell {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var phoneLabelView: UIView!
    @IBOutlet weak var webLabelView: UIView!
    
    @IBOutlet var name: [UILabel]!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var webLink: UITextView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var countryLabelView: UIView!
    @IBOutlet weak var stateLabelView: UIView!
    @IBOutlet weak var cityLabelView: UIView!
    @IBOutlet weak var streetLabelView: UIView!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var street: UILabel!
    
    @IBOutlet weak var showOnMapButtonView: UIView!
    @IBOutlet weak var showOnMapButton: UIButton!
    
    let borderColor: CGColor = Constants.mainColor
    var brewery: Brewery?
    weak var delegate: ShowOnMap?
    
    func setup(brewery: Brewery){
        self.showOnMapButtonView.isHidden = true
        self.brewery = brewery
        self.name.forEach { label in
            label.text = brewery.name
        }
        
        self.phone.text = brewery.phone
        self.country.text = brewery.country
        self.state.text = brewery.state
        self.city.text = brewery.city
        self.street.text = brewery.street
        self.phoneLabelView.update(with: brewery.phone)
        self.webLabelView.update(with: brewery.websiteUrl)
        self.countryLabelView.update(with: brewery.country)
        self.stateLabelView.update(with: brewery.state)
        self.cityLabelView.update(with: brewery.city)
        self.streetLabelView.update(with: brewery.street)
        setupWebLink()
        setupContainersView()
        setupShowOnMapButton(brewery: brewery)
    }
    
    private func setupContainersView(){
        headerView.layer.cornerRadius = 12
        infoView.layer.cornerRadius = 12
        headerView.layer.borderWidth = 1
        infoView.layer.borderWidth = 1
        headerView.layer.borderColor = borderColor
        infoView.layer.borderColor = borderColor
    }
    
    private func setupWebLink() {
        guard let webLink = brewery?.websiteUrl else {return}
        self.webLink.textContainerInset = .zero
        let attributedString = NSMutableAttributedString(string: brewery?.websiteUrl ?? "")
        attributedString.addAttribute(.link, value: webLink, range: NSRange(webLink.startIndex..., in: webLink))
            
        self.webLink.attributedText = attributedString
    }
    
    private func setupShowOnMapButton(brewery: Brewery){
        guard let latitudeValue = brewery.latitude, let _ = Double(latitudeValue), let longtitudeValue = brewery.longtitude, let _ = Double(longtitudeValue) else {
            return
        }
        self.showOnMapButtonView.isHidden = false
        self.showOnMapButton.addTarget(self, action: #selector(showOnMapButtonTapped), for: .touchUpInside)
    }
    
    @objc func showOnMapButtonTapped() {
        guard let brewery = brewery else {
            return
        }
        delegate?.didSelect(breweryId: brewery.id)
    }
}

extension UIView {
    func update(with text: String?) {
        if let text = text, !text.isEmpty {
            self.isHidden = false
        } else {
            self.isHidden = true
        }
    }
}

extension BreweryTableCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
