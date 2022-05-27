extension Collection where Element: Identifiable {
    /// Returns the first index in which an element of the collection satisfies the given ID.
    /// - Parameter element: An element to search for in the collection.
    /// - Returns: The first index where element is found.
    /// If element is not found in the collection, returns nil.
    func firstIndex(matchingId element: Element) -> Self.Index? {
        firstIndex { $0.id == element.id }
    }
}

extension RangeReplaceableCollection where Element: Identifiable {
    /// Removes all the elements that satisfy the given ID.
    /// - Parameter element: The ID of the element to remove.
    mutating func remove(matchingId element: Element) {
        removeAll{ $0.id == element.id }
    }
}
