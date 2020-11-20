//
//  Location.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 28/03/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import Foundation

fileprivate let weekdayNumberStringDict = [2:"mon",3:"tue",4:"wed",5:"thu",6:"fri",7:"sat",1:"sun"]

class Location {
    
    var nightlive_display_name: String //stored property -- mandatory
    
    var nightlive_facebookID: String?
    var nightlive_googlePlacesID: String?
    var nightlive_detailed_description: String?
    var nightlive_visible: Bool?
    var nightlive_happyHours_provided = false
    var nightlive_happyHours: [String]?
    
    
    var google_name: String?
    var google_formattedAddress: String?
    var google_vicinity: String?
    var google_formattedphoneNumber: String?
    var google_international_phone_number: String?
    var google_google_url: String?
    var google_website: String?
    var google_photos: [Any]?
    var google_price_level: Int?
    var google_rating: Double?
    var google_reviews: [Any]?
    
    //Set via function
    var google_address_street: String?
    var google_address_number: String?
    var google_address_zip: String?
    var google_address_city: String?
    var google_address_country: String?
    
    //Set via function
    var google_location_lng: Double?
    var google_location_lat: Double?
    
    //Set via function
    var google_openingHours_provided = false
    var google_open_now: Bool?
    var google_open_sun: String?
    var google_close_sun: String?
    var google_open_mon: String?
    var google_close_mon: String?
    var google_open_tue: String?
    var google_close_tue: String?
    var google_open_wed: String?
    var google_close_wed: String?
    var google_open_thu: String?
    var google_close_thu: String?
    var google_open_fri: String?
    var google_close_fri: String?
    var google_open_sat: String?
    var google_close_sat: String?
    
    
    //Initializer
    init(nightlive_display_name:String) {
        self.nightlive_display_name = nightlive_display_name
    }
    
    
    //MARK: - Setter
    //Parse data from google and set variables
    func google_setOpeningHours(data:[String:Any]) {
        if let openNow = data["open_now"] as? Bool {
            self.google_open_now = openNow
        }
        //Times
        if let periods = data["periods"] as? [[String:Any]] {
            for array in periods {
                if let open = array["open"] as? [String:Any] {
                    let day = open["day"] as! Int
                    let hours = open["time"] as! String
                    setOpeningHoursForDayAndHour(day: day, hours: hours, isOpening: true)
                }
                if let close = array["close"] as? [String:Any] {
                    let day = close["day"] as! Int
                    let hours = close["time"] as! String
                    setOpeningHoursForDayAndHour(day: day, hours: hours, isOpening: false)
                }
            }
            
        }
        
        
    }
    
    private func setOpeningHoursForDayAndHour(day: Int, hours: String, isOpening: Bool) {
        switch day {
        case 0:
            //Sunday
            if isOpening {
                self.google_open_sun = hours
            }
            else {
                self.google_close_sun = hours
            }
            break
            
        case 1:
            //Monday
            if isOpening {
                self.google_open_mon = hours
            }
            else {
                self.google_close_mon = hours
            }
            break
            
        case 2:
            if isOpening {
                self.google_open_tue = hours
            }
            else {
                self.google_close_tue = hours
            }
            break
            
        case 3:
            if isOpening {
                self.google_open_wed = hours
            }
            else {
                self.google_close_wed = hours
            }
            break
            
        case 4:
            if isOpening {
                self.google_open_thu = hours
            }
            else {
                self.google_close_thu = hours
            }
            break
            
        case 5:
            if isOpening {
                self.google_open_fri = hours
            }
            else {
                self.google_close_fri = hours
            }
            break
            
        case 6:
            if isOpening {
                self.google_open_sat = hours
            }
            else {
                self.google_close_sat = hours
            }
            break
            
        default:
            //no default amk
            break
        }
    }
    
    
    func google_setLongituteAndLatitude(data: [String:Any]) {
        if let location = data["location"] as? [String:Any] {
            if let lat = location["lat"] as? Double {
                self.google_location_lat = lat
            }
            if let lng = location["lng"] as? Double {
                self.google_location_lng = lng
            }
        }
    }
    
    func google_setAddressComponents(data: [[String:Any]]) {
        
        for component in data {
            if let types = component["types"] as? [String] {
                for type in types {
                    if type == "street_number" {
                        self.google_address_number = component["long_name"] as? String
                    }
                    if type == "route" {
                        self.google_address_street = component["long_name"] as? String
                    }
                    if type == "locality" {
                        self.google_address_city = component["long_name"] as? String
                    }
                    if type == "country" {
                        self.google_address_country = component["long_name"] as? String
                    }
                    if type == "postal_code" {
                        self.google_address_zip = component["long_name"] as? String
                    }
                }
            }
            
        }
        
    }
    
    
    //Parse data from nightlive and set variables
    func nightlive_setOpeningHours() {
        
    }
    
