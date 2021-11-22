//
//  PunkApiServiceTests.swift
//  PunkAppTests
//
//  Created by Giuseppe Mazzilli on 20/11/21.
//

import XCTest
@testable import PunkApp

class PunkApiServiceTests: XCTestCase {
    
    func testGetBeers() throws {
        
        let nm: PunkApiService? = PunkApiService()
        
        XCTAssertNotNil(nm)

        let exp = XCTestExpectation(description: "Fetch data from api.punkbeer.com")
        exp.expectedFulfillmentCount = 4
        
        for page in 1..<10 {
            nm?.getBeers(page: page) { beers in
                if beers.count > 0 {
                    debugPrint("Page: \(page) Beers count is: \(beers.count)")
                    exp.fulfill()
                } else {
                    debugPrint("Page: \(page) Beers count is: \(beers.count)")
                }
            }
        }
        
        wait(for: [exp], timeout: 30)
        
    }
    
    func testPrefetchData() throws {
        
        let svm = SearchViewModel()
        
        let exp = XCTestExpectation(description: "Fetch data from api.punkbeer.com")
        exp.expectedFulfillmentCount = 4
        
        svm.fetchData {
            print("Page \(svm.currentPage) fetched.")
            exp.fulfill()
            svm.fetchData {
                print("Page \(svm.currentPage) fetched.")
                exp.fulfill()
                svm.fetchData {
                    print("Page \(svm.currentPage) fetched.")
                    exp.fulfill()
                    svm.fetchData {
                        print("Page \(svm.currentPage) fetched.")
                        exp.fulfill()
                        svm.fetchData {
                            print("Page \(svm.currentPage) fetched.")
                            exp.fulfill()
                        }
                    }
                }
            }
        }
        
        
        for page in 1..<10 {
            svm.fetchData {
                print("Page \(page) fetched.")
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 30)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
