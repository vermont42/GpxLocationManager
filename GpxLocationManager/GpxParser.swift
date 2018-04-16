//
//  GpxParser.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 5/2/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import CoreLocation

open class GpxParser: NSObject, XMLParserDelegate {
  private var parser: XMLParser?
  private var name: String = ""
  private var locations: [CLLocation] = []
  private var buffer: String = ""
  private let dateFormatter = DateFormatter()
  private var curLatString: NSString = ""
  private var curLonString: NSString = ""
  private var curEleString: NSString = ""
  private var curSpeedString: NSString = ""
  private var curCourseString: NSString = ""
  private var curTimeString: String = ""
  private var startedTrackPoints = false
  private static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
  private static let accuracy: CLLocationAccuracy = 5.0
  private enum ParsingState: String {
    case trackpoint = "trkpt"
    case name = "name"
    case elevation = "ele"
    case time = "time"
    case speed = "speed"
    case course = "course"
    init() {
      self = .name
    }
  }
  private var alreadySetName = false
  private var parsingState: ParsingState = .name

  public init?(file: String) {
    super.init()
    let url = Bundle.main.url(forResource: file, withExtension: "gpx")
    if url == nil {
      return nil
    }
    parser = XMLParser(contentsOf: url!)
    parser?.delegate = self
    dateFormatter.dateFormat = GpxParser.dateFormat
  }

  public func parse() -> (String, [CLLocation]) {
    parser?.parse()
    return (name, locations)
  }

  public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    switch elementName {
    case ParsingState.trackpoint.rawValue:
      curLatString = attributeDict["lat"]! as NSString
      curLonString = attributeDict["lon"]! as NSString
      parsingState = .trackpoint
      startedTrackPoints = true
    case ParsingState.name.rawValue:
      if !alreadySetName {
        buffer = ""
        parsingState = .name
      }
    case ParsingState.elevation.rawValue:
      buffer = ""
      parsingState = .elevation
    case ParsingState.time.rawValue:
      if startedTrackPoints {
        buffer = ""
        parsingState = .time
      }
    case ParsingState.speed.rawValue:
      parsingState = .speed
    case ParsingState.course.rawValue:
      parsingState = .course
    default:
      break
    }
  }

  public func parser(_ parser: XMLParser, foundCharacters string: String) {
    if (startedTrackPoints || (parsingState == .name && !alreadySetName)) && string != "\n" {
      buffer += string
    }
  }

  public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    switch elementName {
    case ParsingState.trackpoint.rawValue:
      locations.append(CLLocation(coordinate: CLLocationCoordinate2D(latitude: curLatString.doubleValue, longitude: curLonString.doubleValue), altitude: curEleString.doubleValue, horizontalAccuracy: GpxParser.accuracy, verticalAccuracy: GpxParser.accuracy, timestamp: dateFormatter.date(from: curTimeString)!))
    case ParsingState.name.rawValue:
      name = buffer
      alreadySetName = true
    case ParsingState.elevation.rawValue:
      curEleString = buffer as NSString
    case ParsingState.time.rawValue:
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
