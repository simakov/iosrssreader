//
//  Shimmer.swift
//  NewsRSSReader
//
//  Native shimmer overlay. Pairs with `.redacted(reason: .placeholder)`,
//  which provides the skeleton shape; this modifier adds the moving highlight.
//  Uses `phaseAnimator` on iOS 17+, with a gradient-animation fallback on iOS 16.x.
//

import SwiftUI

public extension View {
    /// Adds an animated shimmering highlight to any view, typically to show that an
    /// operation is in progress. Best combined with `.redacted(reason: .placeholder)`.
    /// - Parameter active: Convenience flag to conditionally enable the effect.
    @ViewBuilder func shimmering(active: Bool = true) -> some View {
        if active {
            modifier(ShimmerModifier())
        } else {
            self
        }
    }
}

/// The size of the animated band, as a fraction of the gradient's extent.
private let bandSize: CGFloat = 0.3
/// Unit-point bounds extended beyond the view's edges by the band size, so the
/// highlight can start fully off-screen and travel completely across and out.
private let minPoint: CGFloat = 0 - bandSize
private let maxPoint: CGFloat = 1 + bandSize

/// A gradient with a translucent → opaque → translucent band used as a mask.
private let shimmerGradient = Gradient(colors: [
    .black.opacity(0.3),
    .black,
    .black.opacity(0.3)
])

/// Builds the masking gradient for a given animation phase.
/// `animated == false` is the initial (off-screen) position; `true` is the final one.
private func shimmerMask(animated: Bool) -> some View {
    let start = animated ? UnitPoint(x: 1, y: 1) : UnitPoint(x: minPoint, y: minPoint)
    let end = animated ? UnitPoint(x: maxPoint, y: maxPoint) : UnitPoint(x: 0, y: 0)
    return LinearGradient(gradient: shimmerGradient, startPoint: start, endPoint: end)
}

/// Dispatches to the best available implementation based on OS version.
private struct ShimmerModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.modifier(PhaseShimmer())
        } else {
            content.modifier(LegacyShimmer())
        }
    }
}

/// iOS 17+ implementation driven by the native `phaseAnimator`.
@available(iOS 17.0, *)
private struct PhaseShimmer: ViewModifier {
    func body(content: Content) -> some View {
        content.phaseAnimator([false, true]) { view, phase in
            view.mask(shimmerMask(animated: phase))
        } animation: { _ in
            .linear(duration: 1.5).delay(0.25)
        }
    }
}

/// Fallback for iOS 16.x: a repeating gradient animation driven by state.
private struct LegacyShimmer: ViewModifier {
    @State private var animating = false

    func body(content: Content) -> some View {
        content
            .mask(shimmerMask(animated: animating))
            .animation(.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false), value: animating)
            .onAppear { animating = true }
    }
}
