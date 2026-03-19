import SwiftUI

struct TimerPicker: View {
    let onSelect: (TimerPreset) -> Void

    var body: some View {
        ForEach(TimerPreset.defaultPresets) { preset in
            Button(preset.displayName) {
                onSelect(preset)
            }
        }
    }
}
