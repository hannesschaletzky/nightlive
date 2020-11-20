//
//  ClubCell.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 03/04/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import UIKit

class ClubCell: FoldingCell {
    
    var club = Club(nightlive_display_name: "...")
    
    //Outer Cell
    @IBOutlet weak var outer_clubNameLabel: UILabel!
    @IBOutlet weak var outer_openImgView: UIImageView!
    @IBOutlet weak var outer_happyHourLabel: UILabel!
    @IBOutlet weak var outer_FavoriteButton: DOFavoriteButton!
    
    //INNER
    @IBOutlet weak var inner_RotatedViewFirst: RotatedView!
    @IBOutlet weak var inner_clubNameLabel: UILabel!
    @IBOutlet weak var inner_openImgView: UIImageView!
    @IBOutlet weak var inner_happyHourLabel: UILabel!
    @IBOutlet weak var inner_FavoriteButton: DOFavoriteButton!
    
    //Address, Phone, Website
    @IBOutlet weak var inner_addressTextView: UITextView!
    @IBOutlet weak var inner_telephoneTextView: UITextView!
    @IBOutlet weak var inner_websiteTextView: UITextView!
    
    //Decsription
    @IBOutlet weak var inner_descriptionView: UIView!
    @IBOutlet weak var inner_descriptionTextView: UITextView!
    
    //Next Events
    @IBOutlet weak var inner_nextEventsTextView: UITextView!
    @IBOutlet weak var inner_nextEventsActivityIndicator: UIActivityIndicatorView!
    
    //Opening Hours
    @IBOutlet weak var inner_openinghoursMondayLabel: UILabel!
    @IBOutlet weak var inner_openinghoursTuesdayLabel: UILabel!
    @IBOutlet weak var inner_openinghoursWednesdayLabel: UILabel!
    @IBOutlet weak var inner_openinghoursThursdayLabel: UILabel!
    @IBOutlet weak var inner_openinghoursFridayLabel: UILabel!
    @IBOutlet weak var inner_openinghoursSaturdayLabel: UILabel!
    @IBOutlet weak var inner_openinghoursSundayLabel: UILabel!
    
    @IBOutlet weak var inner_openingHoursMondayDayLabel: UILabel!
    @IBOutlet weak var inner_openingHoursTuesdayDayLabel: UILabel!
    @IBOutlet weak var inner_openingHoursWednesdayDayLabel: UILabel!
    @IBOutlet weak var inner_openingHoursThursdayDayLabel: UILabel!
    @IBOutlet weak var inner_openingHoursFridayDayLabel: UILabel!
    @IBOutlet weak var inner_openingHoursSaturdayDayLabel: UILabel!
    @IBOutlet weak var inner_openingHoursSundayDayLabel: UILabel!
    
    @IBOutlet weak var noOpeningHoursProvidedLabel: UILabel!
    
    //Happy Hours
    @IBOutlet weak var inner_happyHourMondayDayLabel: UILabel!
    @IBOutlet weak var inner_happyHourTuesdayDayLabel: UILabel!
    @IBOutlet weak var inner_happyHourWednesdayDayLabel: UILabel!
    @IBOutlet weak var inner_happyHourThursdayDayLabel: UILabel!
    @IBOutlet weak var inner_happyHourFridayDayLabel: UILabel!
    @IBOutlet weak var inner_happyHourSaturdayDayLabel: UILabel!
    @IBOutlet weak var inner_happyHourSundayDayLabel: UILabel!
    
    @IBOutlet weak var inner_happyHourMondayLabel: UILabel!
    @IBOutlet weak var inner_happyHourTuesdayLabel: UILabel!
    @IBOutlet weak var inner_happyHourWednesdayLabel: UILabel!
    @IBOutlet weak var inner_happyHourThursdayLabel: UILabel!
    @IBOutlet weak var inner_happyHourFridayLabel: UILabel!
    @IBOutlet weak var inner_happyHourSaturdayLabel: UILabel!
    @IBOutlet weak var inner_happyHourSundayLabel: UILabel!
    
    @IBOutlet weak var noHappyHoursProvidedLabel: UILabel!
    
    @IBOutlet weak var inner_closeButton: UIButton!
    
    //
    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2]
        return durations[itemIndex]
    }
    
}
