//
//  API.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 26/03/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import Foundation
import Parse

//MARK: - Global Variables
public let parseServerURL = "https://parseapi.back4app.com"
public let parseServerAppID = "ENPEorSkCLPcSaLuczm97S6GKDMZup40wDoIzo8F"
public let parseServerClientKey = "VQcvIlLzjPwgyEpHQWJdhU2jiIrmx1ctGTKQWq1v"
public let parseServerRestKey = "LV5sw0O7KIcnsUFdbnIXGgqH8wnU2HQLCo4Zlh7s"
public let parseServerMasterKey = "8PXYV95J1mdcFXydoDGfIasmBY4eDYBsDzy5aiDP"

//Facebook Credentials
let facebookAppSecret = "d316d17077c71d4e6f4f7227f9fe0b52"
let facebookAppID = "1126230424104158"

//Google Credentials
let googleAPIKey = "AIzaSyAhueCi1MdgZCj3661155Jf7fW3vB2-PAQ"
let googleWebServiesAPIKey = "AIzaSyCSFKE-8u9pXCHzwkHBDg2cynzjrS-UE14"

//Date over the whole App
var dateToWorkWith = Date() {
    didSet {
        print("new date is \(dateToWorkWith)")
    }
}

//City
var cityToWorkWithID = "nK9vjFrvWK"

//MARK: - Events (Facebook)
fileprivate var clubsFromEvents = [ClubFromEvent]()
var allFBEvents = [Event]()
var allFBEvents_filtered = [Event]()
var pageEventsCallBackCounter = Int()
var pageEventsCallBackSuccessCounter = Int()
var timeStamp = (Double(),Double())

//private Class only for passing some data from the club to the call for the events for the club
fileprivate class ClubFromEvent {
    var facebook_id: String //mandatory
    var visible: Bool       //mandatory
    var display_name: String//manatory
    var googlePlacesID: String?
    
    init(facebook_id: String, visible: Bool, display_name: String) {
        self.facebook_id = facebook_id
        self.visible = visible
        self.display_name = display_name
    }
}

func startFetchingFacebookEvents() {
    retrieveClubsFromNightlive()
}

private func retrieveClubsFromNightlive() {
    
    let tableName = "Locations_Clubs"
    
    let countQuery = PFQuery(className: tableName)
    countQuery.whereKey("city_id_string", equalTo: cityToWorkWithID)
    countQuery.whereKey("visible", equalTo: true)
    countQuery.countObjectsInBackground { (resultInt32, error) in
        if error != nil {
            print(error ?? "Error in counting Clubs")
        }
        else {
            if Int(resultInt32) == clubsFromEvents.count {
                //skip call to nightlive, because no new clubs
                startLoadingEventsForClubs(clubsFromEvents: clubsFromEvents)
            }
            else {
                //don't skip because there is a new club added
                
                clubsFromEvents.removeAll()
                var successCallBackCounter = 0
                
                let query = PFQuery(className: tableName)
                query.selectKeys(["facebook_id,display_name,visible,googlePlacesID"])
                query.whereKey("city_id_string", equalTo: cityToWorkWithID)
                query.whereKey("visible", equalTo: true)
                query.findObjectsInBackground { (results, error) in
                    if error != nil || results == nil {
                        //Error
                        print("Error CallBack")
                    }
                    else {
                        //Success
                        print("Success CallBack")
                        
                        for item in results! {
                            item.fetchIfNeededInBackground(block: { (object, error) in
                                
                                if error != nil || object == nil {
                                    print("Error in RetrieveClubsFromNightlive with \(item)")
                                }
                                else {
                                    successCallBackCounter += 1
                                    if let stringID = item["facebook_id"] as? String {
                                        if let visible = item["visible"] as? Bool {
                                            if let display_name = item["display_name"] as? String {
                                                print("creating clubFromEvent with facebookClubID: \(stringID)")
                                                let tempClubForEvent = ClubFromEvent(facebook_id: stringID, visible: visible, display_name: display_name)
                                                clubsFromEvents.append(tempClubForEvent)
                                                if let googlePlaceID = item["googlePlacesID"] as? String {
                                                    tempClubForEvent.googlePlacesID = googlePlaceID //add google place ID
                                                }
                                            }
                                        }
                                    }
                                    if successCallBackCounter == results?.count {
                                        startLoadingEventsForClubs(clubsFromEvents: clubsFromEvents)
                                    }
                                }
                                
                            })
                            
                        }
                        
                    }
                    
                    
                    
                }

                
                
            }
        }
    }
    
    
}

