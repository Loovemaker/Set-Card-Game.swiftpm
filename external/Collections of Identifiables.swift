extension Collection where Element: Identifiable {
    func firstIndex(matchingId element: Element) -> Self.Index? {
        firstIndex { $0.id == element.id }
    }
}

extension RangeReplaceableCollection where Element: Identifiable {
    mutating func remove(matchingId element: Element) {
        removeAll{ $0.id == element.id }
    }
}
