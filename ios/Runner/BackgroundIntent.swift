import AppIntents
import Foundation
import WidgetKit
import home_widget

@available(iOS 17, *)
public struct BackgroundIntent: AppIntent {
    static public var title: LocalizedStringResource = "Music Control"

    @Parameter(title: "Method")
    var method: String

    public init() {
        method = "toggleplay"
    }

    public init(method: String) {
        self.method = method
    }

    public func perform() async throws -> some IntentResult {
        let worker = await HomeWidgetBackgroundWorker.run(
            url: URL(string: "appWidgets://\(method)")!,
            appGroup: "group.dev.rohanjsh.appWidgets"
        )
        
        // Reload widget to update UI
        await WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

@available(iOS 17, *)
@available(iOSApplicationExtension, unavailable)
extension BackgroundIntent: ForegroundContinuableIntent {}