private func startLoadingEventsForClubs(clubsFromEvents: [ClubFromEvent]) {
    
    allFBEvents.removeAll()
    allFBEvents_filtered.removeAll()
    pageEventsCallBackCounter = 0
    pageEventsCallBackSuccessCounter = 0
    
    let timeStamp = createTimeStampForSpecificDate(dateBegin: dateToWorkWith, dateEnd: nil)
    for club in clubsFromEvents {
        startFacebookRequestForEventsOfClub(clubFromEvent: club, clubsFromEvents: clubsFromEvents, timeStamp: timeStamp)
    }
}

private func startFacebookRequestForEventsOfClub(clubFromEvent: ClubFromEvent, clubsFromEvents: [ClubFromEvent], timeStamp: (Double,Double)) {
    
    let acccessTokenString = getFacebookAccessTokenString() 
    let fieldsToRetrieve = "id,name,description,start_time,end_time,interested_count,attending_count"
    let params = ["fields":fieldsToRetrieve , "access_token": acccessTokenString, "since":"\(timeStamp.0)", "until":"\(timeStamp.1)"]
    
    let request = FBSDKGraphRequest(graphPath: "/\(clubFromEvent.facebook_id)/events" , parameters: params, httpMethod: "GET")
    request?.start(completionHandler: { (connection, objects, error) -> Void in
     
        pageEventsCallBackCounter+=1
        print("")
        print("Requested Events of Page \(clubFromEvent.facebook_id)")
        print("Callback Handling")
        if error != nil || objects == nil {
            //ERROR
            print("Error")
            print(error ?? "Error")
            //WRITE ERROR TO ERROR TABLE IN PARSE!!! so we can track the errors and e.g. edit the facebook ids of the clubs
        }
        else {
            //SUCCESS
            print("SUCCESS")
            
            // parse the result as JSON
            guard let responseDate = objects as? [String:Any] else {
                print("Error")
                return
            }
            pageEventsCallBackSuccessCounter+=1
                
            if let data = responseDate["data"] {
                if let entries = data as? [[String:Any]] {
                    if !entries.isEmpty {
                        for eventData in entries {
                            if let eventID = eventData["id"] as? String {
                                let eventToAdd = Event(nightlive_facebook_id: eventID, nightlive_club_visible: clubFromEvent.visible) 
                                
                                fillEventWithFacebookData(event: eventToAdd, data: eventData)
                                fillEventWithNightliveData(event: eventToAdd, data: clubFromEvent)
                                allFBEvents.append(eventToAdd)
                            }
                        }
                    }
                }
            }
            
            if pageEventsCallBackSuccessCounter == clubsFromEvents.count {
                print("all Clubs have Success Callback - continuing")
                instance_eventsVC?.displayAllEvents(fromRemoveAllFilter: false)
            }
            else if pageEventsCallBackCounter == clubsFromEvents.count {
                print("Not all clubs have success Callback... - continuing")
                instance_eventsVC?.displayAllEvents(fromRemoveAllFilter: false)
            }
            
            
        }
        
    })
    
    
}

func fillEventWithFacebookData(event: Event, data: [String:Any]) {
    
    if let name = data["name"] as? String {
        event.facebook_name = name
    }
    if let description = data["description"] as? String {
        event.facebook_description = description
    }
    if let start_time = data["start_time"] as? String {
        event.facebook_start_time = start_time
    }
    if let end_time = data["end_time"] as? String {
        event.facebook_end_time = end_time
    }
    if let interested_count = data["interested_count"] as? Int32 {
        event.facebook_interested_count = interested_count
    }
    if let attending_count = data["attending_count"] as? Int32 {
        event.facebook_attending_count = attending_count
    }
    if let is_canceled = data["is_canceled"] as? Bool {
        event.is_canceled = is_canceled
    }
    
}

