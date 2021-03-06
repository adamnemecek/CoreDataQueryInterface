//
//  Query.swift
//  CoreDataQueryInterface
//
//  Created by Gregory Higley on 9/25/16.
//  Copyright © 2016 Prosumma LLC. All rights reserved.
//

import CoreData
import Foundation

public struct Query<M: NSManagedObject, R: NSFetchRequestResult> where M: Entity {
    public let builder: QueryBuilder<M>
    
    public init(builder: QueryBuilder<M> = QueryBuilder<M>()) {
        self.builder = builder
    }
    
    public func context(managedObjectContext: NSManagedObjectContext) -> Query<M, R> {
        var builder = self.builder
        builder.managedObjectContext = managedObjectContext
        return Query<M, R>(builder: builder)
    }
    
    public func filter(_ predicate: NSPredicate) -> Query<M, R> {
        var builder = self.builder
        builder.predicates.append(predicate)
        return Query<M, R>(builder: builder)
    }
    
    public func filter(_ format: String, _ args: CVarArg...) -> Query<M, R> {
        return withVaList(args) { filter(NSPredicate(format: format, arguments: $0)) }
    }
    
    public func filter(_ block: (M.CDQIAttribute) -> NSPredicate) -> Query<M, R> {
        let predicate = block(M.CDQIAttribute())
        return filter(predicate)
    }
    
    public func refilter() -> Query<M, R> {
        var builder = self.builder
        builder.predicates = []
        return Query<M, R>(builder: builder)
    }
    
    public func select<P: Sequence>(_ properties: P) -> Query<M, NSDictionary> where P.Iterator.Element: PropertyConvertible {
        var builder = self.builder
        builder.resultType = .dictionaryResultType
        builder.propertiesToFetch ??= []
        builder.propertiesToFetch!.append(contentsOf: properties.map{ $0.cdqiProperty })
        return Query<M, NSDictionary>(builder: builder)
    }
    
    public func select(_ properties: PropertyConvertible...) -> Query<M, NSDictionary> {
        var builder = self.builder
        builder.resultType = .dictionaryResultType
        builder.propertiesToFetch ??= []
        builder.propertiesToFetch!.append(contentsOf: properties.map{ $0.cdqiProperty })
        return Query<M, NSDictionary>(builder: builder)
    }
    
    public func select(_ blocks: ((M.CDQIAttribute) -> PropertyConvertible)...) -> Query<M, NSDictionary> {
        var builder = self.builder
        builder.resultType = .dictionaryResultType
        builder.propertiesToFetch ??= []
        let attribute = M.CDQIAttribute()
        builder.propertiesToFetch!.append(contentsOf: blocks.map{ $0(attribute).cdqiProperty })
        return Query<M, NSDictionary>(builder: builder)
    }
    
    public func select(_ block: (M.CDQIAttribute) -> [PropertyConvertible]) -> Query<M, NSDictionary> {
        var builder = self.builder
        builder.resultType = .dictionaryResultType
        builder.propertiesToFetch ??= []
        builder.propertiesToFetch!.append(contentsOf: block(M.CDQIAttribute()).map{ $0.cdqiProperty })
        return Query<M, NSDictionary>(builder: builder)
    }
    
    public func reselect() -> Query<M, NSDictionary> {
        var builder = self.builder
        builder.resultType = .dictionaryResultType
        builder.propertiesToFetch = nil
        return Query<M, NSDictionary>(builder: builder)
    }
    
    public func groupBy<P: Sequence>(_ properties: P) -> Query<M, NSDictionary> where P.Iterator.Element: PropertyConvertible {
        var builder = self.builder
        builder.resultType = .dictionaryResultType
        builder.propertiesToGroupBy ??= []
        builder.propertiesToGroupBy!.append(contentsOf: properties.map{ $0.cdqiProperty })
        return Query<M, NSDictionary>(builder: builder)
    }
    
