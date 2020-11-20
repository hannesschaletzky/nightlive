//
//  Model.swift
//  wasgehtwo
//
//  Created by Hannes Schaletzky on 04/06/16.
//  Copyright © 2016 Hannes Schaletzky. All rights reserved.
//


//MARK: - StringConstants
public struct StringConstants {
    //NSUserDefaults
    static let NSUserDefCountryKey = "NSUserDefaultsKeyForCountry"
    static let NSUserDefStateKey = "NSUserDefaultsKeyForState"
    static let NSUserDefCityKey = "NSUserDefaultsKeyForCity"
    static let NSUserDefDistrictKey = "NSUserDefaultsKeyForDistrict"
    
    //Sign Up Login
    static let signup = "Sign Up"
    static let login = "Login"
    static let anonymously = "Anonymously"
    static let signUpLoginSuccess = "SignUpLoginSuccess"
    static let signUpLoginFail = "SignUpLoginFailed"
    static let anonymouslySuccess = "AnonymouslySuccess"
    static let anonymouslyFail = "AnonymouslyFail"
    static let correctEntry = "correctEntry"
    static let wrongEntry = "wrongEntry"
    
    //User Preferences
    static let actionCountry = "actionCountry"
    static let actionState = "actionState"
    static let actionCity = "actionCity"
    static let actionDistrict = "actionDistrict"
    static let noItems = "NoItemsInObject"
    static let errorWhileRetrievingItems = "ErrorWhileRetrievingItemsOccured"
}

public let nsNC = NotificationCenter.default
var instance_landingPageVC:LandingPageViewController? = nil
var instance_eventsVC:EventsViewController? = nil
var instance_vouchersVC:VouchersViewController? = nil
var instance_clubsVC:ClubsViewController? = nil
var instance_barsVC:BarsViewController? = nil
var instance_pagerVC:PagerViewController? = nil
var instance_mapVC:MapViewController? = nil

//control Flow Variable
var global_filteredClub = ""
var global_clubsFilterSet = false

var global_mapsFilteredLocation = ""
var global_mapsFilterSet = false

var global_activeController = UIViewController() 


//MARK: - Dates
public func getComponentsOfDate(_ date: Date) -> DateComponents {
    let calendar = Calendar.current
    let dateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.nanosecond, NSCalendar.Unit.timeZone], from: date)
    
    var components = DateComponents()
    components.day = dateComponents.day
    components.month = dateComponents.month
    components.year = dateComponents.year
    components.hour = dateComponents.hour
    components.minute = dateComponents.minute
    components.second = dateComponents.second
    components.weekday = dateComponents.weekday
    (components as NSDateComponents).timeZone = (dateComponents as NSDateComponents).timeZone
    
    return components
}

//MARK: - User Age
public func isUserInValidAgeRange(_ userYear: Int) -> Bool {
    let components = getComponentsOfDate(Date())
    let year = components.year
    
    //           1896...2000   = 1995
    if case year!-120...year!-16 = userYear {
        return true
    }
    
    return false
}

//MARK: - User Favorites
func isEventInFavoriteEvents(eventID: String) -> Bool {
    var isInFavorites = false
    for favoriteEventID in allFavoriteEvents {
        if favoriteEventID == eventID {
            //print("Event \(eventID) is in Favorites")
            isInFavorites = true
        }
    }
    
    return isInFavorites
}

func isLocationInFavoriteLocations(locationGooglePlacesID: String?, locationFacebookID: String?) -> Bool {
    var isInFavorites = false
    var toCompare = ""
    if locationGooglePlacesID != nil {
        toCompare = locationGooglePlacesID!
    }
    else if locationFacebookID != nil {
        toCompare = locationFacebookID!
    }
    for id in allFavoriteLocations {
        if id == toCompare {
            isInFavorites = true
        }
    }
    
    return isInFavorites
}


//MARK: - HappyHour (Is Currently)

fileprivate var now = getDateNowUnderConsiderationOfTimeZone()
fileprivate var todayWeekday = getTodaysWeekday()
fileprivate var dateFormatter = DateFormatter()

func setDateVariablesForHappyHourAndOpeningHourToCurrent() {
    now = getDateNowUnderConsiderationOfTimeZone() //cheeky
    todayWeekday = getTodaysWeekday()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
}
                                                    //   yes/no,endTime,untilClosing
