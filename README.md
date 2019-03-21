# Ithaca Transit

<img width="256" alt="Ithaca Transit App Icon" src="https://raw.githubusercontent.com/cuappdev/tcat-ios/master/app-icon.png">

Download on the App Store [here](https://itunes.apple.com/app/id1290883721).

# Build Instructions

## Download Project

0. Install [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12).
1. Clone this repository.
2. Open Terminal and run the below code. Installing Cocoapods takes a bit, you can do Step 3 while it downloads.

```
cd ithaca-transit-ios
sudo gem install cocoapods // can skip if already installed
pod install
```

3. Go to pinned messages in `#transit-ios` in Slack and download `Keys.plist` and `GoogleServiceInfo.plist`. Within the root directory, place these files in `~/TCAT/Supporting Files/`. 

>If you aren't an AppDev member, you can plug in your own API keys! View the `Sample Keys.plist` file in the root directory, and refer to instructions [here](https://support.google.com/firebase/answer/7015592?hl=en) on generating a `GoogleServiceInfo.plist`. For the latter step, you will need to create a project within Firebase. Let us know if you have any trouble with this, we're happy to help!

4. Open the `.xcworkspace` file.

## Build & Run

1. Click the Play icon in the top-left of the toolbar. Use the  By default, this will load the app in the simulator.
2. To change the simulator's location, within the Simulator.app menu bar, go to `Debug > Location` and click on `Custom Location`. Goldwin Smith Hall's coordinates are **42.449071, -76.483759**.

*Note:* To build on your own device, you need to be signed into an Apple Developer account and have proper provisioning profiles. Talk to Matt about this (it's a pain). Hopefully he will update this in the future with better instructions.

# Contributions

We're proud to be an open-source development team. If you want to help contribute or improve Ithaca Transit, feel free to submit any issues or pull requests. You can also contact us at [ithacatransit@cornellappdev.com](mailto:ithacatransit@cornellappdev.com).

# Made by Cornell App Development

Cornell AppDev is an engineering project team at Cornell University dedicated to designing and developing mobile applications. We were founded in 2014 and have since released apps for Cornell and beyond, like [Eatery](https://itunes.apple.com/us/app/eatery-cornell-dining/id1089672962?mt=8). Our goal is to produce apps that benefit the Cornell community and the local Ithaca area as well as promote open-source development with the community. We have a diverse team of software engineers and product designers that collaborate to create apps from an idea to a reality. Cornell AppDev also aims to foster innovation and learning through training courses, campus initiatives, and collaborative research and development. For more information, visit our [website](http://www.cornellappdev.com) and follow us on [Instagram](https://www.instagram.com/cornellappdev/).
