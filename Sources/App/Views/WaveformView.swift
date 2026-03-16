import SwiftUI

struct WaveformView: View {
  let level: Float
  let isTranscribing: Bool

  private let dotSize: CGFloat = 12
  private let maxStretch: CGFloat = 60
  private let hopHeight: CGFloat = 20
  private let pulsePeriod: CGFloat = 0.5
  private let hopPeriod: CGFloat = 0.8
  private let dotSpacing: CGFloat = 12

  private let dotColors: [Color] = [
    Color(red: 1.0, green: 0.0, blue: 0.0),
    Color(red: 1.0, green: 0.498, blue: 0.0),
    Color(red: 1.0, green: 1.0, blue: 0.0),
    Color(red: 0.0, green: 1.0, blue: 0.0),
    Color(red: 0.0, green: 0.0, blue: 1.0),
  ]

  private let stretchFactors: [CGFloat] = [0.6, 1.0, 1.4, 1.0, 0.6]
  private let animationDelays: [CGFloat] = [0.0, 0.1, 0.2, 0.3, 0.4]

  var body: some View {
    TimelineView(.animation) { context in
      let time = CGFloat(context.date.timeIntervalSinceReferenceDate)
      let clamped = max(0, min(CGFloat(level), 1))

      HStack(spacing: dotSpacing) {
        ForEach(0..<dotColors.count, id: \.self) { index in
          let delay = animationDelays[index]
          let phaseTime = time + delay

          if isTranscribing {
            let hop = (1 - cos(2 * .pi * phaseTime / hopPeriod)) / 2
            Capsule(style: .continuous)
              .fill(dotColors[index])
              .frame(width: dotSize, height: dotSize)
              .offset(y: -hopHeight * hop)
          } else {
            let baseHeight = dotSize + clamped * maxStretch * stretchFactors[index]
            let pulse = 1 + 0.2 * sin(2 * .pi * phaseTime / pulsePeriod)
            Capsule(style: .continuous)
              .fill(dotColors[index])
              .frame(width: dotSize, height: baseHeight)
              .scaleEffect(x: 1, y: pulse, anchor: .center)
          }
        }
      }
      .frame(height: dotSize + maxStretch * 1.4)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}
