//
//  DarkSky.swift
//
//  Created by Josh Adams on 3/20/15.
//  Copyright (c) 2014 Josh Adams. All rights reserved.
//  This code is based on https://github.com/bfolder/Sweather .

import Foundation
import CoreLocation

open class DarkSky {
    static let temperatureError: Float = -1000.0
    static let weatherError = "weather error"
    static let basePath = "https://api.forecast.io/forecast/"
    static let apiKey = ""
    
    public enum Result {
        case success(URLResponse?, NSDictionary?)
        case Error(URLResponse?, NSError?)
        
        public func data() -> NSDictionary? {
            switch self {
                case .success(_, let dictionary):
                return dictionary
                case .Error(_, _):
                return nil
            }
        }
        
        public func response() -> URLResponse? {
            switch self {
            case .success(let response, _):
                return response
            case .Error(let response, _):
                return response
            }
        }
        
        public func error() -> NSError? {
            switch self {
            case .success(_, _):
                return nil
            case .Error(_, let error):
                return error
            }
        }
    }
    
    fileprivate var queue: OperationQueue;
    
    public init() {
        self.queue = OperationQueue()
    }
    
    open func currentWeather(_ coordinate: CLLocationCoordinate2D, callback: @escaping (Result) -> ()) {
        let coordinateString = "\(coordinate.latitude),\(coordinate.longitude)"
        call(coordinateString, callback: callback);
    }
    
    fileprivate func call(_ method: String, callback: @escaping (Result) -> ()) {
        if DarkSky.apiKey == "" {
            print("This app cannot query Dark Sky for current temperature and weather until you obtain an API key and put it in DarkSky.swift. Here is the website to get an API key: https://developer.forecast.io/register You can ignore the following error message, which Dark Sky returned due to the empty API key.")
        }
        let url = DarkSky.basePath + DarkSky.apiKey + "/" + method
        let request = URLRequest(url: URL(string: url)!)
        let currentQueue = OperationQueue.current;
        
        NSURLConnection.sendAsynchronousRequest(request, queue: currentQueue!, completionHandler: { (response, data, error) -> Void in
            let error: NSError? = error as NSError?
            var dictionary: NSDictionary?
            
            if let data = data {
                do {
                    try dictionary = JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            currentQueue?.addOperation {
                var result = Result.success(response, dictionary)
                if error != nil {
                    result = Result.Error(response, error)
                }
                callback(result)
            }
        })
    }
}
