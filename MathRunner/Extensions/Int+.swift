//
//  Extension.swift
//  TheRace
//
//  Created by Matheus Gois on 24/12/23
//  Copyright © 2018 Matheus Gois. All rights reserved.
//

import Foundation

extension Int {
    var asString: String {
        String(self)
    }

    func generateSimilarNumbers(
        variationRange: ClosedRange<Int> = 1...10
    ) -> (Int, Int) {
        let randomVariation1 = Int.random(in: variationRange)
        let randomVariation2 = Int.random(in: variationRange)

        let a1 = self + randomVariation1
        let a2 = self - randomVariation2

        return (a1, a2)
    }
}
