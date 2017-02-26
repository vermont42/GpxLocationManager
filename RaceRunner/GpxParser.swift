//
//  GpxParser.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 5/2/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import CoreLocation

class GpxParser: NSObject, XMLParserDelegate {
    fileprivate var parser: XMLParser?
    fileprivate var name: String = ""
    fileprivate var locations: [CLLocation] = []
    fileprivate var buffer: String = ""
    fileprivate let dateFormatter = DateFormatter()
    fileprivate var curLatString: NSString = ""
    fileprivate var curLonString: NSString = ""
    fileprivate var curEleString: NSString = ""
    fileprivate var curSpeedString: NSString = ""
    fileprivate var curCourseString: NSString = ""
    fileprivate var curTimeString: String = ""
    fileprivate var startedTrackPoints = false
    fileprivate static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    fileprivate static let accuracy: CLLocationAccuracy = 5.0
    fileprivate enum ParsingState: String {
        case Trkpt = "trkpt"
        case Name = "name"
        case Ele = "ele"
        case Time = "time"
        case speed = "speed"
        case course = "course"
        init() {
            self = .Name
        }
    }
    fileprivate var alreadySetName = false
    fileprivate var parsingState: ParsingState = .Name
    
    init?(file: String) {
        super.init()
        let url = Bundle.main.url(forResource: file, withExtension: "gpx")
        if url == nil {
            return nil
        }
        parser = XMLParser(contentsOf: url!)
        parser?.delegate = self
        dateFormatter.dateFormat = GpxParser.dateFormat
    }
    
    func parse() -> (String, [CLLocation]) {
        parser?.parse()
        return (name, locations)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case ParsingState.Trkpt.rawValue:
            curLatString = attributeDict["lat"]! as NSString
            curLonString = attributeDict["lon"]! as NSString
            parsingState = .Trkpt
            startedTrackPoints = true
        case ParsingState.Name.rawValue:
            if !alreadySetName {
                buffer = ""
                parsingState = .Name
            }
        case ParsingState.Ele.rawValue:
            buffer = ""
            parsingState = .Ele
        case ParsingState.Time.rawValue:
            if startedTrackPoints {
                buffer = ""
                parsingState = .Time
            }
        case ParsingState.speed.rawValue:
            parsingState = .speed
        case ParsingState.course.rawValue:
            parsingState = .course
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (startedTrackPoints || (parsingState == .Name && !alreadySetName)) && string != "\n" {
            buffer = buffer + string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case ParsingState.Trkpt.rawValue:
            locations.append(CLLocation(coordinate: CLLocationCoordinate2D(latitude: curLatString.doubleValue, longitude: curLonString.doubleValue), altitude: curEleString.doubleValue, horizontalAccuracy: GpxParser.accuracy, verticalAccuracy: GpxParser.accuracy, timestamp: dateFormatter.date(from: curTimeString)!))
        case ParsingState.Name.rawValue:
            name = buffer
            alreadySetName = true
        case ParsingState.Ele.rawValue:
            curEleString = buffer as NSString
        case ParsingState.Time.rawValue:
            if startedTrackPoints {
                curTimeString = buffer
            }
        case ParsingState.speed.rawValue:
            curSpeedString = buffer as NSString
        case ParsingState.course.rawValue:
            curCourseString = buffer as NSString
        default:
            break
        }
    }
}
