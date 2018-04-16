# TheraMe-Mobile
iOS App, written in Swift 4 for accessing TheraMe as a patient

## Project Set-up

1. Download and install the latest version of Xcode.
2. Go to "File -> Open", and select the "TheraMe Mobile.xcworkspace" file and wait for the project to load.
3. Go to "Xcode -> Open Developer Tool -> Simulator", and wait for it to load.
4. Grab the "TheraMe_root.cer" file and drag and drop it into the simulator window.
5. Wait for Safari Mobile to load, and click accept on the alert, allowing the certificate to be installed on the device.
6. Tap "Install", in the top right corner, and continue to tap "Install", in various parts of the screen until finally the certificate authority has been installed.
7. Navigate to the main home screen of the simulator, and select "Settings".
8. Tap "About", and then "Certificate Trust Settings", and then enable "Full Trust For Root Certificates" for "TheraMe_CA".
    This allows for the simulator device to accept the self-signed certificates created for SSL/TLS security.
9. Click the big play button in the top left corner of Xcode and run the app!


