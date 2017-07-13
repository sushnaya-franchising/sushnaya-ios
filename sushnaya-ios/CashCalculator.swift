//
//  CashCalculator.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 6/29/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation


class CashCalculator {
    
    typealias Row = [Bool]
    typealias Matrix = [Row]
    
    fileprivate let faces: [Int]
    fileprivate let monetaryUnitCentsCount: Int
    fileprivate var changeMatrix: Matrix?
    
    init(faces: Set<CGFloat>, monetaryUnitCentsCount: Int, initialMaxPrice: CGFloat = 5000) {
        self.monetaryUnitCentsCount = monetaryUnitCentsCount
        self.faces = faces.map { $0.getCents(monetaryUnitCentsCount) }.sorted(by: >)
        self.changeMatrix = computeChangeMatrix(initialMaxPrice.getCents(monetaryUnitCentsCount))
    }
    
    func getPossibleCashValues(price: CGFloat) -> [CGFloat]? {
        return getPossibleCashValues(priceCents: price.getCents(monetaryUnitCentsCount))
    }
    
    private func getPossibleCashValues(priceCents: Int) -> [CGFloat]? {
        guard let firstRow = changeMatrix?.first else { return nil }
        guard let firstFaceCents = faces.first else { return nil }
        
        let maxSumInMatrix = firstRow.count - 1
        let maxSumInResult = priceCents + firstFaceCents
        
        if maxSumInResult > maxSumInMatrix { extendChangeMatrix(maxSumInResult) }
        
        var result = [Int]()
        
        var n = faces.count
        var currentSum = priceCents + 1
        
        while n > 0 && currentSum < maxSumInResult {
            if currentSum - priceCents >= faces[n - 1] {
                n -= 1
            
            } else {
                if changeMatrix![n][currentSum] {
                    result.append(currentSum)
                }
                
                currentSum += 1
            }
        }
        
        return result.map { CGFloat($0) / CGFloat(monetaryUnitCentsCount) }
    }
}

fileprivate extension CashCalculator {
    fileprivate func computeChangeMatrix(_ price: Int) -> Matrix? {
        guard let firstFace = faces.first else { return nil }
        
        var matrix = Matrix()
        
        var row = Row(repeating: false, count: price + firstFace + 1)
        row[0] = true
        
        matrix.append(row)
        
        for n in 1...faces.count {
            matrix.append(computeChangeMatrixRow(n, prevRow: matrix[n-1]))
        }
        
        return matrix
    }
    
    fileprivate func computeChangeMatrixRow(_ facesCount: Int, prevRow: Row) -> Row {
        return computeChangeMatrixRow(fromIdx: 0, untilIdx: prevRow.count, facesCount: facesCount, prevRow: prevRow)
    }
    
    fileprivate func computeChangeMatrixRow(fromIdx: Int, untilIdx: Int, facesCount: Int, prevRow: Row) -> Row {
        var row = Row()
        
        for sum in fromIdx..<untilIdx {
            let sumIsRepresentable = sum == 0 || prevRow[sum] ||
                faces[0..<facesCount].first(where: { faceValue in
                    let sumWithoutValue = sum - faceValue
                    return sumWithoutValue >= 0 && row[sumWithoutValue]
                }) != nil
            
            row.append(sumIsRepresentable)
        }
        
        return row
    }
    
    fileprivate func extendChangeMatrix(_ newMax: Int) {
        guard let firstRow = changeMatrix?.first else { return }
        
        let oldMax = firstRow.count - 1
        let sumDiff = newMax - firstRow.count + 1
        
        changeMatrix?[0].append(contentsOf: Row(repeating: false, count: sumDiff))
        
        for n in 1...faces.count {
            let _ = computeChangeMatrixRow(fromIdx: oldMax, untilIdx: newMax,
                                           facesCount: n, prevRow: changeMatrix![n-1]) // todo: fix bug here
        }
    }
}

fileprivate extension CGFloat {
    func getCents(_ monetaryUnitCentsCount: Int) -> Int {
        return Int(floor(self * CGFloat(monetaryUnitCentsCount)))
    }
}
