//MIT License
//
//Copyright (c) 2019 Dilip-Parmar
//
//Permission is hereby granted, free of charge, to any Car obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit Cars to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
@testable import CoreDataWrapper_iOS
import XCTest

class AsyncOperationsTests: XCTestCase {
    
    private var coreDataWrapper: CoreDataWrapper!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.coreDataWrapper = CoreDataWrapper.init(modelFileName: "CoreDataWrapper",
                                                    databaseFileName: "CoreDataWrapper",
                                                    bundle: Bundle(for: AsyncOperationsTests.self),
                                                    storeType: .inMemory)
        
        let loadExpectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        self.coreDataWrapper.loadStore { (isSuccess, error) in
            XCTAssert(isSuccess)
            XCTAssertNil(error)
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5.0)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitializationAsync() {
        
        XCTAssertNotNil(coreDataWrapper)
    }
    
    func testAddObjAsync() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        self.coreDataWrapper.addAsyncOf(type: Car.self) { (car) in
            XCTAssertNotNil(car)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddObjWidPropsAsync() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        self.coreDataWrapper.addAsyncOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: false, completion: { (car) in
            
            XCTAssertNotNil(car)
            
            XCTAssertEqual(car?.model, "Audi")
            XCTAssertEqual(car?.regNo, 30)
            
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchObjAsync() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        self.coreDataWrapper.fetchAsyncBy(type: Car.self,
                                          objectId: car!.objectID,
                                          context: nil, completion: { (car) in
                                            XCTAssertNotNil(car)
                                            XCTAssertEqual(car!.model, "Audi")
                                            XCTAssertEqual(car!.regNo, 30)
                                            expectation.fulfill()
                                            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteObjAsync() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        
        self.coreDataWrapper.deleteAsyncBy(objectId: car!.objectID, shouldSave: true, completion: { (isDeleted) in
            
            XCTAssert(isDeleted)
            
            let fetched = self.coreDataWrapper.fetchBy(objectId: car!.objectID) as? Car
            XCTAssertNil(fetched)
            expectation.fulfill()
        }, completionOnMainThread: false)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchAllAsync() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        self.coreDataWrapper.fetchAllAsyncOf(type: Car.self, sortBy: ["model" : true], completion: { (fetched) in
            XCTAssertEqual(fetched?.count, 3)
            expectation.fulfill()
        }, completionOnMainThread: false)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteAllAsync() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        
        self.coreDataWrapper.deleteAllAsyncOf(type: Car.self, shouldSave: false, completion: { (isDeleted) in
            
            XCTAssert(isDeleted)
            
            let fetched = self.coreDataWrapper.fetchAllOf(type: Car.self, sortBy: ["model" : true])
            XCTAssertEqual(fetched?.count, 0)
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    func testUpdateObjAsync() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        
        self.coreDataWrapper.updateAsyncBy(objectId: car!.objectID, properties: ["model": "dp1", "regNo": 40], shouldSave: true, completion: { (isUpdated) in
            
            XCTAssert(isUpdated)
            
            XCTAssertEqual(car?.model, "dp1")
            XCTAssertEqual(car?.regNo, 40)
            
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateAllAsync() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: false)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        
        self.coreDataWrapper.updateAllAsyncOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: true, completion: { (updated) in
            
            XCTAssert(updated)
            
            let fetched = self.coreDataWrapper.fetchAllOf(type: Car.self, sortBy: ["model" : true])
            XCTAssertEqual(fetched?.count, 3)
            
            let filtered = fetched!.filter { (car) -> Bool in
                car.model == "Audi" && car.regNo == 30
            }
            XCTAssertEqual(filtered.count, 3)
            expectation.fulfill()
        }, completionOnMainThread: false)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCountAsync() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: false)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        self.coreDataWrapper.countAsyncOf(type: Car.self, predicate: nil, completion: { (count) in
            XCTAssertEqual(count, 3)
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchPropertiesAsync() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        self.coreDataWrapper.fetchPropertiesAsyncOf(type: Car.self, propertiesToFetch: ["model", "regNo"], completion: { (properties) in
            XCTAssertNotNil(properties)
            XCTAssertEqual(properties?.count, 3)
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPerformOperationAsync() {
        let coreDataWrapper = CoreDataWrapper.init(modelFileName: "CoreDataWrapper",
                                                   databaseFileName: "CoreDataWrapper",
                                                   bundle: Bundle(for: AsyncOperationsTests.self),
                                                   storeType: .sqlite)
        XCTAssertNotNil(coreDataWrapper)
        
        let loadExpectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.loadStore { (isSuccess, error) in
            XCTAssert(isSuccess)
            XCTAssertNil(error)
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5.0)
        
        let car1 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.performOperationAsync(operation: .sum, type: Car.self, propertyName: "regNo", completion: { (sum) in
            XCTAssertNotNil(sum)
            XCTAssertEqual(sum!.first!["regNo"] as! Int, 70)
            expectation.fulfill()
        }, completionOnMainThread: false)
        
        wait(for: [expectation], timeout: 1.0)
        
        coreDataWrapper.purgeStore()
    }
    
    func testUpdateAllSqliteAsync() {
        let coreDataWrapper = CoreDataWrapper.init(modelFileName: "CoreDataWrapper",
                                                   databaseFileName: "CoreDataWrapper",
                                                   bundle: Bundle(for: AsyncOperationsTests.self),
                                                   storeType: .sqlite)
        XCTAssertNotNil(coreDataWrapper)
        
        let loadExpectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.loadStore { (isSuccess, error) in
            XCTAssert(isSuccess)
            XCTAssertNil(error)
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5.0)
        
        let car1 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.updateAllAsyncOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: true, completion: { (updated) in
            
            XCTAssert(updated)
            
            let fetched = coreDataWrapper.fetchAllOf(type: Car.self, sortBy: ["model" : true])
            XCTAssertEqual(fetched?.count, 3)
            
            let filtered = fetched!.filter { (car) -> Bool in
                car.model == "Audi" && car.regNo == 30
            }
            XCTAssertEqual(filtered.count, 3)
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
        
        coreDataWrapper.purgeStore()
    }
    
    func testUpdateAllSqliteAsyncMainThread() {
        let coreDataWrapper = CoreDataWrapper.init(modelFileName: "CoreDataWrapper",
                                                   databaseFileName: "CoreDataWrapper",
                                                   bundle: Bundle(for: AsyncOperationsTests.self),
                                                   storeType: .sqlite)
        XCTAssertNotNil(coreDataWrapper)
        
        let loadExpectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.loadStore { (isSuccess, error) in
            XCTAssert(isSuccess)
            XCTAssertNil(error)
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5.0)
        
        let car1 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.updateAllAsyncOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: false, completion: { (updated) in
            
            XCTAssert(updated)
            
            let fetched = coreDataWrapper.fetchAllOf(type: Car.self, sortBy: ["model" : true])
            XCTAssertEqual(fetched?.count, 3)
            
            let filtered = fetched!.filter { (car) -> Bool in
                car.model == "Audi" && car.regNo == 30
            }
            XCTAssertEqual(filtered.count, 3)
            expectation.fulfill()
            
        }, completionOnMainThread: true)
        wait(for: [expectation], timeout: 1.0)
        
        coreDataWrapper.purgeStore()
    }
    
    func testUpdateAllSqliteAsyncMainThreadBGContext() {
        let coreDataWrapper = CoreDataWrapper.init(modelFileName: "CoreDataWrapper",
                                                   databaseFileName: "CoreDataWrapper",
                                                   bundle: Bundle(for: AsyncOperationsTests.self),
                                                   storeType: .sqlite)
        XCTAssertNotNil(coreDataWrapper)
        
        let loadExpectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.loadStore { (isSuccess, error) in
            XCTAssert(isSuccess)
            XCTAssertNil(error)
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5.0)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let context = coreDataWrapper.newBgContext()
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.updateAllAsyncOf(type: Car.self, context: context, properties: ["model": "Audi", "regNo": 30], shouldSave: false, completion: { (updated) in
            
            XCTAssert(updated)
            XCTAssert(Thread.isMainThread)
            
            expectation.fulfill()
            
        }, completionOnMainThread: true)
        wait(for: [expectation], timeout: 1.0)
        
        coreDataWrapper.purgeStore()
    }
    
    
    func testDeleteAllSqliteAsync() {
        let coreDataWrapper = CoreDataWrapper.init(modelFileName: "CoreDataWrapper",
                                                   databaseFileName: "CoreDataWrapper",
                                                   bundle: Bundle(for: AsyncOperationsTests.self),
                                                   storeType: .sqlite)
        XCTAssertNotNil(coreDataWrapper)
        
        let loadExpectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.loadStore { (isSuccess, error) in
            XCTAssert(isSuccess)
            XCTAssertNil(error)
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5.0)
        
        let car1 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.deleteAllAsyncOf(type: Car.self, shouldSave: true, completion: { (isDeleted) in
            
            XCTAssert(isDeleted)
            let fetched = coreDataWrapper.fetchAllOf(type: Car.self, sortBy: nil)
            XCTAssertEqual(fetched?.count, 0)
            
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
        
       coreDataWrapper.purgeStore()
    }
    
    // MARK: - BG Context Test cases
    func testAddObjAsyncWidBGContext() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.addAsyncOf(type: Car.self, context: context) { (car) in
            XCTAssertNotNil(car)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddObjWidPropsAsyncWidBGContext() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let context = self.coreDataWrapper.newBgContext()
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        self.coreDataWrapper.addAsyncOf(type: Car.self, context: context, properties: ["model": "Audi", "regNo": 30], shouldSave: false, completion: { (car) in
            
            XCTAssertNotNil(car)
            
            XCTAssertEqual(car?.model, "Audi")
            XCTAssertEqual(car?.regNo, 30)
            
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAddObjWidPropsAsyncWidBGContextMainThread() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let context = self.coreDataWrapper.newBgContext()
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        self.coreDataWrapper.addAsyncOf(type: Car.self, context: context, properties: ["model": "Audi", "regNo": 30], shouldSave: false, completion: { (car) in
            
            XCTAssertNotNil(car)
            
            XCTAssertEqual(car?.model, "Audi")
            XCTAssertEqual(car?.regNo, 30)
            
            XCTAssert(Thread.isMainThread)
            
            expectation.fulfill()
        }, completionOnMainThread: true)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchObjAsyncWidBGContext() {
        
        XCTAssertNotNil(coreDataWrapper)
        let car = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: true)
        XCTAssertNotNil(car)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.fetchAsyncBy(type: Car.self, objectId: car!.objectID, context: context, completion: { (car) in
            XCTAssertNotNil(car)
            XCTAssertEqual(car!.model, "Audi")
            XCTAssertEqual(car!.regNo, 30)
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchObjAsyncWidBGContextMainThread() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: true)
        XCTAssertNotNil(car)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.fetchAsyncBy(type: Car.self, objectId: car!.objectID, context: context, completion: { (car) in
            XCTAssertNotNil(car)
            XCTAssertEqual(car!.model, "Audi")
            XCTAssertEqual(car!.regNo, 30)
            expectation.fulfill()
            
            XCTAssert(Thread.isMainThread)
            
        }, completionOnMainThread: true)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteObjAsyncWidBGContext() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: true)
        XCTAssertNotNil(car)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        
        self.coreDataWrapper.deleteAsyncBy(objectId: car!.objectID, context: context, shouldSave: true, completion: { (isDeleted) in
            
            XCTAssert(isDeleted)
            
            let fetched = self.coreDataWrapper.fetchBy(objectId: car!.objectID) as? Car
            XCTAssert(fetched!.isDeleted)
            
            expectation.fulfill()
            
        }, completionOnMainThread: true)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteObjAsyncWidBGContextMainThread() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: true)
        XCTAssertNotNil(car)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.deleteAsyncBy(objectId: car!.objectID, context: context, shouldSave: true, completion: {  (isDeleted) in
            
            XCTAssert(isDeleted)
            
            let fetched = self.coreDataWrapper.fetchBy(objectId: car!.objectID) as? Car
            XCTAssert(fetched!.isDeleted)
            XCTAssert(Thread.isMainThread)
            
            expectation.fulfill()
        }, completionOnMainThread: true)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchAllAsyncWidBGContext() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 30], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.fetchAllAsyncOf(type: Car.self, context: context, sortBy: ["model" : true], completion: { (fetched) in
            XCTAssertEqual(fetched?.count, 3)
            
            expectation.fulfill()
        }, completionOnMainThread: false)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchAllAsyncWidBGContextMainThread() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 30], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.fetchAllAsyncOf(type: Car.self, context: context, sortBy: ["model" : true], completion: { (fetched) in
            XCTAssertEqual(fetched?.count, 3)
            XCTAssert(Thread.isMainThread)
            
            expectation.fulfill()
        }, completionOnMainThread: true)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteAllAsyncWidBGContext() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 30], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.deleteAllAsyncOf(type: Car.self, context: context, shouldSave: true, completion: { (isDeleted) in
            
            XCTAssert(isDeleted)
            
            let fetched = self.coreDataWrapper.fetchAllOf(type: Car.self, sortBy: ["model" : true])
            XCTAssertEqual(fetched?.count, 0)
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteAllAsyncWidBGContextMainThread() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 30], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 30], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.deleteAllAsyncOf(type: Car.self, context: context, shouldSave: true, completion: { (isDeleted) in
            
            XCTAssert(isDeleted)
            
            let fetched = self.coreDataWrapper.fetchAllOf(type: Car.self, sortBy: ["model" : true])
            XCTAssertEqual(fetched?.count, 0)
            XCTAssert(Thread.isMainThread)
            
            expectation.fulfill()
        }, completionOnMainThread: true)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateObjAsyncWidBGContext() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: true)
        XCTAssertNotNil(car)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.updateAsyncBy(objectId: car!.objectID, context: context, properties: ["model": "dp1", "regNo": 40], shouldSave: true, completion: { (isUpdated) in
            
            XCTAssert(isUpdated)
            
            let car = self.coreDataWrapper.fetchBy(objectId: car!.objectID) as? Car
            XCTAssertEqual(car!.model, "dp1")
            XCTAssertEqual(car!.regNo, 40)
            
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateObjAsyncWidBGContextMainThread() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: true)
        XCTAssertNotNil(car)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.updateAsyncBy(objectId: car!.objectID, context: context, properties: ["model": "dp1", "regNo": 40], shouldSave: true, completion: { (isUpdated) in
            
            XCTAssert(isUpdated)
            
            let car = self.coreDataWrapper.fetchBy(objectId: car!.objectID) as? Car
            XCTAssertEqual(car?.model, "dp1")
            XCTAssertEqual(car?.regNo, 40)
            XCTAssert(Thread.isMainThread)
            expectation.fulfill()
            
        }, completionOnMainThread: true)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateObjAsyncWidBGContextMainThreadSave() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "Audi", "regNo": 30], shouldSave: true)
        XCTAssertNotNil(car)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.updateAsyncBy(objectId: car!.objectID, context: context, properties: ["model": "dp1", "regNo": 40], shouldSave: false, completion: { (isUpdated) in
            
            XCTAssert(isUpdated)
            
            XCTAssert(Thread.isMainThread)
            expectation.fulfill()
            
        }, completionOnMainThread: true)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateAllAsyncWidBGContext() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.updateAllAsyncOf(type: Car.self, context: context, properties: ["model": "Audi", "regNo": 30], shouldSave: true, completion: { (updated) in
            
            XCTAssert(updated)
            
            let fetched = self.coreDataWrapper.fetchAllOf(type: Car.self, sortBy: ["model" : true])
            XCTAssertEqual(fetched?.count, 3)
            
            let filtered = fetched!.filter { (car) -> Bool in
                car.model == "Audi" && car.regNo == 30
            }
            XCTAssertEqual(filtered.count, 3)
            expectation.fulfill()
        }, completionOnMainThread: false)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateAllAsyncWidBGContextMainThread() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.updateAllAsyncOf(type: Car.self, context: context, properties: ["model": "Audi", "regNo": 30], shouldSave: true, completion: { (updated) in
            
            XCTAssert(updated)
            
            let fetched = self.coreDataWrapper.fetchAllOf(type: Car.self, sortBy: ["model" : true])
            XCTAssertEqual(fetched?.count, 3)
            
            let filtered = fetched!.filter { (car) -> Bool in
                car.model == "Audi" && car.regNo == 30
            }
            XCTAssertEqual(filtered.count, 3)
            XCTAssert(Thread.isMainThread)
            
            expectation.fulfill()
        }, completionOnMainThread: true)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCountAsyncWidBGContext() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.countAsyncOf(type: Car.self, context: context, predicate: nil, completion: { (count) in
            XCTAssertEqual(count, 3)
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCountAsyncWidBGContextMainThread() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.countAsyncOf(type: Car.self, context: context, predicate: nil, completion: { (count) in
            XCTAssertEqual(count, 3)
            XCTAssert(Thread.isMainThread)
            
            expectation.fulfill()
        }, completionOnMainThread: true)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchPropertiesAsyncWidBGContext() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.fetchPropertiesAsyncOf(type: Car.self, context: context, propertiesToFetch: ["model", "regNo"], completion: { (properties) in
            XCTAssertNotNil(properties)
            XCTAssertEqual(properties?.count, 3)
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchPropertiesAsyncWidBGContextMainThread() {
        
        XCTAssertNotNil(coreDataWrapper)
        
        let car1 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = self.coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = self.coreDataWrapper.newBgContext()
        self.coreDataWrapper.fetchPropertiesAsyncOf(type: Car.self, context: context, propertiesToFetch: ["model", "regNo"], completion: { (properties) in
            XCTAssertNotNil(properties)
            XCTAssertEqual(properties?.count, 3)
            XCTAssert(Thread.isMainThread)
            
            expectation.fulfill()
        }, completionOnMainThread: true)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPerformOperationAsyncWidBGContext() {
        let coreDataWrapper = CoreDataWrapper.init(modelFileName: "CoreDataWrapper",
                                                   databaseFileName: "CoreDataWrapper",
                                                   bundle: Bundle(for: AsyncOperationsTests.self),
                                                   storeType: .sqlite)
        XCTAssertNotNil(coreDataWrapper)
        
        let loadExpectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.loadStore { (isSuccess, error) in
            XCTAssert(isSuccess)
            XCTAssertNil(error)
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5.0)
        
        let car1 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = coreDataWrapper.newBgContext()
        coreDataWrapper.performOperationAsync(operation: .sum, type: Car.self, context: context, propertyName: "regNo", completion: { (sum) in
            XCTAssertNotNil(sum)
            XCTAssertEqual(sum!.first!["regNo"] as! Int, 70)
            expectation.fulfill()
        }, completionOnMainThread: false)
        
        wait(for: [expectation], timeout: 1.0)
        
        coreDataWrapper.purgeStore()
    }
    
    func testPerformOperationAsyncWidBGContextMainThread() {
        let coreDataWrapper = CoreDataWrapper.init(modelFileName: "CoreDataWrapper",
                                                   databaseFileName: "CoreDataWrapper",
                                                   bundle: Bundle(for: AsyncOperationsTests.self),
                                                   storeType: .sqlite)
        XCTAssertNotNil(coreDataWrapper)
        
        let loadExpectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.loadStore { (isSuccess, error) in
            XCTAssert(isSuccess)
            XCTAssertNil(error)
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5.0)
        
        let car1 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = coreDataWrapper.newBgContext()
        coreDataWrapper.performOperationAsync(operation: .sum, type: Car.self, context: context, propertyName: "regNo", completion: { (sum) in
            XCTAssertNotNil(sum)
            XCTAssertEqual(sum!.first!["regNo"] as! Int, 70)
            XCTAssert(Thread.isMainThread)
            
            expectation.fulfill()
        }, completionOnMainThread: true)
        
        wait(for: [expectation], timeout: 1.0)
        
        coreDataWrapper.purgeStore()
    }
    
    func testUpdateAllSqliteAsyncWidBGContext() {
        let coreDataWrapper = CoreDataWrapper.init(modelFileName: "CoreDataWrapper",
                                                   databaseFileName: "CoreDataWrapper",
                                                   bundle: Bundle(for: AsyncOperationsTests.self),
                                                   storeType: .sqlite)
        XCTAssertNotNil(coreDataWrapper)
        
        let loadExpectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.loadStore { (isSuccess, error) in
            XCTAssert(isSuccess)
            XCTAssertNil(error)
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5.0)
        
        let car1 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = coreDataWrapper.newBgContext()
        coreDataWrapper.updateAllAsyncOf(type: Car.self, context: context, properties: ["model": "Audi", "regNo": 30], shouldSave: true, completion: { (updated) in
            
            XCTAssert(updated)
            
            let fetched = coreDataWrapper.fetchAllOf(type: Car.self, sortBy: ["model" : true])
            XCTAssertEqual(fetched?.count, 3)
            
            let filtered = fetched!.filter { (car) -> Bool in
                car.model == "Audi" && car.regNo == 30
            }
            XCTAssertEqual(filtered.count, 3)
            expectation.fulfill()
            
        }, completionOnMainThread: true)
        wait(for: [expectation], timeout: 1.0)
        
        coreDataWrapper.purgeStore()
    }
    
    func testDeleteAllSqliteAsyncWidBGContext() {
        let coreDataWrapper = CoreDataWrapper.init(modelFileName: "CoreDataWrapper",
                                                   databaseFileName: "CoreDataWrapper",
                                                   bundle: Bundle(for: AsyncOperationsTests.self),
                                                   storeType: .sqlite)
        XCTAssertNotNil(coreDataWrapper)
        
        let loadExpectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        coreDataWrapper.loadStore { (isSuccess, error) in
            XCTAssert(isSuccess)
            XCTAssertNil(error)
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5.0)
        
        let car1 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp1", "regNo": 10], shouldSave: false)
        XCTAssertNotNil(car1)
        
        let car2 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp2", "regNo": 20], shouldSave: false)
        XCTAssertNotNil(car2)
        
        let car3 = coreDataWrapper.addOf(type: Car.self, properties: ["model": "dp3", "regNo": 40], shouldSave: true)
        XCTAssertNotNil(car3)
        
        let expectation = XCTestExpectation.init(description: "\(#file)\(#line)")
        let context = coreDataWrapper.newBgContext()
        coreDataWrapper.deleteAllAsyncOf(type: Car.self, context: context, shouldSave: true, completion: { (isDeleted) in
            
            XCTAssert(isDeleted)
            
            let fetched = coreDataWrapper.fetchAllOf(type: Car.self, sortBy: nil)
            XCTAssertEqual(fetched?.count, 0)
            
            expectation.fulfill()
            
        }, completionOnMainThread: false)
        wait(for: [expectation], timeout: 1.0)
        
        coreDataWrapper.purgeStore()
    }
}
