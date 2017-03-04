GpxLocationManager
===================
[DEMO](https://vimeo.com/138813570)

Xcode’s iOS-app simulator helpfully provides four sets of GPS data for development of apps using `CLLocationManager`: Apple campus, city bike ride, city run, and highway drive. I developed an app that uses GPS and found this data deficient in two ways. First, the data contain no altitudes other than “0”. Altitude tracking is important for my app, and this inability to test my app’s altitude tracking was unacceptable. Second, the simulator provides data only at normal speed. During my develop/run/debug/run cycle, I became impatient waiting for the simulator to provide GPS data to my app, even using the relatively fast-moving highway-drive mode.

In an epic bout of [yak shaving](http://sethgodin.typepad.com/seths_blog/2005/03/dont_shave_that.html), I have remedied these deficiencies by developing `GpxLocationManager`. This class can replace `CLLocationManager` at compile- or runtime, allowing clients to access GPS data from two sources: [GPX](https://en.wikipedia.org/wiki/GPS_Exchange_Format) files and arrays of `CLLocation`s. In particular, `GpxLocationManager` invokes its clients’ `didUpdateLocation()` method with GPS data from either of these two sources. `GpxLocationManager` can provide this data at the same speed it was recorded or sped up by an arbitrary amount. Thanks to the hard work of [Nehal Kanetkar](https://github.com/nkanetka), `GpxLocationManager` supports [simulating](http://nkanetka.github.io/projects/gpx/) course and speed.

Development of the sample [app](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082) continues [here](https://github.com/vermont42/RaceRunner). I welcome pull requests for both `RaceRunner` and `GpxLocationManager`.

I demonstrated `GpxLocationManager` to the [Swift Language User Group](http://www.meetup.com/swift-language/) in [San Francisco](http://www.sanfrancisco.travel). [Realm](http://realm.io) was [kind](https://www.youtube.com/watch?v=LI7-Cu-9wWM) enough to record, transcribe, and host [my talk](https://realm.io/news/josh-adams-gpx-location-manager/).

## Use
Here are the steps to use `GpxLocationManager` in your app.

1. Obtain the framework via CocoaPods or by copying the files RaceRunner/GpxLocationManager.swift, LocationManager.swift, and GpxParser.swift to your project. If you go the CocoaPods route, you will need to `import GpxLocationManager` in any file using classes from that framework.

2. Where you were declaring and instantiating a `CLLocationManager`, instead declare and instantiate a `LocationManager`. Depending on how you instantiate `LocationManager`, there are three possibilities: (1) No arguments: `LocationManager` instantiates a `CLLocationManager` (2) Pass a `String` `gpxFile`: `LocationManager` instantiates a `GpxLocationManager` using the GPX filename you pass in, appending .gpx to the filename. (3) Pass a `[CLLocation]` `locations`: `LocationManager` instantiates a `GpxLocationManager` using the array of `CLLocation`s passed in. The wrapper `LocationManager` exists so that you can decide at run time whether you want a `GpxLocationManager` or `CLLocationManager` running under the hood. The demo uses this flexibility. If you don’t need this flexibility, you can instantiate `GpxLocationManager` directly, avoiding the `LocationManager` wrapper.

3. Set the `LocationManager`’s delegate to something that implements `CLLocationManagerDelegate`.

4. Optionally set the `LocationManager`’s `secondLength` property to something other than 1.0. A lower value speeds up the underlying `GpxLocationManager`. If the `LocationManager` wraps a `CLLocationManager`, this property has no effect.

5. Invoke the `LocationManager`’s `startUpdatingLocation()` method. The `LocationManager` will start calling the delegate’s `didUpdateLocations()` method using data from the device’s GPS, the simulator’s GPS, the GPX file you specified, or the `CLLocation` array you specified.

6. Invoke the `LocationManager`’s `stopUpdatingLocation()` method to pause the location updates.

7. If you are running a `GpxLocationManager` and want to stop the `NSTimer` causing it to invoke `didUpdateLocations()`, invoke the `LocationManager`’s `kill()` method. This method has no effect if there is an underlying `CLLocationManager`.


## Demo

The demo for `GpxLocationManager` is a stripped-down version of my run-tracking app, [RaceRunner](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082).

[Click here](https://vimeo.com/138813570) to watch the demo in action. In this run, `GpxLocationManager` gets GPS data from a GPX file, and RaceRunner plays the data back sped up ten times. Note that a 40-minute run takes four minutes to watch.

The app’s main menu currently has the following options:
* Device GPS: This starts a run using location data from the device’s GPS or the simulator’s GPS, depending on where the app is running.
* CLLocations: This starts a run using data from an array of `CLLocation`s. In RaceRunner, the array is built using a GPX file, but the `CLLocation`s can come from anywhere.
* GPX File: This starts a run using data from a GPX file.
* History: This allows you to see details about past runs.
* Settings: This allows you to change the playback speed of simulated locations from 100% to 1000%. These percentages correspond to second lengths of 1.0 and 0.1 seconds, respectively.


## Comments

`GpxLocationManager` is written in Swift 3.0.

To see examples of `LocationManager` being instantiated in different ways, take a look at `RunModel.swift`.

If you use or are intrigued by `GpxLocationManager`, please consider starring the repo.

`GpxLocationManager` is not a functionally complete replacement for `CLLocationManager`. The former lacks much of the latter’s functionality. `GpxLocationManager`’s primary function is to invoke `didUpdateLocations()` with arbitrary location data. That said, `GpxLocationManager` could certainly serve as a starting point for a functionally complete replacement for `CLLocationManager`.

`GpxLocationManager` correctly parses GPX files created by iSmoothRun, Runmeter, and Runkeeper. I have not tested GPX files from other sources.

## Creator

**Josh Adams**
* [Twitter](https://twitter.com/vermont42)
* [Github](https://github.com/vermont42)


## Credits

`GpxLocationManager` does not use any third-party code, but RaceRunner is based on [MoonRunner](https://github.com/mluedke2/moonrunner) and uses [MarqueeLabel](https://github.com/cbpowell/MarqueeLabel) and a modified version of [Sweather](https://github.com/bfolder/Sweather). All three were released under the MIT license, reproduced below.


## License
```
The MIT License (MIT)

Copyright (c) 2015 Josh Adams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```


## The End
