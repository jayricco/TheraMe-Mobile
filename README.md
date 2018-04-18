# TheraMe Mobile
iOS App, written in Swift 4 for accessing TheraMe as a patient

## Project Set-up

1. Download and install the latest version of Xcode.
2. Go to "File -> Open", and select the "TheraMe Mobile.xcworkspace" file and wait for the project to load.
3. Go to "Xcode -> Open Developer Tool -> Simulator", and wait for it to load.
4. Grab the "TheraMe_root.cer" file in the "TheraMe Mobile" directory and drag and drop it into the simulator window.
5. Wait for Safari Mobile to load, and click accept on the alert, allowing the certificate to be installed on the device.
6. Tap "Install", in the top right corner, and continue to tap "Install", in various parts of the screen until finally the certificate authority has been installed.
7. Navigate to the main home screen of the simulator, and select "Settings".
8. Tap "General", then "About", and then "Certificate Trust Settings", and then enable "Full Trust For Root Certificates" for "TheraMe_CA".
> This allows for the simulator device to accept the self-signed certificates created for SSL/TLS security. Apple is fairly dodgy with their support of self-signed certificates as it presents an extreme security hazard in day to day use. However, in this case - the use of self-signed certificates aims to keep data transfer secure to the outside world without having to be explicitly responsible for hashing and salting of credentials prior to their transmission.

### Dependency Install (Cocoapods)
First, make sure you have homebrew installed, if you're using mac. Otherwise, use NPM to install cocoapods.
If you are using a Mac and want to use homebrew, but don't yet have it, here is the source page: https://brew.sh/

Once homebrew has been installed, open a terminal instance, and run
`brew install cocoapods`
After that navigate the terminal session to the root of the TheraMe Mobile directory (where the podfile is), and run
`pod install`

Once cocoapods has finished generating it's dependencies, open the workspace as specified in the build output.

> Make sure that the simulator you use is the iPhone X, for convenience sake as others should work but are untested.
This can be set by clicking the tab to the right of the cheveron, two elements right of the play button in Xcode's upper left corner.

9. Click the big play button and run the app!
