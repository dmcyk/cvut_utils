import XCTest
@testable import Utils
class General: XCTestCase {
    static let allTests = [
        ("testArrayDivision", testArrayDivision)
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
}


