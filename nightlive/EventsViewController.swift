//
//  EventsViewController.swift
//  nightlive
//
//  Created by Hannes Schaletzky on 27/01/2017.
//  Copyright © 2017 Hannes Schaletzky. All rights reserved.
//

import Foundation

class EventsViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isRetrievingItems = true
    var filterSet = false
    var amountOfFiltersSet = 0
    fileprivate var event = Event(nightlive_facebook_id: "", nightlive_club_visible: false) //only dummy
    fileprivate var arrayIsSorted = false
    
    fileprivate var isFirstLoad = false
    
    //PullToRefresh
    var refresher: UIRefreshControl!
    
    //GRADIENT
    var gradientLayer: CAGradientLayer!
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("eventsVC viewDidLoad")
        
        isFirstLoad = true
        
        //save this instance to Model
        instance_eventsVC = self
        
        //PullToRefresh
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "")
        refresher.addTarget(self, action: #selector(EventsViewController.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        //because it's the first to load, set
        global_activeController = self
        
        //foldingCell
        createCellHeightsArray()
    }
    
    //this is to cover the case when user tapped on a item in the TabBar
    override func viewDidAppear(_ animated: Bool) {
        instance_landingPageVC?.adjustViewToTabBarSelection(newController: self)
    }
    
    //MARK: - Logic
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Events")
    }
    
    func fetchEvents() {
        activityIndicator.startAnimating()
        isRetrievingItems = true
        instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 2, enable: false)
        //Animation
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.alpha = 0
        }) { (finished) in
            self.tableView.isHidden = false
        }
        
        startFetchingFacebookEvents()
    }
    
    func refresh() {
        isRetrievingItems = true
        instance_landingPageVC?.changeEnableStateForButtonWithTag(tag: 2, enable: false)
        startFetchingFacebookEvents()
    }
    
    func sortArrayAccordingToFavorintes() {
        //check if in Favorites and put at top of the list
        if !allFavoriteEvents.isEmpty {
            for (index,event) in allFBEvents.enumerated() {
                if isEventInFavoriteEvents(eventID: event.nightlive_facebook_id) {
                    allFBEvents.remove(at: index)
                    allFBEvents.insert(event, at: 0) //at first Place
                }
            }
        }
    }
    
    
    //MARK: - User Interaction
    @IBAction func eventClubButtonPressed(_ sender: UIButton) {
        if let clubName = sender.titleLabel?.text {
            print("selected \(clubName)")
            //jump to clubs and select club
            global_clubsFilterSet = true 
            global_filteredClub = clubName
            instance_clubsVC?.filterBy(name: clubName, open: "noFilter", happyHour: "noFilter")
            instance_pagerVC?.moveToViewController(at: 2)
        }
        
        
    }
    
    @IBAction func favoriteButtonPressed(_ sender: DOFavoriteButton) {
        
        //get EventFacebookID via Cell
        let tag = sender.tag
        let indexPathOfRow = IndexPath(row: tag, section: 0)
        let cell = tableView.cellForRow(at: indexPathOfRow) as! EventsCell
        let event = cell.event
        let eventFacebookID = event.nightlive_facebook_id
        let endTime = event.facebook_end_time
        
        //get UserID
        let userID = getUserID()
        
        if sender.isSelected {
            // deselect
            //sender.deselect()
            handleUserFavoriteEvent(userID: userID, facebookEventID: eventFacebookID, toAdd: false, endTime: endTime)
            cell.favoriteButton.deselect()
            cell.inner_favoriteButton.deselect()
        } else {
            // select with animation
            //sender.select()
            handleUserFavoriteEvent(userID: userID, facebookEventID: eventFacebookID, toAdd: true, endTime: endTime)
            cell.favoriteButton.select()
            cell.inner_favoriteButton.select()
        }
    }
    
    //MARK: - Filter
    
    func removeAllFilters() {
        amountOfFiltersSet = 0
        displayAllEvents(fromRemoveAllFilter: true)
    }
    
    //                              att,int,noFilter
    func filterBy(name: String, sortAscending: String) {
        
        allFBEvents_filtered.removeAll()
        var newEvents = [Event]()
        newEvents.removeAll()
        
        let filterGroup = 0 
        while true {
            
            //NAME
            if name != "noFilter" {
                var hasMatch = false
                for event in allFBEvents {
                    if let eventName = event.facebook_name {
                        if eventName == name {
                            hasMatch = true
                            allFBEvents_filtered.append(event)
                            break
                        }
                    }
                }
                if hasMatch {
                    //this is to stop the while loop
                    break
                }
                
            }
            
            //TYPE
            if filterGroup == 0 {
                if sortAscending == "att" {
                    newEvents = sortArray(eventscopy: allFBEvents, isAttending: true)
                }
                else if sortAscending == "int" {
                    newEvents = sortArray(eventscopy: allFBEvents, isAttending: false)
                }
                else {
                    newEvents = allFBEvents
                }
                
                //finished
                allFBEvents_filtered = newEvents
                break
            }
            
            
        }
         
        if name == "noFilter" && sortAscending == "noFilter" {
            filterSet = false
            instance_landingPageVC?.setFilterButtonStateTo(filterSet: false)
        }
        else {
            filterSet = true
            instance_landingPageVC?.setFilterButtonStateTo(filterSet: true)
        }
        
        displayFilteredEvents()
        
    }

    
    
    fileprivate func sortArray(eventscopy: [Event], isAttending: Bool) -> [Event] {
        
        var sortedArray = [Event]()
        sortedArray.removeAll()
        
        for event in eventscopy {
            if sortedArray.isEmpty {
                //only first step
                sortedArray.append(event)
            }
            else {
                var count = event.facebook_interested_count!
                if isAttending {
                    count = event.facebook_attending_count!
                }
                for (index,sortedEvent) in sortedArray.enumerated() {
                    var compareCount = sortedEvent.facebook_interested_count!
                    if isAttending {
                        compareCount = sortedEvent.facebook_attending_count!
                    }
                    if count >= compareCount {
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
                            var nextPositionCount = sortedArray[index+1].facebook_interested_count!
                            if isAttending {
                                nextPositionCount = sortedArray[index+1].facebook_attending_count!
                            }
                            if count < compareCount && count >= nextPositionCount {
                                //insert at specific position
                                sortedArray.insert(event, at: index+1)
                                break
                            }
                        }
                    }
                }
            }
        }
        return sortedArray
    }
    
    //MARK: - UI
    
    func displayFilteredEvents() {
        showTableView()
    }
    
    func displayAllEvents(fromRemoveAllFilter: Bool) {
        isRetrievingItems = false
        filterSet = false
        arrayIsSorted = false //filter sorted, not favorite
        sortArrayAccordingToFavorintes() //now sort according favorites
        if !allFBEvents.isEmpty {
            DispatchQueue.main.async { [unowned self] in
                if global_activeController == instance_eventsVC {
                    //this if covers, when user immediatly goes on the maps, so that then the filter button is not activated globally
                    instance_landingPageVC?.setFilterButtonStateTo(filterSet: false)
                }
                instance_landingPageVC?.setAllFilterToNoneFromFilterView(vc: self)
                if !fromRemoveAllFilter {
                    if global_activeController == instance_eventsVC {
                        instance_landingPageVC?.enableButtons()
                    }
                }
            }
            refresher.endRefreshing()
            instance_landingPageVC?.showCorrectFilterScrollView(newController: self)
            showTableView()
        }
        else {
            print("allEvents is empty")
            activityIndicator.stopAnimating()
            instance_landingPageVC?.enableDisableCorrectButtons()
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
    
    
    //MARK: - Table View
    
    let kCloseCellHeight: CGFloat = 148
    let kOpenCellHeight: CGFloat = 382
    
    let kRowsCount = 100
    
    var cellHeights = [CGFloat]()
    
    func createCellHeightsArray() {
        for _ in 0...kRowsCount {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    //MARK: Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterSet {
            return allFBEvents_filtered.count
        }
        else if !allFBEvents.isEmpty {
            return allFBEvents.count
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard case let cell as EventsCell = cell else {
            return
        }
        
        cell.backgroundColor = UIColor.clear
        
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        
        
        if (!allFBEvents.isEmpty && !filterSet) || (!allFBEvents_filtered.isEmpty && filterSet) {
            
            if filterSet {
                event = allFBEvents_filtered[indexPath.row]
            }
            else {
                event = allFBEvents[indexPath.row]
            }
            cell.event = event
            
            
            //GRADIENT
            //Gradient
            gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor.black.cgColor, UIColor.darkGray.cgColor, UIColor.lightGray.cgColor]
            gradientLayer.locations = [0.0, 2.5]
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
            gradientLayer.opacity = 1
            gradientLayer.isOpaque = false
            gradientLayer.frame = cell.foregroundView.bounds
            cell.foregroundView.layer.insertSublayer(gradientLayer, below: cell.eventNameLabel.layer)
            
            //NAME AND CLUB
            cell.eventNameLabel.text = event.facebook_name
            cell.inner_eventNameLabel.text = event.facebook_name //InnerCell
            cell.eventClubButton.setTitle(event.nightlive_club_display_name, for: UIControlState.normal)
            cell.inner_eventClubButton.setTitle(event.nightlive_club_display_name, for: UIControlState.normal) //InnerCell
            
            if event.nightlive_club_googlePlaceID == nil {
                //is not a real club
                //SET ATTRITBUTES OF TITLE HERE and not clickable
            }
            else {
                //set attributes back so buttons are clickable for other resuable cells
            }
            
            //TIME
            var start = ""
            var end = ""
            if let innerStartTime = event.facebook_start_time {
                if let innerEndTime = event.facebook_end_time {
                    start = getHourAndMinuteAsStringFromStringDate(dateString: innerStartTime)
                    end = getHourAndMinuteAsStringFromStringDate(dateString: innerEndTime)
                }
                else {
                    end = "-"
                }
            }
            else {
                start = "-"
            }
            cell.atTimeLabel.text = "\(start) - \(end)"
            cell.inner_atTimeLabel.text = "\(start) - \(end)"
            
            //INT, ATT COUNT -------- BUG!
            var count = ""
            if let iCount = event.facebook_interested_count {
                count = "\(iCount)"
            }
            else {
                count = "-"
            }
            cell.interestedLabel.text = count
            cell.inner_interestedLabel.text = count //innerCell
            
            if let aCount = event.facebook_attending_count {
                count =  "\(aCount)"
            }
            else {
                count =  "-"
            }
            cell.attendingLabel.text =  count
            cell.inner_attendingLabel.text =  count //innerCell
            
            //FAVORITE BUTTON
            cell.favoriteButton.tag = indexPath.row //so we can track the cell in which was pressed
            cell.inner_favoriteButton.tag = indexPath.row
            if isEventInFavoriteEvents(eventID: cell.event.nightlive_facebook_id) {
                //cell.favoriteButton.select()
                //cell.inner_favoriteButton.select()
                cell.favoriteButton.selectWithoutAnimation()
                cell.inner_favoriteButton.selectWithoutAnimation()
            }
            else {
                cell.favoriteButton.deselect()
                cell.inner_favoriteButton.deselect()
            }
            
            //DESCRIPTION
            if let description = event.facebook_description {
                cell.inner_event_description.text = ""
                cell.inner_event_description.insertText(description)
                cell.inner_event_description.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
            }
        }
        

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventsCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    //MARK: Table vie delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            // open cell
            cellHeights[(indexPath as NSIndexPath).row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            // close cell
            cellHeights[(indexPath as NSIndexPath).row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
        
    }

    
    
    
    
    
    
}
