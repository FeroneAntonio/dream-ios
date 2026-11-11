import XCTest

final class DreamVoiceUITests: XCTestCase {
    @MainActor
    func testVoicePermissionCallbackDoesNotCrash() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["newVoiceDream"].tap()
        let system = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        // Refuse both permissions on the dedicated simulator: no ambient audio is recorded.
        for _ in 0..<2 {
            let alert = system.alerts.firstMatch
            if alert.waitForExistence(timeout: 4) {
                let labels = ["Don’t Allow", "Don't Allow", "Non consentire"]
                if let button = labels.map({ alert.buttons[$0] }).first(where: \.exists) { button.tap() }
            }
        }
        XCTAssertTrue(app.buttons["voiceCapture"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.state, .runningForeground)
        let denied = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Allow microphone access")).firstMatch
        XCTAssertTrue(denied.waitForExistence(timeout: 5))
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Voice permission handled without crash"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testTextCaptureRestoresDraftAfterRelaunch() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["newTextDream"].tap()
        let field = app.descendants(matching: .any).matching(identifier: "dreamText").firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["voiceCapture"].exists)
        field.tap()
        if let value = field.value as? String { field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count)) }
        field.typeText("A bridge between the clouds")
        app.buttons["Cancel"].tap()
        app.terminate()
        app.launch()
        app.buttons["newTextDream"].tap()
        XCTAssertTrue(app.staticTexts["Draft restored"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "dreamText").firstMatch.value as? String, "A bridge between the clouds")
    }

    @MainActor
    func testNotebookPageShowsSavedDream() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["newTextDream"].tap()
        let field = app.descendants(matching: .any).matching(identifier: "dreamText").firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["voiceCapture"].exists)
        field.tap()
        if let value = field.value as? String {
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
        }
        field.typeText("I was on a bridge between the clouds. Houses floated slowly and I felt calm.")
        app.buttons["createDream"].tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 90))
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["openJournal"].waitForExistence(timeout: 5))
        app.buttons["openJournal"].tap()
        XCTAssertTrue(app.staticTexts["My dream journal"].waitForExistence(timeout: 5))
        let story = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH %@", "I was on a bridge between the clouds.")).firstMatch
        XCTAssertTrue(story.waitForExistence(timeout: 5))
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Notebook page with fictional dream"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
