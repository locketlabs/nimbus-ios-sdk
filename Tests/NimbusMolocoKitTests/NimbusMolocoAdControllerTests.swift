import MolocoSDK
@testable import NimbusMolocoKit
import NimbusRenderKit
import UIKit
import XCTest

final class NimbusMolocoAdControllerTests: XCTestCase {
    @MainActor
    func testLoadFailureFromBackgroundDeliversErrorOnMainThread() {
        let fixture = makeFixture()

        performFromBackground {
            fixture.controller.failToLoad(ad: fixture.ad, with: TestError.failed)
        }

        XCTAssertEqual(fixture.delegate.errors.count, 1)
        XCTAssertEqual(fixture.delegate.errors.first?.contains("ad failed to load"), true)
        XCTAssertEqual(fixture.delegate.errors.first?.contains("Test failure"), true)
    }

    @MainActor
    func testShowFailureFromBackgroundDeliversErrorOnMainThread() {
        let fixture = makeFixture()

        performFromBackground {
            fixture.controller.failToShow(ad: fixture.ad, with: nil)
        }

        XCTAssertEqual(fixture.delegate.errors.count, 1)
        XCTAssertEqual(fixture.delegate.errors.first?.contains("ad failed to show: nil"), true)
    }

    @MainActor
    func testBackgroundLifecycleCallbacksPreserveOrderAndDestroyOnMainThread() {
        let fixture = makeFixture()

        performFromBackground {
            fixture.controller.didLoad(ad: fixture.ad)
            fixture.controller.didShow(ad: fixture.ad)
            fixture.controller.didClick(on: fixture.ad)
            fixture.controller.userRewarded(ad: fixture.ad)
            fixture.controller.didHide(ad: fixture.ad)
        }

        XCTAssertEqual(fixture.delegate.events, [.loaded, .impression, .clicked, .completed, .destroyed])
        XCTAssertEqual(fixture.ad.destroyCount, 1)
        XCTAssertEqual(fixture.controller.adState, .destroyed)
        XCTAssertNil(fixture.controller.nativeAd)
    }

    @MainActor
    func testLateLoadAfterHideDoesNotReviveDestroyedAd() {
        let fixture = makeFixture()

        performFromBackground {
            fixture.controller.didHide(ad: fixture.ad)
            fixture.controller.didLoad(ad: fixture.ad)
            fixture.controller.didHide(ad: fixture.ad)
        }

        XCTAssertEqual(fixture.delegate.events, [.destroyed])
        XCTAssertTrue(fixture.delegate.errors.isEmpty)
        XCTAssertEqual(fixture.ad.destroyCount, 1)
        XCTAssertEqual(fixture.controller.adState, .destroyed)
    }

    @MainActor
    func testRewardAfterHideIsStillDelivered() {
        let fixture = makeFixture()

        performFromBackground {
            fixture.controller.didHide(ad: fixture.ad)
            fixture.controller.userRewarded(ad: fixture.ad)
        }

        XCTAssertEqual(fixture.delegate.events, [.destroyed, .completed])
        XCTAssertEqual(fixture.controller.adState, .destroyed)
    }

    @MainActor
    func testQueuedErrorRetainsControllerUntilDelivery() {
        var fixture: Fixture? = makeFixture()
        let delegate = fixture!.delegate
        fixture!.controller.failToLoad(ad: fixture!.ad, with: TestError.failed)
        fixture = nil
        drainMainQueue()

        XCTAssertEqual(delegate.errors.count, 1)
    }

    @MainActor
    func testPendingMainThreadCallbackDoesNotReviveAdDestroyedByPublisher() {
        let fixture = makeFixture()
        fixture.controller.didLoad(ad: fixture.ad)
        fixture.controller.destroy()
        drainMainQueue()

        XCTAssertTrue(fixture.delegate.events.isEmpty)
        XCTAssertEqual(fixture.ad.destroyCount, 1)
        XCTAssertEqual(fixture.controller.adState, .destroyed)
    }

