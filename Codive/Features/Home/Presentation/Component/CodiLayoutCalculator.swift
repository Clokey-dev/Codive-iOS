//
//  CodiLayoutCalculator.swift
//  Codive
//
//  Created by 한금준 on 1/15/26.
//

import CoreGraphics

struct CodiLayoutCalculator {

    static func position(
        index: Int,
        totalCount: Int,
        containerSize: CGFloat,
        itemSize: CGFloat = 100
    ) -> CGPoint {

        let center = containerSize / 2

        let stepFor3 = itemSize - 25
        let stepFor4 = itemSize - 36
        let horizontalOverlap: CGFloat = 12
        let horizontalStep = itemSize - horizontalOverlap

        switch totalCount {
        case 1:
            return CGPoint(x: center, y: center)

        case 2:
            let totalW = itemSize + stepFor3
            let startX = (containerSize - totalW) / 2 + (itemSize / 2)
            return CGPoint(
                x: startX + (CGFloat(index) * stepFor3),
                y: center
            )

        case 3:
            let totalH = itemSize + (stepFor3 * 2)
            let startY = (containerSize - totalH) / 2 + (itemSize / 2)
            return CGPoint(
                x: center,
                y: startY + (CGFloat(index) * stepFor3)
            )

        case 4...7:
            let leftCount = (totalCount == 7) ? 4 : 3
            let rightCount = totalCount - leftCount

            let leftStep = (leftCount == 4) ? stepFor4 : stepFor3
            let leftTotalH = itemSize + (leftStep * CGFloat(leftCount - 1))
            let startY = (containerSize - leftTotalH) / 2 + (itemSize / 2)

            let totalW = itemSize + horizontalStep
            let startX = (containerSize - totalW) / 2 + (itemSize / 2)

            let isLeftColumn = index < leftCount
            let internalIndex = isLeftColumn ? index : index - leftCount
            let xPos = isLeftColumn ? startX : startX + horizontalStep

            let currentColumnTotal = isLeftColumn ? leftCount : rightCount
            let step = (currentColumnTotal == 4) ? stepFor4 : stepFor3

            return CGPoint(
                x: xPos,
                y: startY + (CGFloat(internalIndex) * step)
            )

        default:
            return CGPoint(x: center, y: center)
        }
    }
}
