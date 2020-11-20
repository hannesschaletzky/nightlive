//
//  DayTracking.swift
//  wasgehtwo
//
//  Created by Hannes Schaletzky on 22/06/16.
//  Copyright © 2016 Hannes Schaletzky. All rights reserved.
//

import Foundation

private var dateFormatter = DateFormatter()
let oneDayInSeconds = Double(1*24*60*60)

func getDateNowUnderConsiderationOfTimeZone() -> Date {
    var today = Date()
    let timeZone = TimeZone.current.abbreviation()
    if timeZone == "GMT+2" {
        today = today.addingTimeInterval(60*60*2)
    }
    return today
}

func getHourAndMinuteAsStringFromStringDate(dateString: String) -> String {
    //                         "2017-03-31T22:00:00+0200"
    /*dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
    let date = dateFormatter.date(from: dateString)
    let comp = getComponentsOfDate(date!)
    return "\(comp.hour!):\(comp.minute!)"*/
    
    //HARDCORE WORKAROUND
    let endTime = dateString[dateString.index(dateString.startIndex, offsetBy: 11)...dateString.index(dateString.startIndex, offsetBy: 15)]

    return endTime 
}


func createTimeStampForToday() -> (Double,Double) {
    
    let today = Date()
    let comp = getComponentsOfDate(today)
    
    var inMiddleOfNight = false
    
    if comp.hour! < 5 {
        inMiddleOfNight = true
    }
    else if comp.hour == 5 && comp.hour! < 30 {
        inMiddleOfNight = true
    }
    else {
        //take default
    }
    
    let dateString = "\(comp.year!)-\(comp.month!)-\(comp.day!) 05:30:00 +0000"
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
    var date = dateFormatter.date(from: dateString)
    if inMiddleOfNight {
        //subtract one day to get events of yesterday
        print("-> We are in the middle of the night")
        date = date?.addingTimeInterval(-oneDayInSeconds)
    }
    else {
        print("-> We are NOT in the middle of the night")
    }
    
    let timeStamp = createTimeStampForSpecificDate(dateBegin: date!, dateEnd: nil)
    return timeStamp
}


///If only dateBegin is given, then it will default End to one day after dateBegin
func createTimeStampForSpecificDate(dateBegin incDateBegin: Date, dateEnd incDateEnd: Date?) -> (Double,Double) {
    
    let compBegin = getComponentsOfDate(incDateBegin)
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
    
    let dateBeginAsString = "\(compBegin.year!)-\(compBegin.month!)-\(compBegin.day!) 05:30:00 +0000"
    let dateBegin = dateFormatter.date(from: dateBeginAsString)!
    var dateEnd = dateBegin.addingTimeInterval(oneDayInSeconds)
    
    //if incDateEnd was specified, then use that - otherwise use standard value (e.g go one day on from dateBegin)
    if incDateEnd != nil {
        let compEnd = getComponentsOfDate(incDateEnd!)
        let dateEndAsString = "\(compEnd.year!)-\(compEnd.month!)-\(compEnd.day!) 05:30:00 +0000"
        dateEnd = dateFormatter.date(from: dateEndAsString)!
        dateEnd = dateEnd.addingTimeInterval(oneDayInSeconds) //otherwise you wouldn't get the events that happen on the dateEnd date
    }
    
    print("begin: \(dateBegin)")
    print("end:   \(dateEnd)")
    
    let today = Date()
    let differenceToBegin = Int(dateBegin.timeIntervalSince(today))
    let differenceToEnd = Int(dateEnd.timeIntervalSince(today))
    
    print("differenceToBegin: \(differenceToBegin) seconds")
    print("differenceToEnd:   \(differenceToEnd) seconds")
    
    let stampBegin = getTimestampWithDifferenceToToday(daysInc: 0, hoursInc: 0, minutesInc: 0, secondsInc: differenceToBegin)
    let stampEnd = getTimestampWithDifferenceToToday(daysInc: 0, hoursInc: 0, minutesInc: 0, secondsInc: differenceToEnd)
    
    return (stampBegin,stampEnd)
}


public func getTimestampWithDifferenceToToday(daysInc: Int, hoursInc: Int, minutesInc: Int, secondsInc: Int) -> Double {
    
    var date = Date()
    
    var unixTimeStamp = TimeInterval()
    var differenceInSeconds = Double()
    let secondsDef = 60 //default values
    let minutesDef = 60
    let hoursDef = 24
    
    //only add/substract to/from date if something != 0 as parameter
    if secondsInc != 0 {
        differenceInSeconds = Double(secondsInc)
        date = date.addingTimeInterval(differenceInSeconds)
    }
    if minutesInc != 0 {
        differenceInSeconds = Double(secondsDef*minutesInc)
        date = date.addingTimeInterval(differenceInSeconds)
    }
    if hoursInc != 0 {
        differenceInSeconds = Double(secondsDef*minutesDef*hoursInc)
        date = date.addingTimeInterval(differenceInSeconds)
    }
    
    if daysInc != 0 {
        let secondsToAdd = Double(secondsDef*minutesDef*hoursDef*daysInc)
        date = date.addingTimeInterval(secondsToAdd)
    }
    unixTimeStamp = date.timeIntervalSince1970
    let formattedTimestamp = unixTimeStamp.roundTo(places: 0)
    let checkDate = Date(timeIntervalSince1970: unixTimeStamp)
    
    let timezone = TimeZone.autoupdatingCurrent
    let timeZoneAbbreviation = timezone.abbreviation()!
    let timeZoneDescription = (timezone as NSTimeZone).description
    let timeZoneName = timezone.identifier
    
    print("")
    print("unixtimestamp:       \(formattedTimestamp)")
    print("corresponding date:  \(checkDate) \(timeZoneAbbreviation)")
    print("We are in time-zone: \(timeZoneName) -> \(timeZoneDescription)")
    
    return formattedTimestamp
}

func getTodaysWeekday() -> Int {
    let today = NSDate()
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: today as Date)
    return weekDay
}

func dateIsInTheMiddleOfTheNight(date: Date) -> Bool {
    let comp = getComponentsOfDate(date)
    var inMiddleOfNight = false
    
    if comp.hour! < 5 {
        inMiddleOfNight = true
    }
    else if comp.hour == 5 && comp.hour! < 30 {
        inMiddleOfNight = true
    }
    
    return inMiddleOfNight
}

























