# Vantaca Home (demo replica)

A simple SwiftUI replica of the **Home by Vantaca** homeowner app, built for a Devin demo. All data is in-memory mock data (`VantacaHome/Models.swift`); there is no backend.

## Screens
- **Login**: user name and password
- **Select Management Company**
- **Home**: account picker, current balance, recent payments
- **Make a Payment** and **Auto-Draft** enrollment
- **Community**: announcements feed (pinned first, category filter, unread badge) with a Latest Announcement card on Home
- **Payments** history and **Account** (profile, switch company, log out)

## Run
```sh
brew install xcodegen
xcodegen generate
xcodebuild -scheme VantacaHome -destination 'platform=iOS Simulator,name=iPhone 17' test
```
Or open `VantacaHome.xcodeproj` in Xcode and run on an iPhone simulator.

Demo login: `jpolk` / `Homeowner1!` (James Polk, homeowner and board member at Presidential Hills).

## Known issues (from App Store / Google Play reviews)
1. Valid logins are rejected with "System error. Please try again later."
2. You can't create an account or reset your password in the app ("visit your homeowner portal via desktop").
3. Board members have no board tools in the app and have to use the website.
