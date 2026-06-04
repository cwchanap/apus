import XCTest
@testable import apus

final class DIContainerCoverageTests: XCTestCase {

    var sut: DIContainer!

    override func setUp() {
        super.setUp()
        sut = DIContainer.shared
        sut.clear()
    }

    override func tearDown() {
        sut.clear()
        sut = nil
        super.tearDown()
    }

    func testRegisterFactoryAndResolve() {
        sut.register(CameraManagerProtocol.self) { MockCameraManager() }
        let resolved: CameraManagerProtocol = sut.resolve(CameraManagerProtocol.self)
        XCTAssertNotNil(resolved)
    }

    func testResolveOptional_returnsNilForUnregistered() {
        let localContainer = TestDIContainer()
        let result: CameraManagerProtocol? = localContainer.resolveOptional(CameraManagerProtocol.self)
        XCTAssertNil(result)
    }

    func testResolveOptional_returnsRegisteredInstance() {
        let manager = MockCameraManager()
        sut.register(CameraManagerProtocol.self, instance: manager)
        let result: CameraManagerProtocol? = sut.resolveOptional(CameraManagerProtocol.self)
        XCTAssertNotNil(result)
    }

    func testResolveOptional_returnsFactoryResult() {
        sut.register(CameraManagerProtocol.self) { MockCameraManager() }
        let result: CameraManagerProtocol? = sut.resolveOptional(CameraManagerProtocol.self)
        XCTAssertNotNil(result)
    }

    func testClear_removesAllRegistrations() {
        let localContainer = TestDIContainer()
        localContainer.register(CameraManagerProtocol.self, instance: MockCameraManager())
        localContainer.clear()
        XCTAssertNil(localContainer.resolveOptional(CameraManagerProtocol.self))
    }

    func testRegisterFactory_createsNewInstanceEachTime() {
        var callCount = 0
        sut.register(CameraManagerProtocol.self) {
            callCount += 1
            return MockCameraManager()
        }
        _ = sut.resolve(CameraManagerProtocol.self)
        _ = sut.resolve(CameraManagerProtocol.self)
        XCTAssertEqual(callCount, 2)
    }

    func testRegisterInstance_returnsSameInstanceEachTime() {
        let manager1 = MockCameraManager()
        let manager2 = MockCameraManager()
        sut.register(CameraManagerProtocol.self, instance: manager1)
        sut.register(CameraManagerProtocol.self, instance: manager2)
        let result: CameraManagerProtocol = sut.resolve(CameraManagerProtocol.self)
        XCTAssertTrue(result === manager2)
    }

    func testResolveOptional_prefersInstanceOverFactory() {
        let instance = MockCameraManager()
        sut.register(CameraManagerProtocol.self) { MockCameraManager() }
        sut.register(CameraManagerProtocol.self, instance: instance)
        let result: CameraManagerProtocol? = sut.resolveOptional(CameraManagerProtocol.self)
        XCTAssertTrue(result === instance)
    }

    func testInjected_resolvesFromContainer() {
        sut.register(HapticServiceProtocol.self, instance: MockHapticService())
        let injected: Injected<HapticServiceProtocol> = Injected<HapticServiceProtocol>(container: sut)
        XCTAssertNotNil(injected.wrappedValue)
    }

    func testOptionalInjected_resolvesFromContainer() {
        sut.register(HapticServiceProtocol.self, instance: MockHapticService())
        let injected: OptionalInjected<HapticServiceProtocol> = OptionalInjected<HapticServiceProtocol>(container: sut)
        XCTAssertNotNil(injected.wrappedValue)
    }

    func testOptionalInjected_returnsNilForUnregistered() {
        let localContainer = TestDIContainer()
        let injected: OptionalInjected<CameraManagerProtocol> = OptionalInjected<CameraManagerProtocol>(container: localContainer)
        XCTAssertNil(injected.wrappedValue)
    }
}
