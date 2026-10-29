import WidgetKit
import SwiftUI

struct SynapseWidgetEntry: TimelineEntry {
    let date: Date
    let nextMedTitle: String
    let nextMedDosage: String
    let nextMedTime: String
    let hydrationConsumed: Int
    let hydrationTarget: Int
    let sittingMinutes: Int
}

struct SynapseProvider: TimelineProvider {
    func placeholder(in context: Context) -> SynapseWidgetEntry {
        SynapseWidgetEntry(
            date: Date(),
            nextMedTitle: "Metformin",
            nextMedDosage: "500mg • 2 pills",
            nextMedTime: "08:30",
            hydrationConsumed: 1750,
            hydrationTarget: 2500,
            sittingMinutes: 35
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SynapseWidgetEntry) -> ()) {
        completion(loadFromAppGroup())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SynapseWidgetEntry>) -> ()) {
        let entry = loadFromAppGroup()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadFromAppGroup() -> SynapseWidgetEntry {
        let defaults = UserDefaults(suiteName: "group.com.synapse.ambient")
        let title = defaults?.string(forKey: "next_med_title") ?? "All Doses Complete"
        let dosage = defaults?.string(forKey: "next_med_dosage") ?? "Done for today"
        let time = defaults?.string(forKey: "next_med_time") ?? "--:--"
        let water = defaults?.integer(forKey: "hydration_consumed_ml") ?? 1750
        let target = defaults?.integer(forKey: "hydration_target_ml") ?? 2500
        let sitting = defaults?.integer(forKey: "sitting_minutes") ?? 0

        return SynapseWidgetEntry(
            date: Date(),
            nextMedTitle: title,
            nextMedDosage: dosage,
            nextMedTime: time,
            hydrationConsumed: water,
            hydrationTarget: target,
            sittingMinutes: sitting
        )
    }
}

struct SynapseLockScreenWidgetEntryView: View {
    var entry: SynapseProvider.Entry

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("NEXT DOSE • \(entry.nextMedTime)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                Text(entry.nextMedTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text(entry.nextMedDosage)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.hydrationConsumed)ml")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                Text("HYDRATION")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.85))
    }
}

@main
struct SynapseLockScreenWidget: Widget {
    let kind: String = "SynapseLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SynapseProvider()) { entry in
            SynapseLockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Synapse Ambient Routine")
        .description("Glanceable medication, hydration, and movement monitoring directly on lock screen.")
        .supportedFamilies([.accessoryRectangular, .systemSmall, .systemMedium])
    }
}