    //MARK: - Getter
    func getOpeningHourStringForWeekday(weekday: Int) -> String {
        var oh_string = "00:00 - 00:00"
        
        switch weekday {
            
        case 2: //MONDAY
            if let open = self.google_open_mon {
                if let closeSameDay = self.google_close_mon {
                    if let closeNextDay = self.google_close_tue {
                        let result = compareOpeningHours(openSameDay: open, closeSameDay: closeSameDay, closeNextDay: closeNextDay)
                        oh_string = result
                    }
                }
                else {
                    //no closing for same day provided, so next day default
                    if let closeNextDay = self.google_close_tue {
                        oh_string = "\(open) - \(closeNextDay)"
                    }
                }
                
                
            }
            
            break
            
        case 3:
            if let open = self.google_open_tue {
                if let closeSameDay = self.google_close_tue {
                    if let closeNextDay = self.google_close_wed {
                        let result = compareOpeningHours(openSameDay: open, closeSameDay: closeSameDay, closeNextDay: closeNextDay)
                        oh_string = result
                    }
                }
                else {
                    //no closing for same day provided, so next day default
                    if let closeNextDay = self.google_close_wed {
                        oh_string = "\(open) - \(closeNextDay)"
                    }
                }
            }
            
            break
            
        case 4:
            if let open = self.google_open_wed {
                if let closeSameDay = self.google_close_wed {
                    if let closeNextDay = self.google_close_thu {
                        let result = compareOpeningHours(openSameDay: open, closeSameDay: closeSameDay, closeNextDay: closeNextDay)
                        oh_string = result
                    }
                }
                else {
                    //no closing for same day provided, so next day default
                    if let closeNextDay = self.google_close_thu {
                        oh_string = "\(open) - \(closeNextDay)"
                    }
                }
            }
            
            break
            
        case 5:
            if let open = self.google_open_thu {
                if let closeSameDay = self.google_close_thu {
                    if let closeNextDay = self.google_close_fri {
                        let result = compareOpeningHours(openSameDay: open, closeSameDay: closeSameDay, closeNextDay: closeNextDay)
                        oh_string = result
                    }
                }
                else {
                    //no closing for same day provided, so next day default
                    if let closeNextDay = self.google_close_fri {
                        oh_string = "\(open) - \(closeNextDay)"
                    }
                }
            }
            
            break
            
        case 6:
            if let open = self.google_open_fri {
                if let closeSameDay = self.google_close_fri {
                    if let closeNextDay = self.google_close_sat {
                        let result = compareOpeningHours(openSameDay: open, closeSameDay: closeSameDay, closeNextDay: closeNextDay)
                        oh_string = result
                    }
                }
                else {
                    //no closing for same day provided, so next day default
                    if let closeNextDay = self.google_close_sat {
                        oh_string = "\(open) - \(closeNextDay)"
                    }
                }
            }
            
            break
            
        case 7:
            if let open = self.google_open_sat {
                if let closeSameDay = self.google_close_sat {
                    if let closeNextDay = self.google_close_sun {
                        let result = compareOpeningHours(openSameDay: open, closeSameDay: closeSameDay, closeNextDay: closeNextDay)
                        oh_string = result
                    }
                }
                else {
                    //no closing for same day provided, so next day default
                    if let closeNextDay = self.google_close_sun {
                        oh_string = "\(open) - \(closeNextDay)"
                    }
                }
            }
            
            break
            
        case 1: //SUNDAY
            if let open = self.google_open_sun {
                if let closeSameDay = self.google_close_sun {
                    if let closeNextDay = self.google_close_mon {
                        let result = compareOpeningHours(openSameDay: open, closeSameDay: closeSameDay, closeNextDay: closeNextDay)
                        oh_string = result
                    }
                }
                else {
                    //no closing for same day provided, so next day default
                    if let closeNextDay = self.google_close_mon {
                        oh_string = "\(open) - \(closeNextDay)"
                    }
                }
            }
            
            break
        default:
            break
        }
        
        if oh_string == "00:00 - 00:00" {
            oh_string = "Geschlossen"
        }
        else if oh_string.characters.count == 11 {
            oh_string.insert(":", at: oh_string.index(oh_string.startIndex, offsetBy: 2))
            oh_string.insert(":", at: oh_string.index(oh_string.startIndex, offsetBy: 10))
        }
        
        
        return oh_string
    }
    
    func getHappyHourForWeekday(weekday: Int) -> String {
        //String from Backend
        //"tue&23:00&end"    length: 13
        //"thu&18:00&20:00"  length: 15
        var happyHourString = "-"
        
        if let happyHours = self.nightlive_happyHours {
            for happyHour in happyHours {
                let day = happyHour.substring(with: 0..<3)
                let weekdayNumberString = weekdayNumberStringDict[weekday]
                if day == weekdayNumberString {
                    let happyHourCount = happyHour.characters.count
                    var firstTime = ""
                    var secondTime = ""
                    if happyHourCount == 13 {
                        //happy Hour until end (opening hours)
                        //"tue&23:00&end"   length: 13
                        firstTime = happyHour.substring(with: 4..<9)
                        secondTime = "Ende!"
                        
                    }
                    else {
                        //happy hour endtime provided
                        //"thu&18:00&20:00  length: 15
                        firstTime = happyHour.substring(with: 4..<9)
                        secondTime = happyHour.substring(with: 10..<15)
                    }
                    
                    //add firstTime and secondTime to HappyHourString
                    let count = happyHourString.characters.count
                    if  count == 1 {
                        happyHourString = "\(firstTime) - \(secondTime)"
                    }
                    else if count <= 13 {
                        //already added one time, so add another
                        happyHourString += " & \(firstTime) - \(secondTime)"
                    }
                }
                
            }
        }
        
        return happyHourString
    }
    
    
    fileprivate func compareOpeningHours(openSameDay: String, closeSameDay: String, closeNextDay: String) -> String {
        var ohString = ""
        
        let closesameDayInt = Int(closeSameDay)!
        let closeNextDayInt = Int(closeNextDay)!
        let openSameDayInt =  Int(openSameDay)!
        /*if closesameDayInt == 0 {
         ohString = "\(open) - \(midnight)"
         }
         else if closeNextDayInt == 0 {
         ohString = "\(open) - \(midnight)"
         }*/
        if closesameDayInt < openSameDayInt {
            //opening hour is not for this day.
            ohString = "\(openSameDay) - \(closeNextDay)"
        }
        else {
            ohString = "\(openSameDay) - \(closeSameDay)"
        }
        
        return ohString
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
