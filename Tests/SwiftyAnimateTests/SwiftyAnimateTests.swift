//
//  SwiftyAnimateTests.swift
//  SwiftyAnimateTests
//
//  Created by Reid Chatham on 12/4/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import XCTest
@testable import SwiftyAnimate

class SwiftyAnimateTests: XCTestCase {
    
    static var allTests : [(String, (SwiftyAnimateTests) -> () throws -> Void)] {
        return [
            ("test_Animate_Performed", test_Animate_Performed),
            ("test_Animate_PerformedWithCompletion", test_Animate_PerformedWithCompletion),
            ("test_EmptyAnimate_Performed", test_EmptyAnimate_Performed),
            ("test_EmptyAnimate_PerformedWithCompletion", test_EmptyAnimate_PerformedWithCompletion),
            ("test_EmptyAnimate_PerformedDoBlock", test_EmptyAnimate_PerformedDoBlock),
            ("test_EmptyAnimate_PerformedWaitBlock", test_EmptyAnimate_PerformedWaitBlock),
            ("test_EmptyAnimate_Finished", test_EmptyAnimate_Finished),
            ("test_EmptyAnimate_PerformedThenAnimation", test_EmptyAnimate_PerformedThenAnimation),
            ("test_EmptyAnimate_PerformedThenAnimationWithCompletion", test_EmptyAnimate_PerformedThenAnimationWithCompletion),
        ]
    }
    
    func test_Animate_Performed() {
        
        var performedAnimation = false
        
        let animation = Animate(duration: 0.5) {
            performedAnimation = true
        }
        
        XCTAssertFalse(performedAnimation)
        
        animation.perform()
        
        XCTAssertTrue(performedAnimation)
    }
    
    func test_Animate_PerformedWithCompletion() {
        
        var performedAnimation = false
        var performedWithCompletion = false
        
        let animation = Animate(duration: 0.5) {
            performedAnimation = true
        }
        
        XCTAssertFalse(performedAnimation)
        XCTAssertFalse(performedWithCompletion)
        
        let expect = expectation(description: "Performed animation with completion")
        
        animation.perform {
            performedWithCompletion = true
            expect.fulfill()
        }
        
        XCTAssertTrue(performedAnimation)
        
        waitForExpectations(timeout: 1.0) { error in
            if error != nil { print(error!.localizedDescription) }
            XCTAssertTrue(performedWithCompletion)
        }
    }
    
    func test_Animate_PerformedThenAnimation() {
        
        var performedAnimation = false
        var performedThenAnimation = false
        
        let animation = Animate(duration: 0.5) {
            performedAnimation = true
        }.then(duration: 0.5) {
            performedThenAnimation = true
        }
        
        XCTAssertFalse(performedAnimation)
        XCTAssertFalse(performedThenAnimation)
        
        let expect = expectation(description: "Performed then animation with completion")
        
        animation.perform {
            expect.fulfill()
        }
        
        XCTAssertTrue(performedAnimation)
        XCTAssertFalse(performedThenAnimation)
        
        waitForExpectations(timeout: 1.0) { error in
            if error != nil { print(error!.localizedDescription) }
            XCTAssertTrue(performedThenAnimation)
        }
    }
    
    func test_EmptyAnimate_Performed() {
        
        let animation = Animate()
        
        let expect = expectation(description: "Performed empty animation with completion")
        
        animation.perform {
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0) { error in
            if error != nil { print(error!.localizedDescription) }
        }
        
    }
    
    func test_EmptyAnimate_PerformedWithCompletion() {
        
        var performedWithCompletion = false
        
        let animation = Animate()
        
        XCTAssertFalse(performedWithCompletion)
        
        animation.perform {
            performedWithCompletion = true
        }
        
        XCTAssertTrue(performedWithCompletion)
    }
    
    func test_EmptyAnimate_PerformedDoBlock() {
        
        var performedDoBlock = false
        
        let animation = Animate().do {
            performedDoBlock = true
        }
        
        XCTAssertFalse(performedDoBlock)
        
        animation.perform()
        
        XCTAssertTrue(performedDoBlock)
    }
    