    public func groupBy(_ properties: PropertyConvertible...) -> Query<M, NSDictionary> {
        var builder = self.builder
        builder.resultType = .dictionaryResultType
        builder.propertiesToGroupBy ??= []
        builder.propertiesToGroupBy!.append(contentsOf: properties.map{ $0.cdqiProperty })
        return Query<M, NSDictionary>(builder: builder)
    }
    
    public func groupBy(_ blocks: ((M.CDQIAttribute) -> PropertyConvertible)...) -> Query<M, NSDictionary> {
        var builder = self.builder
        builder.resultType = .dictionaryResultType
        builder.propertiesToGroupBy ??= []
        let attribute = M.CDQIAttribute()
        builder.propertiesToGroupBy!.append(contentsOf: blocks.map { $0(attribute).cdqiProperty })
        return Query<M, NSDictionary>(builder: builder)
    }
    
    public func groupBy(_ block: (M.CDQIAttribute) -> [PropertyConvertible]) -> Query<M, NSDictionary> {
        var builder = self.builder
        builder.resultType = .dictionaryResultType
        builder.propertiesToGroupBy ??= []
        builder.propertiesToGroupBy!.append(contentsOf: block(M.CDQIAttribute()).map{ $0.cdqiProperty })
        return Query<M, NSDictionary>(builder: builder)
    }
    
    public func regroup() -> Query<M, NSDictionary> {
        var builder = self.builder
        builder.resultType = .dictionaryResultType
        builder.propertiesToGroupBy = nil
        return Query<M, NSDictionary>(builder: builder)
    }
    
    public func order<O: Sequence>(ascending: Bool, _ sortDescriptors: O) -> Query<M, R> where O.Iterator.Element: SortDescriptorConvertible {
        var builder = self.builder
        builder.sortDescriptors.append(contentsOf: sortDescriptors.map{ $0.cdqiSortDescriptor(ascending: ascending)  })
        return Query<M, R>(builder: builder)
    }
    
    public func order<O: Sequence>(_ sortDescriptors: O) -> Query<M, R> where O.Iterator.Element: SortDescriptorConvertible {
        return order(ascending: true, sortDescriptors)
    }
    
    public func order(ascending: Bool, _ sortDescriptors: SortDescriptorConvertible...) -> Query<M, R> {
        var builder = self.builder
        builder.sortDescriptors.append(contentsOf: sortDescriptors.map{ $0.cdqiSortDescriptor(ascending: ascending)  })
        return Query<M, R>(builder: builder)
    }
    
    public func order(_ sortDescriptors: SortDescriptorConvertible...) -> Query<M, R> {
        var builder = self.builder
        builder.sortDescriptors.append(contentsOf: sortDescriptors.map{ $0.cdqiSortDescriptor(ascending: true)  })
        return Query<M, R>(builder: builder)
    }
    
    public func order(ascending: Bool = true, _ blocks: ((M.CDQIAttribute) -> SortDescriptorConvertible)...) -> Query<M, R> {
        var builder = self.builder
        let attribute = M.CDQIAttribute()
        builder.sortDescriptors.append(contentsOf: blocks.map { $0(attribute).cdqiSortDescriptor(ascending: ascending) })
        return Query<M, R>(builder: builder)
    }
    
    public func order(ascending: Bool = true, _ block: (M.CDQIAttribute) -> [SortDescriptorConvertible]) -> Query<M, R> {
        var builder = self.builder
        builder.sortDescriptors.append(contentsOf: block(M.CDQIAttribute()).map{ $0.cdqiSortDescriptor(ascending: ascending) })
        return Query<M, R>(builder: builder)
    }
        
    public func reorder() -> Query<M, R> {
        var builder = self.builder
        builder.sortDescriptors = []
        return Query<M, R>(builder: builder)
    }
    
    public func objects() -> Query<M, M> {
        var builder = self.builder
        builder.propertiesToFetch = nil
        builder.propertiesToGroupBy = nil
        builder.resultType = .managedObjectResultType
        return Query<M, M>(builder: builder)
    }
    
