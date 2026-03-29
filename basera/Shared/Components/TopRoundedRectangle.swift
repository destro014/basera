import SwiftUI

struct TopRoundedRectangle: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let clampedRadius = min(max(radius, 0), min(rect.width / 2, rect.height))
        var path = Path()

        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: clampedRadius))
        path.addQuadCurve(
            to: CGPoint(x: clampedRadius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width - clampedRadius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: clampedRadius),
            control: CGPoint(x: rect.width, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}
