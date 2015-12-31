//
//  CustomExpressionConvertible.swift
//  CoreDataQueryInterface
//
//  Created by Gregory Higley on 12/28/15.
//  Copyright © 2015 Prosumma LLC. All rights reserved.
//

import Foundation
import CoreData

public protocol CustomExpressionConvertible {
    var expression: NSExpression { get }
}

extension CustomExpressionConvertible {
    public func compare(rhs: Any?, type: NSPredicateOperatorType, options: NSComparisonPredicateOptions) -> NSPredicate {
        let rightExpression: NSExpression
        if let rhs = rhs as? CustomExpressionConvertible {
            rightExpression = rhs.expression
        } else {
            rightExpression = NSExpression(forConstantValue: rhs as! AnyObject?)
        }
        debugPrint(rightExpression)
        return NSComparisonPredicate(leftExpression: expression, rightExpression: rightExpression, modifier: .DirectPredicateModifier, type: type, options: options)
    }
    public func equalTo(rhs: Any?, options: NSComparisonPredicateOptions = []) -> NSPredicate {
        return compare(rhs, type: .EqualToPredicateOperatorType, options: options)
    }
    public func greaterThan(rhs: Any?, options: NSComparisonPredicateOptions = []) -> NSPredicate {
        return compare(rhs, type: .GreaterThanPredicateOperatorType, options: options)
    }
    public func greaterThanOrEqualTo(rhs: Any?, options: NSComparisonPredicateOptions = []) -> NSPredicate {
        return compare(rhs, type: .GreaterThanOrEqualToPredicateOperatorType, options: options)
    }
    public func lessThan(rhs: Any?, options: NSComparisonPredicateOptions = []) -> NSPredicate {
        return compare(rhs, type: .LessThanPredicateOperatorType, options: options)
    }
    public func lessThanOrEqualTo(rhs: Any?, options: NSComparisonPredicateOptions = []) -> NSPredicate {
        return compare(rhs, type: .LessThanOrEqualToPredicateOperatorType, options: options)
    }
    public func beginsWith(rhs: Any?, options: NSComparisonPredicateOptions = []) -> NSPredicate {
        return compare(rhs, type: .BeginsWithPredicateOperatorType, options: options)
    }
    public func contains(rhs: Any?, options: NSComparisonPredicateOptions = []) -> NSPredicate {
        return compare(rhs, type: .ContainsPredicateOperatorType, options: options)
    }
    public func endsWith(rhs: Any?, options: NSComparisonPredicateOptions = []) -> NSPredicate {
        return compare(rhs, type: .EndsWithPredicateOperatorType, options: options)
    }
    public func among(rhs: [Any], options: NSComparisonPredicateOptions = []) -> NSPredicate {
        var expressions = [AnyObject]()
        for elem in rhs {
            let o = elem as! AnyObject
            let e = NSExpression(forConstantValue: o)
            expressions.append(e)
        }
        return compare(NSExpression(forAggregate: expressions), type: .InPredicateOperatorType, options: options)
    }
    public func like(rhs: Any?, options: NSComparisonPredicateOptions = []) -> NSPredicate {
        return compare(rhs, type: .LikePredicateOperatorType, options: options)
    }
    public func matches(rhs: Any?, options: NSComparisonPredicateOptions = []) -> NSPredicate {
        return compare(rhs, type: .MatchesPredicateOperatorType, options: options)
    }
}

extension NSExpression: CustomExpressionConvertible {
    public var expression: NSExpression {
        return self
    }
}