fileprivate func fillEventWithNightliveData(event: Event, data: ClubFromEvent) {
    
    //this is a mandatory property, that's why there is no check
    event.nightlive_club_display_name = data.display_name
    if let googlePlaceID = data.googlePlacesID {
        event.nightlive_club_googlePlaceID = googlePlaceID
    }
    
}

//MARK: - Events - Clubs (Facebook)
func retrieveNextEventsForClub(club: Club, clubFacebookID: String, notificationString: String) {
    
    let acccessTokenString = getFacebookAccessTokenString()
    let timeStamp = createTimeStampForSpecificDate(dateBegin: Date(), dateEnd: Date().addingTimeInterval(60*60*24*90))
    let fieldsToRetrieve = "id,name,start_time,interested_count,attending_count"
    let params = ["fields":fieldsToRetrieve , "access_token": acccessTokenString, "since":"\(timeStamp.0)", "until":"\(timeStamp.1)"]
    
    let request = FBSDKGraphRequest(graphPath: "/\(clubFacebookID)/events" , parameters: params, httpMethod: "GET")
    request?.start(completionHandler: { (connection, objects, error) -> Void in
        
        
        print("")
        print("Requested Events of Page \(clubFacebookID)")
        print("Callback Handling")
        if error != nil || objects == nil {
            //ERROR
            print("Error")
            print(error ?? "Error")
            //WRITE ERROR TO ERROR TABLE IN PARSE!!! so we can track the errors and e.g. edit the facebook ids of the clubs
        }
        else {
            //SUCCESS
            print("SUCCESS")
            club.upcomingEvents.removeAll()
            
            // parse the result as JSON
            guard let responseDate = objects as? [String:Any] else {
                print("Error")
                return
            }
            
            if let data = responseDate["data"] {
                if let entries = data as? [[String:Any]] {
                    if !entries.isEmpty {
                        for eventData in entries {
                            if let eventID = eventData["id"] as? String {
                                let eventToadd = Event(nightlive_facebook_id: eventID, nightlive_club_visible: true)
                                club.upcomingEvents.append(eventToadd)
                                fillEventWithFacebookData(event: eventToadd, data: eventData)
                            }
                        }
                    }
                }
            }
            nsNC.post(name: NSNotification.Name(rawValue: notificationString), object: nil)
        }
        
    })

    
}


//MARK: - Clubs & Bars (Google)

var allBars = [Bar]()
var allBars_Filtered = [Bar]()
var allClubs = [Club]()
var allClubs_Filtered = [Club]()