    func test_EmptyAnimate_PerformedWaitBlock() {
        
        var performedWaitBlock = false
        
        let animation = Animate().wait { resume in
            
            self.resumeBlock = {
                XCTAssertFalse(performedWaitBlock)
                performedWaitBlock = true
                
                resume()
                self.resumeBlock = nil
            }
            
            if #available(iOS 10.0, *) {
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] timer in
                    self?.resumeBlock?()
                }
            } else {
                Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(SwiftyAnimateTests.resume(_:)), userInfo: nil, repeats: false)
            }
            
        }
        
        XCTAssertFalse(performedWaitBlock)
        
        let expect = expectation(description: "Performed empty animation with completion")
        
        animation.perform {
            XCTAssertTrue(performedWaitBlock)
            expect.fulfill()
        }
        
        XCTAssertFalse(performedWaitBlock)
        
        waitForExpectations(timeout: 6.0) { error in
            if error != nil { print(error!.localizedDescription) }
        }
    }
    
    func test_EmptyAnimate_PerformedWaitBlock_WithTimeout() {
        
        var performedWaitBlock = false
        var performedDoBlock = false
        
        let animation = Animate().wait(timeout: 1.0) { resume in
            
            self.resumeBlock = {
                XCTAssertFalse(performedWaitBlock)
                performedWaitBlock = true
                
                resume()
                self.resumeBlock = nil
            }
            
            if #available(iOS 10.0, *) {
                
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] timer in
                    self?.resumeBlock?()
                }
            } else {
                Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(SwiftyAnimateTests.resume(_:)), userInfo: nil, repeats: false)
            }
            
        }.do {
            performedDoBlock = true
        }
        
        XCTAssertFalse(performedWaitBlock)
        XCTAssertFalse(performedDoBlock)
        
        let expect = expectation(description: "Performed empty animation with completion")
        
        animation.perform {
            XCTAssertFalse(performedWaitBlock)
            XCTAssertTrue(performedDoBlock)
            expect.fulfill()
        }
        
        XCTAssertFalse(performedWaitBlock)
        XCTAssertFalse(performedDoBlock)
        
        waitForExpectations(timeout: 2.0) { error in
            if error != nil { print(error!.localizedDescription) }
            
            XCTAssertFalse(performedWaitBlock)
            XCTAssertTrue(performedDoBlock)
        }
    }
    
    func test_EmptyAnimate_Finished() {
        
        var finishedAnimation = false
        
        let animation = Animate()
        
        XCTAssertFalse(finishedAnimation)
        
        animation.finish(duration: 0.5) {
            finishedAnimation = true
        }
        
        XCTAssertTrue(finishedAnimation)
    }
    
    func test_EmptyAnimate_Finished_Spring() {
        
        var finishedAnimation = false
        
        let animation = Animate()
        
        XCTAssertFalse(finishedAnimation)
        
        animation.finish(duration: 0.5, springDamping: 1.0, initialVelocity: 0.5) {
            finishedAnimation = true
        }
        
        XCTAssertTrue(finishedAnimation)
    }
    
    func test_EmptyAnimate_Finished_Animation() {
        
        var finishedAnimation = false
        
        let animation = Animate(duration: 0.5) {
            finishedAnimation = true
        }
        
        XCTAssertFalse(finishedAnimation)
        
        Animate().finish(animation: animation)
        
        XCTAssertTrue(finishedAnimation)
    }
    
    func test_EmptyAnimate_Finished_Keyframe() {
        
        var finishedAnimation = false
        
        let animation = Animate()
        
        XCTAssertFalse(finishedAnimation)
        
        animation.finish(keyframes: [
                Keyframe(duration: 1.0) {
                    finishedAnimation = true
                }
            ])
        
        XCTAssertTrue(finishedAnimation)
    }
    
    func test_EmptyAnimate_PerformedThenAnimation() {
        
        var performedThenAnimation = false
        
        let animation = Animate().then(duration: 0.5) {
            performedThenAnimation = true
        }
        
        XCTAssertFalse(performedThenAnimation)
        
        animation.perform()
        
        XCTAssertTrue(performedThenAnimation)
    }
    
    func test_EmptyAnimate_PerformedThenAnimationWithCompletion() {
        
        var performedThenAnimation = false
        var performedWithCompletion = false
        
        let animation = Animate().then(duration: 0.5) {
            performedThenAnimation = true
        }
        
        XCTAssertFalse(performedThenAnimation)
        XCTAssertFalse(performedWithCompletion)
        
        let expect = expectation(description: "Performed then animation with completion")
        
        animation.perform {
            performedWithCompletion = true
            expect.fulfill()
        }
        
        XCTAssertTrue(performedThenAnimation)
        
        waitForExpectations(timeout: 1.0) { error in
            if error != nil { print(error!.localizedDescription) }
            XCTAssertTrue(performedWithCompletion)
        }
    }
    
    func test_EmptyAnimate_DidDecay() {
        
        var performedDoBlock = false
        
        let animation = Animate().do {
            performedDoBlock = true
        }
        
        XCTAssertFalse(performedDoBlock)
        
        animation.decay()
        
        XCTAssertFalse(performedDoBlock)
        
        animation.perform()
        
        XCTAssertFalse(performedDoBlock)
        
    }
    
    // Feels like this should include a check that the then block was not called before 2.0 seconds but currently a Timer finds that it gets called already? This is probably due to semantics of the UIView animation API.
    func test_Animation_DidDelay() {
        
        var performedAnimation = false
        var performedThenAnimation = false
        
        let animation = Animate(duration: 0.5, delay: 2.0, options: []) {
            performedAnimation = true
        }.then(duration: 0.5) {
            performedThenAnimation = true
        }
        
        XCTAssertFalse(performedAnimation)
        XCTAssertFalse(performedThenAnimation)
        
        let expect = expectation(description: "Performed then animation with delay")
        
        animation.perform {
            XCTAssertTrue(performedAnimation)
            XCTAssertTrue(performedThenAnimation)
            expect.fulfill()
        }
        
        XCTAssertTrue(performedAnimation)
        XCTAssertFalse(performedThenAnimation)
        
        waitForExpectations(timeout: 3.5) { error in
            if error != nil { print(error!.localizedDescription) }
        }
        
    }
    
    func test_Animate_ThenAnimation() {
        
        var performedAnimation = false
        var performedThenAnimation = false
        
        let thenAnimation = Animate(duration: 1.0) {
            performedThenAnimation = true
        }
        
        let animation = Animate(duration: 1.0) {
            performedAnimation = true
        }.then(animation: thenAnimation)
        
        XCTAssertFalse(performedAnimation)
        XCTAssertFalse(performedThenAnimation)
        
        let expect = expectation(description: "Performed then animation")
        
        animation.perform {
            XCTAssertTrue(performedAnimation)
            XCTAssertTrue(performedThenAnimation)
            expect.fulfill()
        }
        
        XCTAssertTrue(performedAnimation)
        XCTAssertFalse(performedThenAnimation)
        
        waitForExpectations(timeout: 2.5) { error in
            if error != nil { print(error!.localizedDescription) }
        }
    }
    
    func test_EmptyAnimate_ThenAnimation() {
        
        var performedThenAnimation = false
        
        let thenAnimation = Animate(duration: 1.0) {
            performedThenAnimation = true
        }
        
        let animation = Animate().then(animation: thenAnimation)
        
        XCTAssertFalse(performedThenAnimation)
        
        animation.perform {
            XCTAssertTrue(performedThenAnimation)
        }
        
        XCTAssertTrue(performedThenAnimation)
    }
    
    func test_SpringAnimation_Performed() {
        
        var performedAnimation = false
        
        let animation = Animate(duration: 0.5, springDamping: 1.0, initialVelocity: 0.5) {
            performedAnimation = true
        }
        
        XCTAssertFalse(performedAnimation)
        
        animation.perform()
        
        XCTAssertTrue(performedAnimation)
    }
    
    
    func test_SpringAnimation_PerformedWithCompletion() {
        
        var performedAnimation = false
        var performedWithCompletion = false
        
        let animation = Animate(duration: 0.5, springDamping: 1.0, initialVelocity: 0.5) {
            performedAnimation = true
        }
        
        XCTAssertFalse(performedAnimation)
        XCTAssertFalse(performedWithCompletion)
        
        let expect = expectation(description: "Performed animation with completion")
        
        animation.perform {
            performedWithCompletion = true
            expect.fulfill()
        }
        
        XCTAssertTrue(performedAnimation)
        
        waitForExpectations(timeout: 1.0) { error in
            if error != nil { print(error!.localizedDescription) }
            XCTAssertTrue(performedWithCompletion)
        }
    }
    
    func test_SpringAnimation_PerformedThenAnimation() {
        
        var performedAnimation = false
        var performedThenAnimation = false
        
        let animation = Animate(duration: 0.5, springDamping: 1.0, initialVelocity: 0.5) {
            performedAnimation = true
        }.then(duration: 0.5, springDamping: 1.0, initialVelocity: 0.5) {
            performedThenAnimation = true
        }
        
        XCTAssertFalse(performedAnimation)
        XCTAssertFalse(performedThenAnimation)
        
        let expect = expectation(description: "Performed then animation with completion")
        
        animation.perform {
            expect.fulfill()
        }
        
        XCTAssertTrue(performedAnimation)
        XCTAssertFalse(performedThenAnimation)
        
        waitForExpectations(timeout: 1.0) { error in
            if error != nil { print(error!.localizedDescription) }
            XCTAssertTrue(performedThenAnimation)
        }
    }
    
    func test_KeyframeAnimation_Performed() {
        
        var performedAnimation = false
        
        let animation = Animate(keyframes: [
                Keyframe(duration: 1.0) {
                    performedAnimation = true
                }
            ])
        
        XCTAssertFalse(performedAnimation)
        
        animation.perform()
        
        XCTAssertTrue(performedAnimation)
    }
    
    func test_KeyframeAnimation_PerformedThenKeyframeAnimation() {
        
        var performedAnimation = false
        var performedThenAnimation = false
        
        let animation = Animate(keyframes: [
                Keyframe(duration: 1.0) {
                    performedAnimation = true
                }
            ])
            .then(keyframes: [
                Keyframe(duration: 1.0) {
                    performedThenAnimation = true
                }
            ])
        
        XCTAssertFalse(performedAnimation)
        XCTAssertFalse(performedThenAnimation)
        
        let expect = expectation(description: "Performed then animation with completion")
        
        animation.perform {
            expect.fulfill()
        }
        
        XCTAssertTrue(performedAnimation)
        XCTAssertFalse(performedThenAnimation)
        
        waitForExpectations(timeout: 1.0) { error in
            if error != nil { print(error!.localizedDescription) }
            XCTAssertTrue(performedThenAnimation)
        }
    }
    
    func test_Animate_Copy() {
        
        var performedAnimation = false
        var performedAnimationTwice = false
        
        let animation = Animate(duration: 0.5) {
            if performedAnimation {
                performedAnimationTwice = true
            } else {
                performedAnimation = true
            }
        }
        
        let copy = animation.copy
        
        XCTAssertFalse(performedAnimation)
        XCTAssertFalse(performedAnimationTwice)
        
        animation.perform()
        
        XCTAssertTrue(performedAnimation)
        XCTAssertFalse(performedAnimationTwice)
        
        copy.perform()
        
        XCTAssertTrue(performedAnimation)
        XCTAssertTrue(performedAnimationTwice)
    }
    
    func test_Animate_DecayPerformance() {
        
        let animation = Animate()
        
        for _ in 0..<1000 {
            _ = animation.then(duration: 0.3) {
                print("do something that takes time like writing to the terminal")
            }
        }
        
        measure {
            animation.decay()
        }
        
    }
    
    func test_Animate_Move() {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
        XCTAssert(view.frame.origin.x == 0)
        XCTAssert(view.frame.origin.y == 0)
        
        Animate().move(view: view, duration: 0.3, x: 10, y: 10).perform()
        
        XCTAssert(view.frame.origin.x == 10)
        XCTAssert(view.frame.origin.y == 10)
        
    }
    
    func test_Animate_Rotate() {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
        let transform = view.transform
        
        XCTAssert(transform == view.transform)
        
        Animate().rotate(view: view, duration: 0.3, angle: 30).perform()
        
        let rotatedTransform = CGAffineTransform(rotationAngle: 30 * CGFloat(M_PI / 180))
        
        XCTAssert(rotatedTransform == view.transform)
        
    }
    
    func test_Animate_Scale() {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
        XCTAssert(view.frame.width == 10)
        XCTAssert(view.frame.height == 10)
        
        Animate().scale(view: view, duration: 0.3, x: 2, y: 2).perform()
        
        XCTAssert(view.frame.width == 20)
        XCTAssert(view.frame.height == 20)
        
    }
    
    func test_Animate_Corner() {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
        XCTAssert(view.layer.cornerRadius == 0)
        
        Animate().corner(view: view, duration: 0.3, radius: 5).perform()
        
        XCTAssert(view.layer.cornerRadius == 5)
        
    }
    
    func test_Animate_Color() {
        
        let view = UIView()
        view.backgroundColor = .white
        
        XCTAssert(view.backgroundColor == .white)
        
        Animate().color(view: view, duration: 0.3, value: .blue).perform()
        
        XCTAssert(view.backgroundColor == .blue)
        
    }

    func test_Animate_Transformed() {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
        var transform = view.transform
        
        XCTAssert(transform == view.transform)
        
        Animate().transform(view: view, duration: 0.3, transforms: [
                .rotate(angle: 90),
                .scale(x: 1.5, y: 1.5),
                .move(x: -10, y: -10),
            ])
            .perform()
        
        transform = CGAffineTransform(rotationAngle: 90 * CGFloat(M_PI / 180))
            .scaledBy(x: 1.5, y: 1.5)
            .translatedBy(x: -10, y: -10)
        
        XCTAssert(transform == view.transform)
        
    }
    
    private var resumeBlock: Resume?
    
    internal func resume(_ sender: Timer) {
        resumeBlock?()
    }
}
