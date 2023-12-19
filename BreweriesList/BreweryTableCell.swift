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
    let borderColor: CGColor = Constants.mainColor
    
    func setup(brewery: Brewery){
        setupView()
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
        
        self.webLink.textContainerInset = .zero

        guard let webLink = brewery.websiteUrl else {return}
        let attributedString = NSMutableAttributedString(string: brewery.websiteUrl ?? "")
        attributedString.addAttribute(.link, value: webLink, range: NSRange(webLink.startIndex..., in: webLink))
            
        self.webLink.attributedText = attributedString
    }
    
    private func setupView(){
        
        headerView.layer.cornerRadius = 12
        infoView.layer.cornerRadius = 12
        headerView.layer.borderWidth = 1
        infoView.layer.borderWidth = 1
        headerView.layer.borderColor = borderColor
        infoView.layer.borderColor = borderColor
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
