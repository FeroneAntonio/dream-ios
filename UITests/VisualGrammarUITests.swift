import XCTest

final class VisualGrammarUITests: XCTestCase {
  @MainActor
  func testRefinementPreviewCancelConfirmAndReopening() throws {
    let app = XCUIApplication()
    app.launch()
    app.buttons["newTextDream"].tap()
    let field = app.descendants(matching: .any).matching(identifier: "dreamText").firstMatch
    XCTAssertTrue(field.waitForExistence(timeout: 5))
    field.tap()
    if let value = field.value as? String {
      field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
    }
    field.typeText("I was walking in a forest when the path split into three.")
    app.buttons["createDream"].tap()
    XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 90))
    XCTAssertTrue(app.staticTexts["Why this drawing?"].waitForExistence(timeout: 10))
    let refine = app.buttons["refinePortrait"]
    if !refine.isHittable { app.swipeUp() }
    refine.tap()
    XCTAssertTrue(app.buttons["confirmPortrait"].waitForExistence(timeout: 10))
    let explore = app.buttons["explorePortrait"]
    if !explore.isHittable { app.swipeUp() }
    explore.tap()
    app.buttons["Cancel"].tap()
    XCTAssertTrue(app.buttons["confirmPortrait"].waitForNonExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["Why this drawing?"].exists)
    if !refine.isHittable { app.swipeUp() }
    refine.tap()
    XCTAssertTrue(app.buttons["confirmPortrait"].waitForExistence(timeout: 10))
    if !app.buttons["explorePortrait"].isHittable { app.swipeUp() }
    app.buttons["explorePortrait"].tap()
    app.buttons["confirmPortrait"].tap()
    XCTAssertTrue(app.buttons["confirmPortrait"].waitForNonExistence(timeout: 15))
    app.buttons["Done"].tap()
    app.terminate()
    app.launch()
    let portrait = app.buttons["Open your latest dream"]
    XCTAssertTrue(portrait.waitForExistence(timeout: 10))
    portrait.tap()
    XCTAssertTrue(app.staticTexts["Why this drawing?"].waitForExistence(timeout: 10))
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = "Visual Grammar — saved refined portrait and explanation"
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  @MainActor
  func testCaptureActionsAtLargestDynamicType() throws {
    let app = XCUIApplication()
    app.launchArguments = [
      "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL",
    ]
    app.launch()
    let write = app.buttons["newTextDream"]
    XCTAssertTrue(write.waitForExistence(timeout: 10))
    XCTAssertTrue(write.isHittable)
    write.tap()
    XCTAssertTrue(
      app.descendants(matching: .any).matching(identifier: "dreamText").firstMatch.waitForExistence(
        timeout: 10))
    XCTAssertFalse(app.buttons["voiceCapture"].exists)
    app.buttons["Cancel"].tap()
  }
}
