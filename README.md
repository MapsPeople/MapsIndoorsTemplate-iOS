# Using the MapsIndoors Template App

To get started with MapsIndoors IOS SDK follow the description in the [MapsIndoors Getting Started guide](https://docs.mapsindoors.com/ios/v3/getting-started/prerequisites/) to get an API key for MapsIndoors and Google. 

This app will provide an example of how to use the MapsPeople SDK in SwiftUI. 

## Getting started

To get started, clone this repository and run `pod install` from the Terminal. Open the file `xxxxx.xcworkspace` in Xcode. 
Make a copy of the `MapsIndoors-Info-Sample.plist` file and name it `MapsIndoors-Info.plist`. Add your MapsIndoors Api key and Google Maps Api key to the `MapsIndoors-Info.plist` file. Then run the project.

## Use the functionality in your own app

To reuse the code in your app, drag and drop the `Views` and `Services` folders, and all the `Assets` except for the AppIcon into your Xcode project. Create a copy of the `MapsIndoors-Info-Sample.plist` file and name it `MapsIndoors-Info.plist`. Add your MapsIndoors API key and Google Maps API key to the `MapsIndoors-Info.plist` file. Look at `ViewController.swift` for an example of how to initialize the MapsIndoors SDK and use the MapsIndoors SwiftUI implementation in an UIKit app. The `ViewController.swift` reads the API keys retrieved as described above from the file `MapsIndoors-Info.plist`. 

### Update on MapsIndoorsIOS V3.39.0
Update your podfile so it matches the podfile in the MapsIndoors SwiftUI App Example. Note: Due to a [bug in CocoaPods](https://github.com/CocoaPods/CocoaPods/issues/7155) it is necessary to include the post_install hook in your Podfile described in the [PodFile post_install](https://github.com/MapsIndoors/MapsIndoorsIOS/wiki/Podfile-post_install) wiki. 





