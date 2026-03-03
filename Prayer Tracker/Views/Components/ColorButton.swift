//
//  ColorButton.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.03.26.
//

import SwiftUI

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)

                if isSelected {
                    Circle()
                        .strokeBorder(.white, lineWidth: 3)
                        .frame(width: 44, height: 44)
                }
            }
        }
    }
}
