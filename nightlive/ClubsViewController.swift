//
//  ClubsViewController.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 27/01/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import Foundation

class ClubsViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isRetrievingItems = true
    var filterSet = false
    var amountOfFiltersSet = 0
    fileprivate var club = Club(nightlive_display_name: "") //only dummy
    
    //PullToRefresh
    var refresher: UIRefreshControl!
    
    //GRADIENT
    var gradientLayer: CAGradientLayer!
    
    
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("clubsVC viewDidLoad")
        instance_clubsVC = self
        
        createCellHeightsArray()
        
        //PullToRefresh
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "")
        refresher.addTarget(self, action: #selector(ClubsViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        //Check if clubs are already loaded, if not show activity Indicator
        if allClubs.isEmpty {
            activityIndicator.startAnimating()
            isRetrievingItems = true
            instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 2, enable: false)
        }
        else {
            if global_clubsFilterSet {
                //only for first click
                filterBy(name: global_filteredClub, open: "noFilter", happyHour: "noFilter")
                isRetrievingItems = false
            }
            else {
                displayAllClubs()
            }
        }
        
    }
    
    //this is to cover the case when user tapped on a item in the TabBar
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear Clubs")
        instance_landingPageVC?.adjustViewToTabBarSelection(newController: self)
        
        sortArrayAccordingToFavorintes()
        
    }
    
    //MARK: - Logic
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Clubs")
    }
    
    func refresh() {
        instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 2, enable: false)
        isRetrievingItems = true
        setDateVariablesForHappyHourAndOpeningHourToCurrent()
        retrievePlaceIDsFromNightliveFor(isRequestForClubs: true)
    }
    
    func sortArrayAccordingToFavorintes() {
        //check if in Favorites and put at top of the list
        if !allFavoriteLocations.isEmpty {
            for (index,club) in allClubs.enumerated() {
                if isLocationInFavoriteLocations(locationGooglePlacesID: club.nightlive_googlePlacesID, locationFacebookID: club.nightlive_facebookID) {
                    allClubs.remove(at: index)
                    allClubs.insert(club, at: 0) //at first Place
                }
            }
        }
    }
    
    func sortUpcomingEvents(events: [Event]) -> [Event] {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        for event in events {
            let startTime = event.facebook_start_time!
            let year = startTime.substring(with: 0..<4)
            let month = startTime.substring(with: 5..<7)
            let day = startTime.substring(with: 8..<10)
            let dayMonthYearString = "\(day).\(month).\(year)"
            let startDate = formatter.date(from: dayMonthYearString)!
            event.compareDateStartTime = startDate
        }
        
        var sortedArray = [Event]()
        sortedArray.removeAll()
        
        for event in events {
            if sortedArray.isEmpty {
                //only first step
                sortedArray.append(event)
            }
            else {
                let date = event.compareDateStartTime
                for (index,sortedEvent) in sortedArray.enumerated() {
                    let compareDate = sortedEvent.compareDateStartTime!
                    if date?.compare(compareDate) == ComparisonResult.orderedDescending {
                        sortedArray.insert(event, at: index)
                        break
                    }
                    else {
                        let sortedArrayMaxIndex = sortedArray.count-1
                        if index == sortedArrayMaxIndex {
                            //last position, so insert
                            sortedArray.append(event)
                            break
                        }
                        else {
                            let nextPositionDate = sortedArray[index+1].compareDateStartTime!
                            if date?.compare(compareDate) == ComparisonResult.orderedAscending && date?.compare(nextPositionDate) == ComparisonResult.orderedDescending {
                                //insert at specific position
                                sortedArray.insert(event, at: index+1)
                                break
                            }
                        }
                    }
                }
            }
        }
        
        sortedArray.reverse()
        
        return sortedArray
        
    }

    
    //MARK: - User Interaction
    @IBAction func favoriteButtonPressed(_ sender: DOFavoriteButton) {
        
        //get EventFacebookID via Cell
        let tag = sender.tag
        let indexPathOfRow = IndexPath(row: tag, section: 0)
        let cell = tableView.cellForRow(at: indexPathOfRow) as! ClubCell
        let club = cell.club
        var id = ""
        if let clubGooglePlacesID = club.nightlive_googlePlacesID {
            id = clubGooglePlacesID
        }
        if id.isEmpty {
            if let clubFacebookID = club.nightlive_facebookID {
                id = clubFacebookID
            }
        }
        
        //get UserID
        let userID = getUserID()
        
        if sender.isSelected {
            // deselect
            handleUserFavoriteLocation(userID: userID, id: id, toAdd: false)
            cell.outer_FavoriteButton.deselect()
            cell.inner_FavoriteButton.deselect()
        } else {
            // select with animation
            handleUserFavoriteLocation(userID: userID, id: id, toAdd: true)
            cell.outer_FavoriteButton.select()
            cell.inner_FavoriteButton.select()
        }
    }
    
    @IBAction func closeCellButtonPressed(_ sender: UIButton) {
        //CloseCell
        //first scroll to Top of Cell
        let tag = sender.tag
        let indexPathOfRow = IndexPath(row: tag, section: 0)
        let cellNow = tableView.cellForRow(at: indexPathOfRow) as! FoldingCell
        let frame = cellNow.frame
        let rect = CGRect(x: (frame.minX), y: (frame.minY), width: 1, height: 1)
        tableView.scrollRectToVisible(rect, animated: true)
        //--
        cellHeights[(indexPathOfRow as NSIndexPath).row] = kCloseCellHeight
        cellNow.selectedAnimation(false, animated: true, completion: nil)
        let duration = 0.8
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }, completion: nil)
    }
    
    //MARK: - Filter
    func removeAllFilters() {
        filterSet = false
        displayAllClubs()
    }
    
    //            today,now,noFilter    today,now,noFilter
    func filterBy(name: String, open: String, happyHour: String) {
        
        allClubs_Filtered.removeAll()
        var newClubs = [Club]()
        newClubs.removeAll()
        
        var filterGroup = 0
        while true {
            
            //NAME
            if name != "noFilter" {
                var hasMatch = false
                for club in allClubs {
                    if club.nightlive_display_name == name {
                        hasMatch = true
                        allClubs_Filtered.append(club)
                        break
                    }
                }
                if hasMatch {
                    //this is to stop the while loop
                    break
                }
            }
            
            //OPEN
            if filterGroup == 0 {
                for location in allClubs {
                    if open == "today" {
                        if isLocationOpen(location: location, isNow: false) {
                            newClubs.append(location)
                        }
                        else if isLocationOpen(location: location, isNow: true) {
                            newClubs.append(location)
                        }
                    }
                    else if open == "now" {
                        if isLocationOpen(location: location, isNow: true) {
                            newClubs.append(location)
                        }
                    }
                    else {
                        newClubs.append(location)
                    }
                    
                    
                }
                //go to next Filtergroup
                allClubs_Filtered = newClubs
                newClubs.removeAll()
                filterGroup += 1
                continue
            }
            
            //HAPPYHOUR
            if filterGroup == 1 {
                for location in allClubs_Filtered {
                    if happyHour == "today" {
                        if isLocationInHappyHour(location: location, isNow: false) {
                            newClubs.append(location)
                        }
                        else if isLocationInHappyHour(location: location, isNow: true) {
                            newClubs.append(location)
                        }
                    }
                    else if happyHour == "now" {
                        if isLocationInHappyHour(location: location, isNow: true) {
                            newClubs.append(location)
                        }
                    }
                    else {
                        newClubs.append(location)
                    }
                    
                    
                }
                //finished
                allClubs_Filtered = newClubs 
                break
            }

            
            
        }
        
        if name == "noFilter" && open == "noFilter" && happyHour == "noFilter" {
            displayAllClubs()
        }
        else {
            filterSet = true
            instance_landingPageVC?.setFilterButtonStateTo(filterSet: true)
            showTableView()
        }
        
    }
    
    
    
    //MARK: - UI
    func displayUpcomingEventsForCell() {
        tableView.reloadData()
    }
    
    func displayAllClubs() {
        isRetrievingItems = false
        filterSet = false
        global_clubsFilterSet = false
        global_filteredClub = ""
        
        if !allClubs.isEmpty {
            DispatchQueue.main.async { [unowned self] in
                //put UI back on the main queue... otherwise it will apply changes after a couple of seconds
                instance_landingPageVC?.setFilterButtonStateTo(filterSet: false)
                instance_landingPageVC?.setAllFilterToNoneFromFilterView(vc: self)
                instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 2, enable: true)
            }
            sortArrayAccordingToFavorintes()
            refresher.endRefreshing()
            showTableView()
        }
        else {
            print("allClubs is empty")
            activityIndicator.stopAnimating()
        }
    }

    private func showTableView() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            //Animation
            self.tableView.alpha = 0
            self.tableView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.self.tableView.alpha = 1
            }
        })
    }
    
    func setHiddenOfOpeningHoursOfCellTo(hidden: Bool, cell: ClubCell) {
        cell.inner_openinghoursMondayLabel.isHidden = hidden
        cell.inner_openinghoursTuesdayLabel.isHidden = hidden
        cell.inner_openinghoursWednesdayLabel.isHidden = hidden
        cell.inner_openinghoursThursdayLabel.isHidden = hidden
        cell.inner_openinghoursFridayLabel.isHidden = hidden
        cell.inner_openinghoursSaturdayLabel.isHidden = hidden
        cell.inner_openinghoursSundayLabel.isHidden = hidden
        
        cell.inner_openingHoursMondayDayLabel.isHidden = hidden
        cell.inner_openingHoursTuesdayDayLabel.isHidden = hidden
        cell.inner_openingHoursWednesdayDayLabel.isHidden = hidden
        cell.inner_openingHoursThursdayDayLabel.isHidden = hidden
        cell.inner_openingHoursFridayDayLabel.isHidden = hidden
        cell.inner_openingHoursSaturdayDayLabel.isHidden = hidden
        cell.inner_openingHoursSundayDayLabel.isHidden = hidden
        
        cell.noOpeningHoursProvidedLabel.isHidden = !hidden
    }
    
    func setHiddenOfHappyHoursOfCellTo(hidden: Bool, cell: ClubCell) {
        cell.inner_happyHourMondayLabel.isHidden = hidden
        cell.inner_happyHourTuesdayLabel.isHidden = hidden
        cell.inner_happyHourWednesdayLabel.isHidden = hidden
        cell.inner_happyHourThursdayLabel.isHidden = hidden
        cell.inner_happyHourFridayLabel.isHidden = hidden
        cell.inner_happyHourSaturdayLabel.isHidden = hidden
        cell.inner_happyHourSundayLabel.isHidden = hidden
        
        cell.inner_happyHourMondayDayLabel.isHidden = hidden
        cell.inner_happyHourTuesdayDayLabel.isHidden = hidden
        cell.inner_happyHourWednesdayDayLabel.isHidden = hidden
        cell.inner_happyHourThursdayDayLabel.isHidden = hidden
        cell.inner_happyHourFridayDayLabel.isHidden = hidden
        cell.inner_happyHourSaturdayDayLabel.isHidden = hidden
        cell.inner_happyHourSundayDayLabel.isHidden = hidden
        
        cell.noHappyHoursProvidedLabel.isHidden = !hidden
    }
    
    func setViewToWorkingState() {
        tableView.isHidden = true
        self.tableView.alpha = 0
        activityIndicator.startAnimating()
    }
    
    //MARK: - Table View
    
    let kCloseCellHeight: CGFloat = 170
    let kOpenCellHeight: CGFloat = 970
    
    let kRowsCount = 100
    
    var cellHeights = [CGFloat]()
    
    // MARK: configure
    func createCellHeightsArray() {
        for _ in 0...kRowsCount {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterSet {
            return allClubs_Filtered.count
        }
        else if !allClubs.isEmpty {
            return allClubs.count
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard case let cell as ClubCell = cell else {
            return
        }
        
        cell.backgroundColor = UIColor.clear
        
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        
        //Display Items
        //CHECK IF IS EMPTY
        if (!allClubs.isEmpty && !filterSet) || (!allClubs_Filtered.isEmpty && filterSet) {
            
            if filterSet {
                club = allClubs_Filtered[indexPath.row]
            }
            else {
                club = allClubs[indexPath.row]
            }
            cell.club = club
            
            //GRADIENT
            gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.black.cgColor, UIColor.wgwDarkBlueClubCell().cgColor, UIColor.white.cgColor]
            gradientLayer.locations = [0.0, 2.5]
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
            gradientLayer.opacity = 1
            gradientLayer.isOpaque = false
            gradientLayer.frame = cell.foregroundView.bounds
            cell.foregroundView.layer.insertSublayer(gradientLayer, below: cell.outer_clubNameLabel.layer)
            
            
            //FAVORITE BUTTON
            //so we can track the cell in which was pressed
            let row = indexPath.row
            cell.outer_FavoriteButton.tag = row
            cell.inner_FavoriteButton.tag = row
            cell.inner_closeButton.tag = row
            
            //check if club has google Place ID 
            if club.nightlive_googlePlacesID != nil {
            
                //outerCell
                cell.outer_clubNameLabel.text = club.nightlive_display_name
                cell.inner_clubNameLabel.text = club.nightlive_display_name //innerCell
                //OPENNOW
                if let openNow = club.google_open_now {
                    if openNow {
                        cell.outer_openImgView.image = UIImage(named: "Attending")
                        cell.inner_openImgView.image = UIImage(named: "Attending") //innerCell
                    }
                    else {
                        cell.outer_openImgView.image = UIImage(named: "Minus")
                        cell.inner_openImgView.image = UIImage(named: "Minus") //innerCell
                    }
                }
                else {
                    //open now status not provided
                    cell.outer_openImgView.image = UIImage(named: "Image") //nothing aka blank aka empty
                    cell.inner_openImgView.image = UIImage(named: "Image") //innerCell
                }
                
                //FAVORITE
                if isLocationInFavoriteLocations(locationGooglePlacesID: club.nightlive_googlePlacesID, locationFacebookID: club.nightlive_facebookID) {
                    cell.outer_FavoriteButton.selectWithoutAnimation()
                    cell.inner_FavoriteButton.selectWithoutAnimation()
                }
                else {
                    cell.outer_FavoriteButton.deselect()
                    cell.inner_FavoriteButton.deselect()
                }
                
                //HAPPYHOUR
                var happyHour = "-"
                let result = isLocationCurrentlyInHappyHour(location: cell.club)
                if  result.0 {
                    happyHour = ("Bis: \(result.1)")
                }
                else {
                    happyHour = getNextHappyHourOf(location: cell.club)
                }
                cell.outer_happyHourLabel.text = "\(happyHour)"
                cell.inner_happyHourLabel.text = "\(happyHour)" //innerCell

                
                //innercell
                
                //ADDRESS
                if let street = club.google_address_street {
                    if let number = club.google_address_number {
                        if let zip = club.google_address_zip {
                            if let city = club.google_address_city {
                                cell.inner_addressTextView.text = "\(street) \(number), \(zip) \(city)"
                                //cell.inner_addressTextView.sizeToFit()
                            }
                        }
                    }
                }
                
                //TELEPHONE
                if let number = club.google_international_phone_number {
                    cell.inner_telephoneTextView.text = number
                    //cell.inner_telephoneTextView.sizeToFit()
                }
                
                //WEBSITE
                if let site = club.google_website {
                    cell.inner_websiteTextView.text = site
                    //cell.inner_websiteTextView.sizeToFit()
                }
                
                //DESCRIPTION
                if let description = club.nightlive_detailed_description {
                    cell.inner_descriptionTextView.text = description
                }
                else {
                    cell.inner_descriptionTextView.text = "No Description provided"
                }
                
                //NEXT EVENTS
                if !club.upcomingEvents.isEmpty {
                    club.upcomingEvents = sortUpcomingEvents(events: club.upcomingEvents)
                    var nextEventsString = ""
                    for event in club.upcomingEvents {
                        let startTime = event.facebook_start_time!
                        let year = startTime.substring(with: 0..<4)
                        let month = startTime.substring(with: 5..<7)
                        let day = startTime.substring(with: 8..<10)
                        let dayMonthYearString = "\(day).\(month).\(year)"
                        nextEventsString += dayMonthYearString
                        nextEventsString += "\n"
                        nextEventsString += "\(event.facebook_name!)"
                        nextEventsString += "\n"
                        nextEventsString += "I: \(event.facebook_interested_count!) - Z: \(event.facebook_attending_count!)"
                        nextEventsString += "\n"
                        nextEventsString += "\n"
                    }
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        cell.inner_nextEventsTextView.text = nextEventsString
                        cell.inner_nextEventsActivityIndicator.stopAnimating()
                        cell.inner_nextEventsTextView.isHidden = false
                        cell.inner_nextEventsTextView.flashScrollIndicators()
                        cell.inner_nextEventsTextView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                    })
                    
                    
                    
                }
                else {
                    cell.inner_nextEventsTextView.text = "No next events"
                }
                
                //OPENING HOURS
                if club.google_openingHours_provided {
                    setHiddenOfOpeningHoursOfCellTo(hidden: false, cell: cell)
                    cell.inner_openinghoursMondayLabel.text = club.getOpeningHourStringForWeekday(weekday: 2) //Monday
                    cell.inner_openinghoursTuesdayLabel.text = club.getOpeningHourStringForWeekday(weekday: 3)
                    cell.inner_openinghoursWednesdayLabel.text = club.getOpeningHourStringForWeekday(weekday: 4)
                    cell.inner_openinghoursThursdayLabel.text = club.getOpeningHourStringForWeekday(weekday: 5)
                    cell.inner_openinghoursFridayLabel.text = club.getOpeningHourStringForWeekday(weekday: 6)
                    cell.inner_openinghoursSaturdayLabel.text = club.getOpeningHourStringForWeekday(weekday: 7)
                    cell.inner_openinghoursSundayLabel.text = club.getOpeningHourStringForWeekday(weekday: 1) //Sunday
                }
                else {
                    setHiddenOfOpeningHoursOfCellTo(hidden: true, cell: cell)
                }
                
                //HAPPY HOURS
                if club.nightlive_happyHours_provided {
                    setHiddenOfHappyHoursOfCellTo(hidden: false, cell: cell)
                    cell.inner_happyHourMondayLabel.text = club.getHappyHourForWeekday(weekday: 2) //Monday
                    cell.inner_happyHourTuesdayLabel.text = club.getHappyHourForWeekday(weekday: 3)
                    cell.inner_happyHourWednesdayLabel.text = club.getHappyHourForWeekday(weekday: 4)
                    cell.inner_happyHourThursdayLabel.text = club.getHappyHourForWeekday(weekday: 5)
                    cell.inner_happyHourFridayLabel.text = club.getHappyHourForWeekday(weekday: 6)
                    cell.inner_happyHourSaturdayLabel.text = club.getHappyHourForWeekday(weekday: 7)
                    cell.inner_happyHourSundayLabel.text = club.getHappyHourForWeekday(weekday: 1) //Sunday
                }
                else {
                    setHiddenOfHappyHoursOfCellTo(hidden: true, cell: cell)
                }
                
            }
            else {
                print("Unfortunetely has \(cell.club.nightlive_display_name) no data from google available")
                //show this to user somehow
            }
            
            
            
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClubCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            // open cell
            
            //fetch upcoming Events for Cell
            let cell = tableView.cellForRow(at: indexPath) as! ClubCell
            let club = cell.club
            if let facebookID = club.nightlive_facebookID {
                let notificationString = "\(facebookID)/\(indexPath)"
                nsNC.addObserver(self, selector: #selector(ClubsViewController.displayUpcomingEventsForCell), name:NSNotification.Name(rawValue: notificationString), object: nil)
                cell.inner_nextEventsActivityIndicator.startAnimating()
                cell.inner_nextEventsTextView.isHidden = true
                retrieveNextEventsForClub(club:  club, clubFacebookID: facebookID, notificationString: notificationString)
            }
            
            cellHeights[(indexPath as NSIndexPath).row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            
            //closing is handled by button at the end of cell
            
            // close cell
            /* 
            //first scroll to Top of Cell
            let cellNow = tableView.cellForRow(at: indexPath)
            let frame = cellNow?.frame
            let rect = CGRect(x: (frame?.minX)!, y: (frame?.minY)!, width: 1, height: 1)
            tableView.scrollRectToVisible(rect, animated: true)
            //--
            cellHeights[(indexPath as NSIndexPath).row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
             */
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
        
    }

    
    
    
    
    
}