func retrievePlaceIDsFromNightliveFor(isRequestForClubs: Bool) {
    
    var tableName = ""
    if isRequestForClubs { 
        tableName = "Locations_Clubs"
        allClubs.removeAll()
        allClubs_Filtered.removeAll()
        clubAnnotations.removeAll()
    }
    else {
        tableName = "Locations_Bars"
        allBars.removeAll()
        allBars_Filtered.removeAll()
        barAnnotations.removeAll()
    }
    
    let query = PFQuery(className: tableName)
    if isRequestForClubs {
        query.selectKeys(["googlePlacesID,display_name,visible,happyHours,Detailed_Description,facebook_id"])
    }
    else {
        query.selectKeys(["googlePlacesID,display_name,visible,happyHours,Detailed_Description,facebook_id"])
    }
    query.whereKey("city_id_string", equalTo: cityToWorkWithID)
    query.whereKey("visible", equalTo: true)
    
    print("Executing Call to LocationsTable...")
    query.findObjectsInBackground { (results, error) in
        if error != nil || results == nil {
            //Error
            print("Error CallBack or no Data")
        }
        else {
            //Success
            print("Success CallBack")
            var callbackCounter = 0
            var callbackSuccessCounter = 0
            var filledSuccessfullyCounter = 0
            for item in results! {
                item.fetchIfNeededInBackground(block: { (object, error) in
                    callbackCounter += 1
                    
                    // check for any errors
                    guard error == nil else {
                        print("error in receiving data from nightlive")
                        print(error?.localizedDescription ?? "Error")
                        return
                    }
                    // make sure we got data
                    guard object != nil else {
                        print("Error: did not receive data from nightlive")
                        return
                    }
                    
                    if let displayName = object?["display_name"] as? String {
                        var location = Location(nightlive_display_name: "not important")
                        if let stringID = object?["googlePlacesID"] as? String {
                            callbackSuccessCounter += 1 //Success, when placeID is there
                            if isRequestForClubs {
                                //Add Club to allClubs
                                let clubToAdd = Club(nightlive_display_name: displayName)
                                clubToAdd.nightlive_googlePlacesID = stringID
                                allClubs.append(clubToAdd)
                                location = clubToAdd
                            }
                            else {
                                //Add Bar to allBars
                                let barToAdd = Bar(nightlive_display_name: displayName)
                                barToAdd.nightlive_googlePlacesID = stringID
                                allBars.append(barToAdd)
                                location = barToAdd
                            }
                        }
                        else {
                            print("No googlePlacesID for: \(displayName)")
                            if isRequestForClubs {
                                //Add Club to allClubs without GooglePlaceID
                                let clubToAdd = Club(nightlive_display_name: displayName)
                                clubToAdd.nightlive_googlePlacesID = nil
                                allClubs.append(clubToAdd)
                                location = clubToAdd
                            }
                            else {
                                //Add Bar to allBars without GooglePlaceID
                                let barToAdd = Bar(nightlive_display_name: displayName)
                                barToAdd.nightlive_googlePlacesID = nil
                                allBars.append(barToAdd)
                                location = barToAdd
                            }
                        }
                        
                        //fill rest of the properties
                        let filledSuccessfully = fillLocationWithNightliveData(location: location, data: object!)
                        if filledSuccessfully {
                            filledSuccessfullyCounter += 1
                        }
                    }
                        
                    if callbackSuccessCounter == callbackCounter &&
                        callbackSuccessCounter == results?.count &&
                        filledSuccessfullyCounter == results?.count {
                        print("All Items have placeID and displayName, all callbacks are here, all items filled successfully")
                        fetchDataForPlacesFromGoogle(isRequestForClubs: isRequestForClubs)
                    } 
                    else if callbackSuccessCounter != callbackCounter && callbackCounter == results?.count {
                        print("not all Items have placeID, all callbacks are here")
                        fetchDataForPlacesFromGoogle(isRequestForClubs: isRequestForClubs)
                    }
                        
                    //COVER THE CASE WHEN NOT EVERYTHING COMES BACK LIKE AFTER 5 SECONDS
                    
                })
                
            }
            
        }
    }
    
}


//REST API GOOGLE CALL
func fetchDataForPlacesFromGoogle(isRequestForClubs: Bool) {
    
    var callbackCounter = 0
    var callbackSuccessCounter = 0
    var objectUpdateCounter = 0
    
    //sort out the locations without googlePlacesID
    var locations = [Location]()
    if isRequestForClubs {
        for club in allClubs {
            if let _ = club.nightlive_googlePlacesID {
                locations.append(club)
            }
        }
    }
    else {
        for bar in allBars {
            if let _ = bar.nightlive_googlePlacesID {
                locations.append(bar)
            }
        }
    }
    
    print("Executing REST Calls for \(locations.count) Locations with Google Places ID...")
    for location in locations {
        let googleAPIKeyREST = "AIzaSyCSFKE-8u9pXCHzwkHBDg2cynzjrS-UE14"
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(location.nightlive_googlePlacesID!)&key=\(googleAPIKeyREST)"
        
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            return
        }
        
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            callbackCounter += 1
            //check for any errors
            guard error == nil else {
                print("error calling GET on Google Web Services")
                print(error?.localizedDescription ?? "Error")
                return
            }
            //make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            //parse the result as JSON
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String:Any] else {
                    print("error trying to convert data to JSON")
                    return
                }
                
                //drill into JSON Object
                guard let data = jsonObject["result"] as? [String:Any] else {
                    print("--------- Error for place: \(location.nightlive_display_name)")
                    print("Could not get data from JSON")
                    return
                }
                
                //successfully converted to JSON
                callbackSuccessCounter += 1
                if let _ = data["name"] {
                    print("Success for: \(location.nightlive_display_name)")
                }
                
                let objectFilledSuccessfully = fillLocationWithGoogleData(location: location, data: data)
                
                if objectFilledSuccessfully {
                    addAnnotation(location: location) //for map
                    objectUpdateCounter += 1
                }
                
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            
            if callbackCounter == locations.count {
                print("All callbacks here - continuing...")
                if isRequestForClubs {
                    instance_clubsVC?.displayAllClubs()
                }
                else {
                    instance_barsVC?.displayAllBars()
                }
                instance_mapVC?.displayAnnotations()
            }
            
        })
        task.resume()

    }
    
    
}