    @MainActor
    func testMainThreadCallbacksPreserveOrder() {
        let fixture = makeFixture()
        fixture.controller.didLoad(ad: fixture.ad)
        fixture.controller.didShow(ad: fixture.ad)
        fixture.controller.didClick(on: fixture.ad)
        drainMainQueue()

        XCTAssertEqual(fixture.delegate.events, [.loaded, .impression, .clicked])
    }

    @MainActor
    func testNativeAndRewardedLoggingCallbacksRunOnMainThread() {
        let fixture = makeFixture()

        performFromBackground {
            fixture.controller.didHandleClick(ad: fixture.ad)
            fixture.controller.didHandleImpression(ad: fixture.ad)
            fixture.controller.rewardedVideoStarted(ad: fixture.ad)
            fixture.controller.rewardedVideoCompleted(ad: fixture.ad)
        }

        XCTAssertEqual(fixture.logger.messages, [
            "Handled Moloco Click",
            "Handled Moloco Impression",
            "Moloco Video Started",
            "Moloco Video Completed",
        ])
    }

    @MainActor
    private func performFromBackground(_ callbacks: @escaping () -> Void) {
        let drained = expectation(description: "Callbacks delivered")
        DispatchQueue.global().async {
            XCTAssertFalse(Thread.isMainThread)
            callbacks()
            DispatchQueue.main.async { drained.fulfill() }
        }
        wait(for: [drained], timeout: 5)
    }

    @MainActor
    private func drainMainQueue() {
        let drained = expectation(description: "Main queue drained")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 5)
    }

    @MainActor
    private func makeFixture() -> Fixture {
        let container = UIView()
        let delegate = RecordingDelegate()
        let logger = RecordingLogger()
        let ad = StubNativeAd()
        let controller = NimbusMolocoAdController(
            ad: NimbusAd(
                position: "test",
                auctionType: .native,
                bidRaw: 0,
                bidInCents: 0,
                contentType: "application/json",
                auctionId: "test",
                network: "molocosdk",
                markup: "",
                isInterstitial: false,
                placementId: nil,
                duration: nil,
                adDimensions: nil,
                trackers: nil,
                isMraid: false,
                extensions: nil
            ),
            container: container,
            logger: logger,
            delegate: delegate,
            isBlocking: false,
            isRewarded: false,
            adPresentingViewController: nil
        )
        controller.nativeAd = ad
        logger.messages.removeAll()
        return Fixture(controller: controller, ad: ad, delegate: delegate, logger: logger, container: container)
    }
}

private struct Fixture {
    let controller: NimbusMolocoAdController
    let ad: StubNativeAd
    let delegate: RecordingDelegate
    let logger: RecordingLogger
    // Nimbus retains the container and delegate weakly.
    let container: UIView
}

private final class RecordingDelegate: AdControllerDelegate {
    var events: [NimbusEvent] = []
    var errors: [String] = []

    func didReceiveNimbusEvent(controller _: any AdController, event: NimbusEvent) {
        XCTAssertTrue(Thread.isMainThread, "Nimbus events may synchronously mutate UIKit")
        events.append(event)
    }

    func didReceiveNimbusError(controller _: any AdController, error: any NimbusError) {
        XCTAssertTrue(Thread.isMainThread, "Nimbus errors may synchronously remove views")
        errors.append(error.localizedDescription)
    }
}

private final class RecordingLogger: Logger {
    var selectedLogLevel: NimbusLogLevel = .debug
    var messages: [String] = []

    func log(_ message: String, level _: NimbusLogLevel) {
        XCTAssertTrue(Thread.isMainThread)
        messages.append(message)
    }
}

private final class StubNativeAd: NSObject, MolocoNativeAd {
    var delegate: (any MolocoNativeAdDelegate)?
    var assets: (any MolocoNativeAdAssests)? { nil }
    var isReady: Bool { true }
    var destroyCount = 0

    @MainActor func load(bidResponse _: String) {}
    func handleClick() {}
    func handleImpression() {}

    func destroy() {
        XCTAssertTrue(Thread.isMainThread, "Moloco teardown may mutate UIKit")
        destroyCount += 1
    }
}

private enum TestError: LocalizedError {
    case failed
    var errorDescription: String? { "Test failure" }
}
