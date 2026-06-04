import XCTest
@testable import apus

final class HapticServiceTests: XCTestCase {

    var sut: HapticService!

    override func setUp() {
        super.setUp()
        sut = HapticService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testImpact_light_doesNotCrash() {
        sut.impact(.light)
    }

    func testImpact_medium_doesNotCrash() {
        sut.impact(.medium)
    }

    func testImpact_heavy_doesNotCrash() {
        sut.impact(.heavy)
    }

    func testImpact_soft_doesNotCrash() {
        sut.impact(.soft)
    }

    func testImpact_rigid_doesNotCrash() {
        sut.impact(.rigid)
    }

    func testNotification_success_doesNotCrash() {
        sut.notification(.success)
    }

    func testNotification_warning_doesNotCrash() {
        sut.notification(.warning)
    }

    func testNotification_error_doesNotCrash() {
        sut.notification(.error)
    }

    func testSelection_doesNotCrash() {
        sut.selection()
    }

    func testButtonTap_doesNotCrash() {
        sut.buttonTap()
    }

    func testActionFeedback_doesNotCrash() {
        sut.actionFeedback()
    }

    func testStrongFeedback_doesNotCrash() {
        sut.strongFeedback()
    }

    func testSuccess_doesNotCrash() {
        sut.success()
    }

    func testWarning_doesNotCrash() {
        sut.warning()
    }

    func testError_doesNotCrash() {
        sut.error()
    }

    func testSelectionChanged_doesNotCrash() {
        sut.selectionChanged()
    }
}

final class MockHapticServiceTests: XCTestCase {

    var sut: MockHapticService!

    override func setUp() {
        super.setUp()
        sut = MockHapticService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testImpact_setsFlag() {
        XCTAssertFalse(sut.impactCalled)
        sut.impact(.light)
        XCTAssertTrue(sut.impactCalled)
    }

    func testNotification_setsFlag() {
        XCTAssertFalse(sut.notificationCalled)
        sut.notification(.success)
        XCTAssertTrue(sut.notificationCalled)
    }

    func testSelection_setsFlag() {
        XCTAssertFalse(sut.selectionCalled)
        sut.selection()
        XCTAssertTrue(sut.selectionCalled)
    }

    func testButtonTap_setsFlag() {
        sut.buttonTap()
        XCTAssertTrue(sut.buttonTapCalled)
    }

    func testActionFeedback_setsFlag() {
        sut.actionFeedback()
        XCTAssertTrue(sut.actionFeedbackCalled)
    }

    func testStrongFeedback_setsFlag() {
        sut.strongFeedback()
        XCTAssertTrue(sut.strongFeedbackCalled)
    }

    func testSuccess_setsFlag() {
        sut.success()
        XCTAssertTrue(sut.successCalled)
    }

    func testWarning_setsFlag() {
        sut.warning()
        XCTAssertTrue(sut.warningCalled)
    }

    func testError_setsFlag() {
        sut.error()
        XCTAssertTrue(sut.errorCalled)
    }

    func testSelectionChanged_setsFlag() {
        sut.selectionChanged()
        XCTAssertTrue(sut.selectionChangedCalled)
    }
}