func fillLocationWithNightliveData(location:Location, data:PFObject) -> Bool {
    
    let errorOccured = false
    
    //check entirely if data has entries
    if let description = data["Detailed_Description"] as? String {
        location.nightlive_detailed_description = description
    }
    if let facebookID = data["facebook_id"] as? String {
        location.nightlive_facebookID = facebookID
    }
    if let visible = data["visible"] as? Bool {
        location.nightlive_visible = visible
    }
    
    if let happyHours = data["happyHours"] as? [String] {
        location.nightlive_happyHours_provided = true
        location.nightlive_happyHours = happyHours
    }
    else {
        location.nightlive_happyHours_provided = false
    }
    
    return !errorOccured
}


func fillLocationWithGoogleData(location:Location, data: [String:Any]) -> Bool {
    
    let errorOccured = false
    
    //set single properties through manual call
    if let name = data["name"] as? String {
        location.google_name = name
    }
    if let fa = data["formatted_address"] as? String {
        location.google_formattedAddress = fa
    }
    if let vic = data["vicinity"] as? String {
        location.google_vicinity = vic
    }
    if let ph = data["formatted_phone_number"] as? String {
        location.google_formattedphoneNumber = ph
    }
    
    if let iph = data["international_phone_number"] as? String {
        location.google_international_phone_number = iph
    }
    
    if let ggurl = data["url"] as? String {
        location.google_google_url = ggurl
    }
    
    if let website = data["website"] as? String {
        location.google_website = website
    }
    
    if let photos = data["photos"] as? [Any] {
        location.google_photos = photos
    }
    //don't know which data type is used here
    if let pl = data["price_level"] as? Int {
        location.google_price_level = pl
    }
    
    if let rating = data["rating"] as? Double {
        location.google_rating = rating
    }
    
    if let reviews = data["reviews"] as? [Any] {
        location.google_reviews = reviews
    }
    
    //set multiple properties through functions
    if let geometry = data["geometry"] as? [String:Any] {
        location.google_setLongituteAndLatitude(data: geometry)
    }
    
    if let oh = data["opening_hours"] as? [String:Any] {
        location.google_openingHours_provided = true
        location.google_setOpeningHours(data: oh)
    }
    else {
        print("No opening hours provided for club \(location.nightlive_display_name)")
        location.google_openingHours_provided = false
    }
    
    if let addresscomponents = data["address_components"] as? [[String:Any]] {
        location.google_setAddressComponents(data: addresscomponents)
    }
    
    return !errorOccured
}

//MARK: - Vouchers
var allVouchers = [Any]()

//MARK: - User Favorites

var isAuthenticatedUser = false
var userObjectID = ""
var allFavoriteLocations = [String]()
var allFavoriteEvents = [String]()

func requestFavoriteLocationsForUser() {
    
    let tableName = "Favorite_locations_user"
    allFavoriteLocations.removeAll() 
    
    let query = PFQuery(className: tableName)
    query.selectKeys(["facebook_google_ID"])
    query.whereKey("user_id", equalTo: userObjectID)
    query.findObjectsInBackground { (results, error) in
        if error != nil || results == nil {
            //Error
            print("Error CallBack Favorite Locations")
        }
        else {
            //Success
            print("Success CallBack Favorite Locations")
            var successCounter = 0
            for item in results! {
                if let id = item["facebook_google_ID"] as? String {
                    allFavoriteLocations.append(id)
                    print("appending favorite id: \(id)")
                    successCounter += 1
                }
            }
            if successCounter == results?.count {
                print("Success - all Favorite Locations loaded")
                //WHAT IF THIS COMES BACK LATER THAN THE ACTUAL TABLE WITH THE LOCATIONS???
                //UPDATED THE TABLE THEN??? but first check if allBars allClubs have values and stuff
            }
            else {
                print("Error - Not all Favorite Locations loaded")
            }
            
        }
    }
    
    

}


