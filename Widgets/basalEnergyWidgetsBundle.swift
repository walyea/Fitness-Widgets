//
//  widgetsBundle.swift
//  widgets
//
//  Created by Wylan Alyea on 6/2/26.
//

import WidgetKit
import SwiftUI

@main
// Bundle of all the widgets
struct fitnessWidgetBundle: WidgetBundle {
    var body: some Widget {
        fitnessWidget()
        heartRateWidget()
        stepsWidget()
    }
}