    public func ids() -> Query<M, NSManagedObjectID> {
        var builder = self.builder
        builder.propertiesToFetch = nil
        builder.propertiesToGroupBy = nil        
        builder.resultType = .managedObjectIDResultType
        return Query<M, NSManagedObjectID>(builder: builder)
    }
    
    public func limit(_ fetchLimit: Int) -> Query<M, R> {
        var builder = self.builder
        builder.fetchLimit = fetchLimit
        return Query<M, R>(builder: builder)
    }
    
    public func offset(_ fetchOffset: Int) -> Query<M, R> {
        var builder = self.builder
        builder.fetchOffset = fetchOffset
        return Query<M, R>(builder: builder)
    }
    
    public func distinct(_ distinct: Bool = true) -> Query<M, NSDictionary> {
        var builder = self.builder
        builder.returnsDistinctResults = distinct
        builder.resultType = .dictionaryResultType
        return Query<M, NSDictionary>(builder: builder)
    }
    
    public func request(managedObjectContext: NSManagedObjectContext) -> NSFetchRequest<R> {
        if #available(iOS 10, macOS 10.12, tvOS 10, watchOS 3, *) {
            return builder.request()
        } else {
            let managedObjectModel = managedObjectContext.persistentStoreCoordinator!.managedObjectModel
            return builder.request(managedObjectModel: managedObjectModel)
        }
    }
    
    @available(iOS 10, macOS 10.12, tvOS 10, watchOS 3, *)
    public func request() -> NSFetchRequest<R> {
        return builder.request()
    }
    
    @available(*, deprecated: 5.0)
    public func request(managedObjectModel: NSManagedObjectModel) -> NSFetchRequest<R> {
        return builder.request(managedObjectModel: managedObjectModel)
    }
    
    public func count(managedObjectContext: NSManagedObjectContext? = nil) throws -> Int {
        var builder = self.builder
        builder.resultType = .countResultType
        let managedObjectContext = managedObjectContext ?? builder.managedObjectContext!
        return try managedObjectContext.count(for: request(managedObjectContext: managedObjectContext))
    }
    
    public func first(managedObjectContext: NSManagedObjectContext? = nil) throws -> R? {
        let results = try limit(1).all(managedObjectContext: managedObjectContext)
        assert(results.count < 2)
        return results.count == 0 ? nil : results[0]
    }
    
    public func all(managedObjectContext: NSManagedObjectContext? = nil) throws -> [R] {
        let managedObjectContext = managedObjectContext ?? builder.managedObjectContext!
        return try managedObjectContext.fetch(request(managedObjectContext: managedObjectContext))
    }
    
    public func array<T>(_ property: PropertyConvertible, managedObjectContext: NSManagedObjectContext? = nil) throws -> [T] {
        let results: [NSDictionary] = try reselect().select(property).all(managedObjectContext: managedObjectContext)
        if results.count == 0 { return [] }
        let key = results[0].allKeys[0]
        return results.map { $0[key]! as! T }
    }
    
    public func array<T>(managedObjectContext: NSManagedObjectContext? = nil, _ block: (M.CDQIAttribute) -> PropertyConvertible) throws -> [T] {
        return try array(block(M.CDQIAttribute()), managedObjectContext: managedObjectContext)
    }
    
    public func value<T>(_ property: PropertyConvertible, managedObjectContext: NSManagedObjectContext? = nil) throws -> T? {
        let results: [T] = try limit(1).array(property)
        return results.count == 0 ? nil : results[0]
    }
    
    public func value<T>(managedObjectContext: NSManagedObjectContext? = nil, _ block: (M.CDQIAttribute) -> PropertyConvertible) throws -> T? {
        return try value(block(M.CDQIAttribute()), managedObjectContext: managedObjectContext)
    }
    
    public func exists(managedObjectContext: NSManagedObjectContext? = nil) throws -> Bool {
        return try limit(1).count(managedObjectContext: managedObjectContext) > 0
    }
}
