Wunderlist.swift
===========

This is a Wunderlist API wrapper written in Swift. The library is still in development, so it doesn't cover all API endpoints.


###Features

+ Supports iOS and OSX.
+ Authorization process implemented for both platforms.

###Installation

#####As Embedded framework (iOS 8.0+)

1. Add Wunderlist.swift as a submodule.
`git submodule add git@github.com:Constantine-Fry/wunderlist.swift.git`
2. Drag-and-drop `Wunderlist.xcodeproj` into your project. The project has two targets: Wunderlist.framework for OSX project, WunderlistTouch.framework for iOS projects. 
3. Add new target in "Build Phases" -> "Target Dependencies".
4. Click the `+` button at the top left of the panel and choose "New copy files phase".
* Rename the new phase to "Copy Frameworks".
* Set the "Destination" to "Frameworks".
5. Add Wunderlist framework to this phase.

###Usage


###Requirements

Swift 1.1 / iOS 8.0+ / Mac OS X 10.9+ 

###License

The BSD 2-Clause License. See LICENSE.txt for details.

===========
Bonn, April 2015.
