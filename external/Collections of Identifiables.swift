extension Collection where Element: Identifiable {
    func firstIndex(matchingId element: Element) -> Self.Index? {
        firstIndex { $0.id == element.id }
    }
    
    subscript(element: Element) -> Element? {
        guard let index = firstIndex(matchingId: element)
        else { return nil }
        return self[index]
    }
}

extension RangeReplaceableCollection where Element: Identifiable {
    mutating func remove(matchingId element: Element) {
        guard let index = firstIndex(matchingId: element)
        else { return }
        remove(at: index)
    }
}
