#!/usr/bin/env swift
import AppKit
import Foundation

autoreleasepool {
    // Replace / extend this list with your full building list
    let buildingList = [
        "Albuquerque HQ - NM",
        "Chicago HQ - IL",
        "Chicago Pilsen - IL",
        "Cigna",
        "Dallas C1 - TX",
        "Danville - IL",
        "Downers Grove - IL",
        "Helena HQ - MT",
        "Houston - TX",
        "Lombard - IL"
        // ... add remaining buildings here
    ]

    // Ensure an application object exists for AppKit modal APIs
    _ = NSApplication.shared

    let fieldWidth: CGFloat = 360
    let fieldHeight: CGFloat = 24
    let padding: CGFloat = 8

    let usernameField = NSTextField(frame: NSRect(x: 0, y: 64, width: fieldWidth, height: fieldHeight))
    usernameField.placeholderString = "Username"
    usernameField.stringValue = ""

    let assetField = NSTextField(frame: NSRect(x: 0, y: 32, width: fieldWidth, height: fieldHeight))
    assetField.placeholderString = "Asset tag"
    assetField.stringValue = ""

    let buildingPop = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: fieldWidth, height: 26), pullsDown: false)
    buildingPop.addItems(withTitles: buildingList)
    if let defaultIndex = buildingList.firstIndex(of: "Chicago HQ - IL") {
        buildingPop.selectItem(at: defaultIndex)
    }

    let accessoryHeight = 64 + fieldHeight + padding
    let accessoryView = NSView(frame: NSRect(x: 0, y: 0, width: fieldWidth, height: accessoryHeight))
    accessoryView.addSubview(usernameField)
    accessoryView.addSubview(assetField)
    accessoryView.addSubview(buildingPop)

    let alert = NSAlert()
    alert.messageText = "Asset Registration"
    alert.informativeText = "Enter username, asset tag, and choose a building."
    alert.accessoryView = accessoryView
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")

    let response = alert.runModal()
    // Second button is Cancel
    if response == .alertSecondButtonReturn {
        // Matches your AppleScript behavior so the shell can check for "__CANCELED__"
        print("__CANCELED__")
        exit(0)
    }

    let uname = usernameField.stringValue
    let atag = assetField.stringValue
    let bldg = buildingPop.titleOfSelectedItem ?? ""

    // Print tab-delimited output so the shell can read it as before
    print("\(uname)\t\(atag)\t\(bldg)")
}