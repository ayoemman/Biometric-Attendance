//
//  UIButton+Adaptive.swift
//  BioAttendance
//
//  Created by AI Assistant on 2025-12-29.
//

import UIKit

extension UIButton {
    /// Apply a primary, prominent adaptive style that looks consistent across devices.
    /// - Ensures minimum tap height, dynamic type font, padding, and rounded corners.
    func applyPrimaryAdaptiveStyle() {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .large
            config.baseBackgroundColor = .tintColor
            config.baseForegroundColor = .white
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = UIFont.preferredFont(forTextStyle: .headline)
                return out
            }
            self.configuration = config
        } else {
            self.backgroundColor = .systemBlue
            self.setTitleColor(.white, for: .normal)
            self.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            self.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            self.layer.cornerRadius = 12
            self.clipsToBounds = true
        }

        self.titleLabel?.adjustsFontForContentSizeCategory = true
        ensureMinimumHeight(48)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Apply a secondary, outlined adaptive style for less prominent actions.
    func applySecondaryAdaptiveStyle() {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.bordered()
            config.cornerStyle = .large
            config.baseForegroundColor = .tintColor
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = UIFont.preferredFont(forTextStyle: .headline)
                return out
            }
            self.configuration = config
        } else {
            self.backgroundColor = .clear
            self.setTitleColor(.tintColor, for: .normal)
            self.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            self.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            self.layer.cornerRadius = 12
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.tintColor.cgColor
            self.clipsToBounds = true
        }

        self.titleLabel?.adjustsFontForContentSizeCategory = true
        ensureMinimumHeight(48)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Ensures the button has at least the provided height. If a fixed height constraint exists
    /// with a smaller constant, it is increased to the minimum. Otherwise, a >= constraint is added.
    func ensureMinimumHeight(_ minHeight: CGFloat) {
        // Try to find an existing height constraint on the button
        if let heightConstraint = self.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .equal }) {
            if heightConstraint.constant < minHeight {
                heightConstraint.constant = minHeight
            }
        } else if self.constraints.first(where: { $0.firstAttribute == .height && $0.relation == .greaterThanOrEqual }) == nil {
            let c = self.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
            c.priority = .required
            c.isActive = true
        }
    }
}

extension UIView {
    /// Recursively applies the primary adaptive style to all UIButtons in the view hierarchy.
    func applyAdaptivePrimaryButtonStyleRecursively() {
        func apply(in view: UIView) {
            for sub in view.subviews {
                if let button = sub as? UIButton {
                    button.applyPrimaryAdaptiveStyle()
                }
                apply(in: sub)
            }
        }
        apply(in: self)
    }
}