func isLocationCurrentlyInHappyHour(location: Location) -> (Bool,String,Bool) {
    
    let allPossibleHappyHours = getAllPossibleHappyHoursForTodayOf(location: location)
    
    if !allPossibleHappyHours.isEmpty {
        
        var startTime = String()
        var endTime = String()
        var lastDay = Int()
        var untilClosing = Bool()
        var startDate = Date()
        var endDate = Date()
        
        //check every happyHour
        //22:00 - 23:00
        //22:00 - Ende!
        for object in allPossibleHappyHours {
            
            let happyHour = object.value
            let key = object.key
            
            startTime = ""
            endTime = ""
            untilClosing = false
            
            //determine weekday of happyHour
            var happyHourWeekDay = 1
            if key < 10 {
                happyHourWeekDay = key
            }
            else if key/10 < 10 {
                happyHourWeekDay = key/10
            }
            
            //determine starttime and endtime
            startTime = happyHour.substring(with: 0..<5)
            endTime = happyHour.substring(with: 8..<13)
            
            //determine if it's until closing
            if endTime == "Ende!" {
                untilClosing = true
            }
            
            //set lastDay correctly
            if todayWeekday == 1 {
                lastDay = 7
            }
            else {
                lastDay = todayWeekday-1
            }
            
            
            //determine today or yesterday
            //TODAY
            if happyHourWeekDay == todayWeekday {
                
                startDate = getDateFromHourAndMinuteString(hourAndMinute: startTime)
                
                if untilClosing {
                    //endTime == "Ende"
                    if location.google_openingHours_provided {
                        //Opening Hours provided
                        let todayOH = location.getOpeningHourStringForWeekday(weekday: todayWeekday) //what happens if "Geschlossen" is given?
                        let closingTime = todayOH.substring(with: 8..<13)
                        endDate = getDateFromHourAndMinuteString(hourAndMinute: closingTime)
                        if compareIfNowIsBetween(startDate: startDate, endDate: endDate) {
                            return (true,closingTime,true)
                        }
                    }
                    else {
                        //Opening Hours not provided
                        //return (false,"Ende!",true)
                        //We cannot determine whether it's still in happyHour or not... notify user!
                    }
                    
                }
                else {
                    //not until Closing
                    endDate = getDateFromHourAndMinuteString(hourAndMinute: endTime)
                    
                    //check if endDate is day after... so we cover the time until midnight
                    
                    if isEndDateSmallerThanStartDate(happyHour: happyHour)  {
                        //happy hour is until after midnight, so ends at next day (means today)
                        endDate = endDate.addingTimeInterval(60*60*24)
                    }
                    if compareIfNowIsBetween(startDate: startDate, endDate: endDate) {
                        return(true,endTime,false)
                    }
                    
                }
            
            }
            //Yesterday
            else if happyHourWeekDay == lastDay {
                
                startDate = getDateFromHourAndMinuteString(hourAndMinute: startTime)
                startDate = startDate.addingTimeInterval(60*60*24 * -1)
                
                if untilClosing {
                    //endTime == "Ende"
                    if location.google_openingHours_provided {
                        //Opening Hours provided
                        let todayOH = location.getOpeningHourStringForWeekday(weekday: lastDay) //what happens if "Geschlossen" is given?
                        let closingTime = todayOH.substring(with: 8..<13)
                        endDate = getDateFromHourAndMinuteString(hourAndMinute: closingTime)
                        if compareIfNowIsBetween(startDate: startDate, endDate: endDate) {
                            return (true,closingTime,true)
                        }
                    }
                    else {
                        //Opening Hours not provided
                        //return (false,"Ende!",true)
                        //We cannot determine whether it's still in happyHour or not... notify user!
                        
                        
                        //Wenn das so zutrifft hier, aber keine Opening hours provided sind, dann mach continue, sprich geh die anderen happy HOurs noch durch und setzt aber ne Flag, falls alle Happy Hours durch sind, dass die eine happyHour zutrifft und es evtl. noch ne happy Hour ist - du es aber nicht zuordnen kannst weil die Öffnungszeiten nicht gegeben sind... Dafür musst du aber erst checken ob now später als startTime von der HappyHour ist.
                        
                    }
                }
                else {
                    if isEndDateSmallerThanStartDate(happyHour: happyHour) {
                        //happy hour is until after midnight, so ends at next day (means today)
                        endDate = getDateFromHourAndMinuteString(hourAndMinute: endTime)
                        if compareIfNowIsBetween(startDate: startDate, endDate: endDate) {
                            return(true,endTime,false)
                        }
                    }
                    
                }
                
            }
            
            
            
        }
         
        //no happy hour was hit
        return (false,"",false)
        
    }
    else {
        //no Happy Hours for this place today and yesterday
        return (false,"",false)
    }
    
}


