import SwiftUI

struct ScheduleEditor: View {
    @Binding var schedule: Schedule

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Enable Schedule", isOn: $schedule.isEnabled)

            if schedule.isEnabled {
                HStack(spacing: 4) {
                    ForEach(Weekday.allCases) { day in
                        Toggle(day.shortName, isOn: Binding(
                            get: { schedule.weekdays.contains(day) },
                            set: { isOn in
                                if isOn {
                                    schedule.weekdays.insert(day)
                                } else {
                                    schedule.weekdays.remove(day)
                                }
                            }
                        ))
                        .toggleStyle(.button)
                        .font(.caption)
                    }
                }

                HStack {
                    Text("Start:")
                    DatePicker("", selection: startTimeBinding, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    Text("End:")
                    DatePicker("", selection: endTimeBinding, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }
        }
        .padding()
        .frame(width: 320)
    }

    private var startTimeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(from: DateComponents(
                    hour: schedule.startHour, minute: schedule.startMinute)) ?? .now
            },
            set: { date in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                schedule.startHour = comps.hour ?? 9
                schedule.startMinute = comps.minute ?? 0
            }
        )
    }

    private var endTimeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(from: DateComponents(
                    hour: schedule.endHour, minute: schedule.endMinute)) ?? .now
            },
            set: { date in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                schedule.endHour = comps.hour ?? 17
                schedule.endMinute = comps.minute ?? 0
            }
        )
    }
}
