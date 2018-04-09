// RUN: %empty-directory(%t)
// RUN: %target-build-swift %s -o %t/a.out3 -swift-version 3 && %target-run %t/a.out3
// RUN: %target-build-swift %s -o %t/a.out4 -swift-version 4 && %target-run %t/a.out4
// RUN: %target-build-swift %s -o %t/a.out5 -swift-version 5 && %target-run %t/a.out5
// REQUIRES: executable_test

import StdlibUnittest

#if swift(>=4.1)
let swiftVersion = ">=4.1"
#else
let swiftVersion = "<4.1"
#endif

let tests = TestSuite("ReverseCompatibility")

tests.test("Double reverse type/Collection/\(swiftVersion)") {
  func reverse<C : BidirectionalCollection>(_ xs: C) {
    var result = xs.reversed().reversed()
#if swift(>=4.1)
    expectType(C.self, &result)
#else
    expectType(ReversedCollection<ReversedCollection<C>>.self, &result)
#endif
  }
  reverse(Array(0..<10))

  func backwardCompatible<C : BidirectionalCollection>(_ xs: C) {
    typealias ExpectedType = ReversedCollection<ReversedCollection<C>>
    var result: ExpectedType = xs.reversed().reversed()
    expectType(ExpectedType.self, &result)
  }
  backwardCompatible(Array(0..<10))
}

tests.test("Double reverse type/LazyCollection/\(swiftVersion)") {
  func reverse<C : BidirectionalCollection>(_ xs: C) {
    var result = xs.lazy.reversed().reversed()
#if swift(>=4.1)
    expectType(LazyCollection<C.Elements>.self, &result)
#else
    expectType(
      LazyCollection<ReversedCollection<ReversedCollection<C.Elements>>>.self,
      &result)
#endif
  }
  reverse(Array(0..<10).lazy)

  func backwardCompatible<C : BidirectionalCollection>(_ xs: C) {
    typealias ExpectedType =
      LazyCollection<ReversedCollection<ReversedCollection<C.Elements>>>
    var result: ExpectedType = xs.lazy.reversed().reversed()
    expectType(ExpectedType.self, &result)
  }
  backwardCompatible(Array(0..<10).lazy)
}
