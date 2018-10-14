# Ithaca Transit

![Ithaca Transit Icon](https://raw.githubusercontent.com/cuappdev/tcat-ios/master/app-icon.png)

Download on the App Store [here](https://itunes.apple.com/app/id1290883721).

# Build Instructions

## Download Project

1. Install [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12).
2. Clone this repository.
3. Open Terminal and run the following:

```
cd tcat-ios
sudo gem install cocoapods // skip if already installed
pod install
```

4. While you're waiting for that, go to `#transit-ios` and 

4. Open the `.xcworkspace` file.
5. Change any relevant network settings for testing (see below).

## Build & Run

1. Click the Play icon in the top-left of the toolbar. By default, this will load the app in the simulator.
2. To change the simulator's location, within the Simulator.app menu bar, go to `Debug > Location` and click on `Custom Location`. Goldwin Smith Hall's coordinates are **42.449071, -76.483759**.

*Note:* To build on your own device, you need to be signed into an Apple Developer account and have proper provisioning profiles. Talk to Matt about this (it's a pain). Hopefully he will update this in the future with better instructions.

### Updating Network Settings

In Xcode, locate Network.swift or Network+Endpoints.swift. This should be in `TCAT/Utilities` or `TCAT/Network` under the TCAT project.

At the top of the Network class, you can edit whether the app uses the release, debug, or local server, as well as which IP address each one points to.

`networkType = .release | .debug | .local`

`localIPAddress: String`
`debugIPAddress: String`
`releaseIPAddress: String`

# Product Description

Introducing Ithaca Transit, a new end-to-end navigation service for built for the TCAT bus service. A free and open-source app, Ithaca Transit offers a diverse range of features in beautiful, clean interface to help get you where you need to go.

### Live Bus Tracking

Want to know is the bus is running late (again) or where it’s even at? We’ve got you covered. View actual bus locations on the map and see expected delay times, all in one easy-to-use interface. We use the latest dynamic transit data directly from TCAT to ensure the most up-to-date information.

### Search Anywhere

Ithaca Transit integrates with Google Places to allow you to search bus routes to any destination in the country. Search up Chipotle or Waffle Frolic and let the app take care of the rest, including accurate walking directions!

### Your Favorites

Easily bookmark your favorite bus stops and destinations for one tap access to routes. Blazing!

## Made by Cornell AppDev

Cornell AppDev is an engineering project team at Cornell University dedicated to designing and developing mobile applications. We were founded in 2014 and have since released apps for Cornell and beyond, from Eatery and Big Red Shuttle to Pollo and Recast. Our goal is to produce apps that benefit the Cornell community and the local Ithaca area as well as promote open-source development with the community. We have a diverse team of software engineers and product designers that collaborate to create apps from an idea to a reality. Cornell AppDev also aims to foster innovation and learning through training courses, campus initiatives, and collaborative research and development. For more information, visit our [website](http://www.cornellappdev.com) and follow us on [Instagram](https://www.instagram.com/cornellappdev/).