func requestFavoriteEventsForUser() {
    
    let tableName = "Favorite_event_user"
    
    let query = PFQuery(className: tableName)
    query.selectKeys(["facebook_event_id"])
    query.whereKey("user_id", equalTo: userObjectID)
    query.findObjectsInBackground { (results, error) in
        if error != nil || results == nil {
            //Error
            print("Error CallBack Favorite Events")
        }
        else {
            //Success
            print("Success CallBack Favorite Events")
            allFavoriteEvents.removeAll()
            var successCounter = 0
            for item in results! {
                if let eventID = item["facebook_event_id"] as? String {
                    allFavoriteEvents.append(eventID)
                    print("appending favorite facebook_event_id: \(eventID)")
                    successCounter += 1
                }
            }
            if successCounter == results?.count {
                print("Success - all Favorite Events loaded")
            }
            else {
                print("Error - Not all Favorite Events loaded")
            }
            
        }
    }
    
}

//MARK: - Parse
func logoutUser() {
    PFUser.logOutInBackground { (error) in
        if error != nil {
            print("Logout Error")
            print(error ?? "Error coulnd't be printed")
            instance_landingPageVC?.logoutError()
        }
        else {
            print("Logout Success")
            instance_landingPageVC?.logoutSuccess()
        }
    }
}

func getUserID() -> String {
    var userID = ""
    if let currentUser = PFUser.current() {
        userID = currentUser.objectId!
        print("Authenticated user with ID: \(userID)")
    }
    else {
        print("No Authenticated User!")
    }
    return userID
}

func handleUserFavoriteEvent(userID: String, facebookEventID: String, toAdd: Bool, endTime: String?) {
    let className = "Favorite_event_user"
    if toAdd {
        let object = PFObject(className: className)
        object["user_id"] = userID
        object["facebook_event_id"] = facebookEventID
        object["event_endtime"] = endTime
        if endTime == nil {
            //Error covered: Can't use nil for keys or values on PFObject. Use NSNull for values.
            object["event_endtime"] = NSNull()
        }
        object.saveInBackground(block: { (isSaved, error) in
            if error != nil || !isSaved {
                print("Error occured during favorite event saving")
                print(error ?? "Error...")
            }
            else {
                print("Successfully saved favorite event")
                requestFavoriteEventsForUser()
            }
        })
    }
    else {
        let query = PFQuery(className: className)
        query.whereKey("user_id", equalTo: userID)
        query.whereKey("facebook_event_id", equalTo: facebookEventID)
        query.findObjectsInBackground(block: { (object, error) in
            if error != nil || object == nil {
                print("Error in getting favorite Event")
            }
            else {
                object?.first?.deleteInBackground(block: { (isDeleted, error) in
                    if error != nil || !isDeleted {
                        print("Error occured during favorite event deletion")
                        print(error ?? "Error...")
                    }
                    else {
                        print("Successfully deleted favorite event")
                        requestFavoriteEventsForUser()
                    }
                })
            }
        })
        
    }
}

func handleUserFavoriteLocation(userID: String, id: String, toAdd: Bool) {
    let className = "Favorite_locations_user"
    if toAdd {
        let object = PFObject(className: className)
        object["user_id"] = userID
        object["facebook_google_ID"] = id
        object.saveInBackground(block: { (isSaved, error) in
            if error != nil || !isSaved {
                print("Error occured during favorite location saving")
                print(error ?? "Error...")
            }
            else {
                print("Successfully saved favorite location")
                requestFavoriteLocationsForUser()
            }
        })
    }
    else {
        let query = PFQuery(className: className)
        query.whereKey("user_id", equalTo: userID)
        query.whereKey("facebook_google_ID", equalTo: id)
        query.findObjectsInBackground(block: { (object, error) in
            if error != nil || object == nil {
                print("Error in getting favorite Location")
            }
            else {
                print(object?.count)
                object?.first?.deleteInBackground(block: { (isDeleted, error) in
                    if error != nil || !isDeleted {
                        print("Error occured during favorite location deletion")
                        print(error ?? "Error...")
                    }
                    else {
                        print("Successfully deleted location event")
                        requestFavoriteLocationsForUser()
                    }
                })
            }
        })
        
    }
}

//MARK: - Additionals
//Additional Helper Function
func getFacebookAccessTokenString() -> String {
    let token = "\(facebookAppID)|\(facebookAppSecret)"
    return token
}












