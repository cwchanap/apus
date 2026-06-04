import XCTest
@testable import apus

final class ServiceLocatorTests: XCTestCase {

    override func setUp() {
        super.setUp()
        AppDependencies.shared.configureForTesting()
    }

    override func tearDown() {
        DIContainer.shared.clear()
        super.tearDown()
    }

    func testServiceLocator_shared_returnsSingleton() {
        let locator1 = ServiceLocator.shared
        let locator2 = ServiceLocator.shared
        XCTAssertTrue(locator1 === locator2)
    }

    func testServiceLocator_cameraManager_resolvesFromContainer() {
        let cameraManager = ServiceLocator.shared.cameraManager
        XCTAssertNotNil(cameraManager)
    }

    func testServiceLocator_objectDetectionManager_resolvesFromContainer() {
        let manager = ServiceLocator.shared.objectDetectionManager
        XCTAssertNotNil(manager)
    }

    func testServiceLocator_photoLibraryService_resolvesFromContainer() {
        let service = ServiceLocator.shared.photoLibraryService
        XCTAssertNotNil(service)
    }

    func testServiceLocator_permissionService_resolvesFromContainer() {
        let service = ServiceLocator.shared.permissionService
        XCTAssertNotNil(service)
    }

    func testServiceLocator_errorService_resolvesFromContainer() {
        let service = ServiceLocator.shared.errorService
        XCTAssertNotNil(service)
    }

    func testServiceLocator_setContainer_doesNotCrash() {
        let testContainer = TestDIContainer()
        ServiceLocator.shared.setContainer(testContainer)
    }
}
