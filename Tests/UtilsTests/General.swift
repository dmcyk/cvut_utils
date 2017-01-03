import XCTest
@testable import Utils
class General: XCTestCase {
    static let allTests = [
        ("testArrayDivision", testArrayDivision),
        ("testBinaryBuffSubscript", testBinaryBuffSubscript),
        ("testBinaryBuffExtend", testBinaryBuffExtend)
    ]
    
    func testArrayDivision() {
        
        for i in 1 ... 20 {
            var src = [Int]()
            for j in 0 ..< i {
                src.append(j)
            }
            for k in 1 ..< i {
                let division = src.divide(withCrossoverPoints: k)
                assert(division.last!.0 <= division.last!.1)
                assert(division.count == k + 1)
            }
        }
        
    }
    
    func testBinaryBuffSubscript() {
        var binbuff = BinaryBuff(capacity: 128)
        
        XCTAssert(binbuff.rawBuff.count == 2)
        XCTAssertThrowsError(try binbuff.get(index: 128))
        
        XCTAssertThrowsError(try binbuff.set(index: -1, value: true))
        
        XCTAssert(!binbuff[0])
        XCTAssert(!binbuff[64])
        XCTAssert(!binbuff[65])
        XCTAssert(!binbuff[126])
        
        binbuff[64] = true
        binbuff[65] = true
        binbuff[126] = true

        XCTAssert(binbuff[64])
        XCTAssert(binbuff[65])
        XCTAssert(binbuff[126])
        
        binbuff[126] = false
        
        XCTAssert(!binbuff[126])
    }
    
    func testBinaryBuffExtend() {
        var binbuff = BinaryBuff(capacity: 62)
        
        XCTAssert(binbuff.rawBuff.count == 1)
        
        binbuff = BinaryBuff(capacity: 64)
        
        XCTAssert(binbuff.rawBuff.count == 1)
        
        binbuff = BinaryBuff(capacity: 65)
        
        XCTAssert(binbuff.rawBuff.count == 2)
        
        binbuff.extend(toCapacity: 129)
        
        XCTAssert(binbuff.rawBuff.count == 3)
        
        
    }
    
    func testBinaryBuffCrossover() {
        var randomWeights = [Double]()
        for _ in 0 ..< MemoryLayout<Int>.size * 8 {
            randomWeights.append(Int.arc4random_uniform_d(Int(Int32.max)))
        }
        let lhs = BinaryBuff(raw: [Int.arc4random_uniform(Int(Int32.max))])
        let rhs = BinaryBuff(raw: [Int.arc4random_uniform(Int(Int32.max))])

        let (son, daughter) = lhs.crossover(with: rhs, upToBits: 64, pointsCount: 3)
        
        let lhsEvaluation = lhs.evaluate(usingWeights: randomWeights)
        let rhsEvaluation = rhs.evaluate(usingWeights: randomWeights)
        let sonEvaluation = son.evaluate(usingWeights: randomWeights)
        let daughterEvaluation = daughter.evaluate(usingWeights: randomWeights)
        
        if (lhsEvaluation != rhsEvaluation) {
            XCTAssert(sonEvaluation != daughterEvaluation && sonEvaluation != lhsEvaluation && daughterEvaluation != rhsEvaluation)
        }
    }
}


