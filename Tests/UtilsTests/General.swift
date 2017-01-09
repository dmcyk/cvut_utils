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
    
    func testBinaryBuffCmp() {
        let binbuff = try! BinaryBuff(raw: [15], capacity: 4)
        let binbuff2 = try! BinaryBuff(raw: [31], capacity: 4)
        assert(binbuff2.rawBuff[0] == 15)
        assert(binbuff == binbuff2)

    }
}


