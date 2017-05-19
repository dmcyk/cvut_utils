import XCTest
@testable import Utils
class General: XCTestCase {
    static let allTests = [
        ("testArrayDivision", testArrayDivision),
        ("testBinaryBuffSubscript", testBinaryBuffSubscript),
        ("testBinaryBuffExtend", testBinaryBuffExtend),
        ("testBinaryBuffCmp", testBinaryBuffCmp),
        ("testBinaryBuffCmp2", testBinaryBuffCmp2),
        ("testBinaryBuffSetPerformance", testBinaryBuffSetPerformance),
        ("testArraySetPerformance", testArraySetPerformance),
        ("testBinaryBuffGetPerformance", testBinaryBuffGetPerformance),
        ("testArrayGetPerformance", testArrayGetPerformance),
        ("testBinaryBuffCopyPerformance", testBinaryBuffCopyPerformance),
        ("testArrayCopyPerformance", testArrayCopyPerformance)
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
        var binbuff = BinaryBuff<Int>(capacity: 128)
        
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
        var binbuff = BinaryBuff<Int>(capacity: 62)
        
        XCTAssert(binbuff.rawBuff.count == 1)
        
        binbuff = BinaryBuff(capacity: 64)
        
        XCTAssert(binbuff.rawBuff.count == 1)
        
        binbuff = BinaryBuff(capacity: 65)
        
        XCTAssert(binbuff.rawBuff.count == 2)
        
        binbuff.extend(toCapacity: 129)
        
        XCTAssert(binbuff.rawBuff.count == 3)
        
        
    }
    
    func testBinaryBuffCmp() {
        let binbuff = try! BinaryBuff<Int>(raw: [15], capacity: 4)
        let binbuff2 = try! BinaryBuff<Int>(raw: [31], capacity: 4)
        assert(binbuff2.rawBuff[0] == 15)
        assert(binbuff == binbuff2)

    }
    
    func testBinaryBuffCmp2() {
        let binbuff = try! BinaryBuff<Int>(raw: [614689], capacity: 20)
        let binbuff2 = try! BinaryBuff<Int>(raw: [17595227529505], capacity: 20)
        assert(binbuff == binbuff2)
        
        let seq = [binbuff]
        assert(seq.contains(binbuff2))
    }
    
    func testBinaryBuffSetPerformance() {
        var binbuff = BinaryBuff<Int>(capacity: 500000)
        
        measure {
            for i in 0 ..< 500000 {
                binbuff[i] = true
            }
        }
        
    }
    
    func testIntBinaryBuffSetPerformance() {
        var binbuff = IntBinaryBuff(capacity: 500000)
        
        measure {
            for i in 0 ..< 500000 {
                binbuff[i] = true
            }
        }
        
    }
    
    func testBinaryBuffRawSetPerformance() {
        var binbuff = BinaryBuff<Int>(capacity: 500000)
        
        measure {
            for i in 0 ..< 500000 {
                try! binbuff.set(index: i, value: true)
            }
        }
        
    }
    
    func testIntBinaryBuffRawSetPerformance() {
        var binbuff = IntBinaryBuff(capacity: 500000)
        
        measure {
            for i in 0 ..< 500000 {
                try! binbuff.set(index: i, value: true)
            }
        }
        
    }
    
    func testArraySetPerformance() {
        var arr = [Bool]()
        for _ in 0 ..< 500000 {
            arr.append(false)
        }
        measure {
            for i in 0 ..< 500000 {
                arr[i] = true
            }
        }
    }
    
    func testBinaryBuffGetPerformance() {
        var binbuff = BinaryBuff<Int>(capacity: 500000)
        for i in 0 ..< 500000 {
            binbuff[i] = true
        }
        measure {
            for i in 0 ..< 500000 {
                let _ = binbuff[i]
            }
        }
    }
    
    func testIntBinaryBuffGetPerformance() {
        var binbuff = IntBinaryBuff(capacity: 500000)
        for i in 0 ..< 500000 {
            binbuff[i] = true
        }
        measure {
            for i in 0 ..< 500000 {
                let _ = binbuff[i]
            }
        }
    }
    
    func testBinaryBuffRawGetPerformance() {
        var binbuff = BinaryBuff<Int>(capacity: 500000)
        for i in 0 ..< 500000 {
            binbuff[i] = true
        }
        measure {
            for i in 0 ..< 500000 {
                let _ = try! binbuff.get(index: i)
            }
        }
    }
    
    func testIntBinaryBuffRawGetPerformance() {
        var binbuff = IntBinaryBuff(capacity: 500000)
        for i in 0 ..< 500000 {
            binbuff[i] = true
        }
        measure {
            for i in 0 ..< 500000 {
                let _ = try! binbuff.get(index: i)
            }
        }
    }
    
    func testArrayGetPerformance() {
        var arr = [Bool]()
        arr.reserveCapacity(500000)
        for _ in 0 ..< 500000 {
            arr.append(true)
        }
        measure {
            for i in 0 ..< 500000 {
                let _ = arr[i]
            }
        }
    }
    
    func testBinaryBuffCopyPerformance() {
        var binbuff = BinaryBuff<Int>(capacity: 50000)
        for i in 0 ..< 50000 {
            binbuff[i] = true
        }
        measure {
            for _ in 0 ..< 50000 {
                var new = binbuff
                new[0] = false
                new[1] = false
            }
        }
        
    }
    
    func testIntBinaryBuffCopyPerformance() {
        var binbuff = IntBinaryBuff(capacity: 50000)
        for i in 0 ..< 50000 {
            binbuff[i] = true
        }
        measure {
            for _ in 0 ..< 50000 {
                var new = binbuff
                new[0] = false
                new[1] = false
            }
        }
        
    }
    
    func testArrayCopyPerformance() {
        var arr = [Bool]()
        arr.reserveCapacity(50000)
        for _ in 0 ..< 50000 {
            arr.append(true)
        }
        measure {
            for _ in 0 ..< 50000 {
                var new = arr
                new[0] = false
                new[1] = false

            }
        }
    }
    
}


