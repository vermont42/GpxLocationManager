//
//  GpxParser.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 5/2/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import CoreLocation

class GpxParser: NSObject, NSXMLParserDelegate {
    private var parser: NSXMLParser?
    private var name: String = ""
    private var locations: [CLLocation] = []
    private var buffer: String = ""
    private let dateFormatter = NSDateFormatter()
    private var curLatString: NSString = ""
    private var curLonString: NSString = ""
    private var curEleString: NSString = ""
    private var curTimeString: String = ""
    private var startedTrackPoints = false
    private static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    private static let accuracy: CLLocationAccuracy = 5.0
    private enum ParsingState: String {
        case Trkpt = "trkpt"
        case Name = "name"
        case Ele = "ele"
        case Time = "time"
        init() {
            self = .Name
        }
    }
    private var alreadySetName = false
    private var parsingState: ParsingState = .Name
    
    init?(file: String) {
        super.init()
        let url = NSBundle.mainBundle().URLForResource(file, withExtension: "gpx")
        if url == nil {
            return nil
        }
        parser = NSXMLParser(contentsOfURL: url!)
        parser?.delegate = self
        dateFormatter.dateFormat = GpxParser.dateFormat
    }
    
    func parse() -> (String, [CLLocation]) {
        parser?.parse()
        return (name, locations)
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case ParsingState.Trkpt.rawValue:
            curLatString = attributeDict["lat"]!
            curLonString = attributeDict["lon"]!
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
        default:
            break
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if (startedTrackPoints || (parsingState == .Name && !alreadySetName)) && string != "\n" {
            buffer = buffer + string
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case ParsingState.Trkpt.rawValue:
            locations.append(CLLocation(coordinate: CLLocationCoordinate2D(latitude: curLatString.doubleValue, longitude: curLonString.doubleValue), altitude: curEleString.doubleValue, horizontalAccuracy: GpxParser.accuracy, verticalAccuracy: GpxParser.accuracy, timestamp: dateFormatter.dateFromString(curTimeString)!))
        case ParsingState.Name.rawValue:
            name = buffer
            alreadySetName = true
        case ParsingState.Ele.rawValue:
            curEleString = buffer
        case ParsingState.Time.rawValue:
            if startedTrackPoints {
                curTimeString = buffer
            }
        default:
            break
        }
    }
}