//First get all possible Happy Hours as a String array
fileprivate func getAllPossibleHappyHoursForTodayOf(location: Location) -> [Int:String] {
    var allPossibleHappyHours = [Int:String]()
    allPossibleHappyHours.removeAll()
    
    //22:00 - 23:00 & 23:30 - 02:00
    //22:00 - 23:00
    
    let todaysWeekday = getTodaysWeekday()
    var time = ""
    
    //HappyHour Today
    let happyHoursForToday = location.getHappyHourForWeekday(weekday: todaysWeekday)
    if happyHoursForToday.characters.count > 1 {
        time = happyHoursForToday.substring(with: 0..<13)
        allPossibleHappyHours[todaysWeekday] = time
        if happyHoursForToday.characters.count > 13 {
            time = happyHoursForToday.substring(with: 16..<29)
            allPossibleHappyHours[todaysWeekday*10] = time
        }
    }
    
    //Happy Hour Yesterday
    var happyHoursYesterday = ""
    var lastDay = Int()
    if todaysWeekday == 1 {
        happyHoursYesterday = location.getHappyHourForWeekday(weekday: 7)
        lastDay = 7
    }
    else {
        happyHoursYesterday = location.getHappyHourForWeekday(weekday: todaysWeekday-1)
        lastDay = todayWeekday-1
    }
    if happyHoursYesterday.characters.count > 1 {
        time = happyHoursYesterday.substring(with: 0..<13)
        allPossibleHappyHours[lastDay] = time
        if happyHoursYesterday.characters.count > 13 {
            time = happyHoursYesterday.substring(with: 16..<29)
            allPossibleHappyHours[lastDay*10] = time
        }
    }
    
    return allPossibleHappyHours
}


fileprivate func getDateFromHourAndMinuteString(hourAndMinute: String) -> Date {
    var hour = hourAndMinute.substring(with: 0..<2)
    var isMidnight = false
    
    if hour == "24" {
        hour = "00"
        isMidnight = true
    }
    let minute = hourAndMinute.substring(with: 3..<5)
    
    let comp = getComponentsOfDate(Date())
    let dateString = "\(comp.year!)-\(comp.month!)-\(comp.day!) \(hour):\(minute):00 +0000"
    var date = dateFormatter.date(from: dateString)!
    if isMidnight {
        //add one day manually, because otherwise it will interprete midnight from the current day...
        date = date.addingTimeInterval(60*60*24)
    }
    return date
}

fileprivate func isEndDateSmallerThanStartDate(happyHour: String) -> Bool {
    let startHour = happyHour.substring(with: 0..<2)
    let startMinute = happyHour.substring(with: 3..<5)
    let endHour = happyHour.substring(with: 8..<10)
    let endMinute = happyHour.substring(with: 11..<13)
    
    var startInt = Int(startHour)!*100
    startInt += Int(startMinute)!
    
    var endInt = Int(endHour)!*100
    endInt += Int(endMinute)!
    
    if endInt < startInt {
        return true
    }
    return false
    
    
    
}

fileprivate func compareIfNowIsBetween(startDate: Date, endDate: Date) -> Bool {
    if now.compare(startDate) == ComparisonResult.orderedDescending && now.compare(endDate) == ComparisonResult.orderedAscending {
        return true
    }
    return false
}

//MARK: - HappyHour (Next)

func getNextHappyHourOf(location: Location) -> String {
    
    var happyHourString = ""
    var currentDistance = -1
    var startTime = ""
    var endTime = ""
    let components = getComponentsOfDate(Date())
    
    let allPossibleHappyHours = getAllPossibleHappyHoursForTodayOf(location: location)
    
    
    for object in allPossibleHappyHours {
        
        let happyHour = object.value
        let key = object.key
        
        //determine weekday of happyHour
        var happyHourWeekDay = 1
        if key < 10 {
            happyHourWeekDay = key
        }
        else if key/10 < 10 {
            happyHourWeekDay = key/10
        }
        
        if happyHourWeekDay == todayWeekday {
            //determine starttime and endtime
            startTime = happyHour.substring(with: 0..<5)
            endTime = happyHour.substring(with: 8..<13)
            
            //HappyHour Starttime
            let startHour = happyHour.substring(with: 0..<2)
            let startMinute = happyHour.substring(with: 3..<5)
            let happyHourHourMinuteString = "\(startHour)\(startMinute)"
            let happyHourHourMinuteInt = Int(happyHourHourMinuteString)!
            
            //Now
            let nowHourMinuteString = "\(components.hour!)\(components.minute!)"
            let nowHourMinuteInt = Int(nowHourMinuteString)!
            
            
            //Check HappyHour
            if nowHourMinuteInt < happyHourHourMinuteInt {
                //we muste be before start
                
                if currentDistance == -1 {
                    //initialize
                    currentDistance = happyHourHourMinuteInt - nowHourMinuteInt
                    happyHourString = "\(startTime) - \(endTime)"
                }
                else {
                    let newDistance = happyHourHourMinuteInt - nowHourMinuteInt
                    if newDistance < currentDistance {
                        //found happyHour with less time to startPoint
                        currentDistance = newDistance
                        happyHourString = "\(startTime) - \(endTime)"
                    }
                }
            }
            
            
            
        }
        
        
    }
    
    return happyHourString
    
}



