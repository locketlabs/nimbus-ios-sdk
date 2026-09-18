import MolocoSDK
@testable import NimbusMolocoKit
import NimbusRenderKit
import UIKit
import XCTest

final class NimbusMolocoAdControllerTests: XCTestCase {
    @MainActor
    func testLoadFailureFromBackgroundDeliversErrorOnMainThread() {
        assertFailureOnMainThread(expectedMessage: "ad failed to load: Optional(\"Test failure\")") { controller, ad in
            controller.failToLoad(ad: ad, with: NSError(
                domain: "test",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Test failure"]
            ))
        }
    }

    @MainActor
    func testShowFailureFromBackgroundDeliversErrorOnMainThread() {
        assertFailureOnMainThread(expectedMessage: "ad failed to show: nil") { controller, ad in
            controller.failToShow(ad: ad, with: nil)
        }
    }

    @MainActor
    private func assertFailureOnMainThread(
        expectedMessage: String,
        callback: @escaping (NimbusMolocoAdController, StubAd) -> Void
    ) {
        let received = expectation(description: "Nimbus error delivered")
        let delegate = ErrorDelegate { error in
            XCTAssertTrue(Thread.isMainThread, "Nimbus error handling may remove UIKit views")
            XCTAssertEqual(error.localizedDescription, "NimbusMolocoAdController error: \(expectedMessage)")
            received.fulfill()
        }
        let container = UIView()
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
            logger: Nimbus.shared.logger,
            delegate: delegate,
            isBlocking: false,
            isRewarded: false,
            adPresentingViewController: nil
        )
        DispatchQueue.global().async {
            XCTAssertFalse(Thread.isMainThread)
            callback(controller, StubAd())
        }
        // Nimbus retains the container and delegate weakly.
        withExtendedLifetime((container, delegate)) {
            wait(for: [received], timeout: 5)
        }
    }
}

private final class ErrorDelegate: AdControllerDelegate {
    let onError: (any NimbusError) -> Void

    init(onError: @escaping (any NimbusError) -> Void) {
        self.onError = onError
    }

    func didReceiveNimbusEvent(controller _: any AdController, event _: NimbusEvent) {}

    func didReceiveNimbusError(controller _: any AdController, error: any NimbusError) {
        onError(error)
    }
}

private final class StubAd: NSObject, MolocoAd {
    var isReady: Bool { true }
    @MainActor func load(bidResponse _: String) {}
    func destroy() {}
}
