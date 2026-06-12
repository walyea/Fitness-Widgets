//
//  widgetsBundle.swift
//  widgets
//
//  Created by Wylan Alyea on 6/2/26.
//

import SwiftUI
import WidgetKit

@main
// Bundle of all the widgets
struct fitnessWidgetBundle: WidgetBundle {
    var body: some Widget {
        fitnessWidget()
        heartRateWidget()
        stepsWidget()
    }
}
