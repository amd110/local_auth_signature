//
//  DispatchQueue+Extension.swift
//  local_auth_signature
//
//  Created by sudan on 09/08/2024.
//

import Foundation

@discardableResult func doAsync1<T>(_ block: @escaping () -> T) -> T {
    let queue = DispatchQueue.global()
    let group = DispatchGroup()
    var result: T?
    group.enter()
    queue.async(group: group) { result = block(); group.leave(); }
    group.wait()
    
    return result!
}

struct Await<T> {
    fileprivate let group: DispatchGroup
    fileprivate let getResult: () -> T
    @discardableResult func await() -> T { return getResult() }
}

func doAsync<T>(_ queue: DispatchQueue = DispatchQueue.global() , _ block: @escaping () -> T) -> Await<T> {
    let group = DispatchGroup()
    var result: T?
    group.enter()
    queue.async(group: group) { result = block(); group.leave() }
    group.wait()
    return Await(group: group, getResult: { return result! })
}
