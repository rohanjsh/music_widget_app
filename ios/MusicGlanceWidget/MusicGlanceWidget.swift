//
//  MusicGlanceWidget.swift
//  MusicGlanceWidget
//
//  Created by Rohan Joshi on 08/12/24.
//

import WidgetKit
import SwiftUI
import MediaPlayer

struct MusicEntry: TimelineEntry {
    let date: Date
    let isPlaying: Bool
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MusicEntry {
        MusicEntry(date: Date(), isPlaying: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (MusicEntry) -> Void) {
        let prefs = UserDefaults(suiteName: "group.dev.rohanjsh.appWidgets")
        let entry = MusicEntry(
            date: Date(),
            isPlaying: prefs?.bool(forKey: "isPlaying") ?? false
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct MusicWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            // Background Image with fallback
            Group {
                if let _ = UIImage(named: "widget_background") {
                    Image("widget_background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                } else {
                    // Fallback gradient if image is missing
                    LinearGradient(
                        colors: [Color(hex: 0x1F1F1F), Color(hex: 0x3B2349)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            
            VStack(spacing: 8) {
                Spacer().frame(height: 18)
                
                if #available(iOS 17, *) {
                    Button(intent: BackgroundIntent(method: "toggleplay")) {
                        Image(systemName: entry.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                }
                
                Text("A cool song")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct MusicGlanceWidget: Widget {
    let kind: String = "MusicGlanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MusicWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MusicWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Music Control")
        .description("Music player controls")
        .supportedFamilies([.systemSmall])
    }
}

//#Preview(as: .systemSmall) {
//    MusicGlanceWidget()
//} timeline: {
//    MusicEntry(date: .now, isPlaying: false)
//    MusicEntry(date: .now, isPlaying: true)
//}