//MARK: - Opening Hours
func getNextOpeningHourOf(location: Location) -> String {
    var openingHour = ""
    
    if dateIsInTheMiddleOfTheNight(date: Date()) {
        if todayWeekday == 1 {
            openingHour = location.getOpeningHourStringForWeekday(weekday: 7)
        }
        else {
            openingHour = location.getOpeningHourStringForWeekday(weekday: todayWeekday-1)
        }
    }
    else {
        openingHour = location.getOpeningHourStringForWeekday(weekday: todayWeekday)
    }
    
    return openingHour
    
}

//MARK: - Map Annotations
import MapKit

var todaysWeekDay = getTodaysWeekday()
var clubAnnotations = [LocationAnnotation]()
var barAnnotations = [LocationAnnotation]()

class LocationAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let location: Location
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, location: Location, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.location = location
        self.coordinate = coordinate
        
        
        super.init()
    }
    
}

func addAnnotation(location: Location) {
    if location.google_location_lat != nil && location.google_location_lng != nil {
        let openingHours = location.getOpeningHourStringForWeekday(weekday: todaysWeekDay)
        var happyHour = ""
        let result = isLocationCurrentlyInHappyHour(location: location)
        if  result.0 {
            happyHour = ("Bis: \(result.1)")
        }
        else {
            happyHour = getNextHappyHourOf(location: location)
        }
        
        let annotation = LocationAnnotation(title: location.nightlive_display_name,
                                            subtitle: "\(openingHours), \(happyHour)",
            location:  location,
            coordinate: CLLocationCoordinate2D(latitude: location.google_location_lat!, longitude: location.google_location_lng!))
        
        if location is Bar {
            barAnnotations.append(annotation)
        }
        if location is Club {
            clubAnnotations.append(annotation)
        }
    }
    
}

//MARK: - User Location
import CoreLocation
var  locationManager:CLLocationManager?

func setupLocationManager() {
    //called in viewDidLoad of LandingPageVC
    locationManager = CLLocationManager()
    locationManager?.delegate = instance_mapVC as CLLocationManagerDelegate?
}

func isAppAuthorizedToUseLocation() -> Bool {
    let result = CLLocationManager.authorizationStatus()
    if result == CLAuthorizationStatus.authorizedWhenInUse {
        return true
    }
    
    return false
}

func startUpdatingLocation() {
    locationManager?.startUpdatingLocation()
    print("start updating location")
}

func endUpdatingLocation() {
    locationManager?.stopUpdatingLocation()
    print("end updating location")
}

func isLocationServicesEnabled() -> Bool {
    return CLLocationManager.locationServicesEnabled()
}

func didUserDenyLocationServices() -> Bool {
    let result = CLLocationManager.authorizationStatus()
    if result == .denied {
        //denied
        return true
    }
    else if result == CLAuthorizationStatus.notDetermined {
        //has not made a choice yet
        return true
    }
    return false
}

//MARK: - Search                                         
                                                        //NAME,Type
func searchForLocation_Event(searchString: String) -> [(String,String)] {
    var results = [(String,String)]()
    results.removeAll()
    
    let searchString = searchString.lowercased()
    
    //EVENTS
    for event in allFBEvents {
        if let eventName = event.facebook_name {
            let lowerCasedDisplayName = eventName.lowercased()
            if lowerCasedDisplayName.contains(searchString) {
                results.append((eventName,"Event"))
            }
        }
    }
    
    //CLUBS
    for club in allClubs {
        let lowerCasedDisplayName = club.nightlive_display_name.lowercased()
        if lowerCasedDisplayName.contains(searchString) {
            results.append((club.nightlive_display_name,"Club"))
        }
    }
    
    //BARS
    for bar in allBars {
        let lowerCasedDisplayName = bar.nightlive_display_name.lowercased()
        if lowerCasedDisplayName.contains(searchString) {
            results.append((bar.nightlive_display_name,"Bar"))
        }
    }
    
    return results
}



//MARK: - Additionals - FILTER
func isLocationOpen(location: Location, isNow: Bool) -> Bool {
    if isNow {
        //check now
        if location.google_open_now != nil {
            if location.google_open_now! {
                return true
            }
        }
    }
    else {
        //check for today
        let nextOpeningHour = getNextOpeningHourOf(location: location)
        if nextOpeningHour != "Geschlossen" {
            return true
        }
    }
    return false
}

func isLocationInHappyHour(location: Location, isNow: Bool) -> Bool {
    if isNow {
        //check now
        let result = isLocationCurrentlyInHappyHour(location: location)
        if  result.0 {
            return true
        }
    }
    else {
        //check for today
        let nextHappyHour = getNextHappyHourOf(location: location)
        if nextHappyHour != "" {
            return true
        }
        
    }
    return false
}


























