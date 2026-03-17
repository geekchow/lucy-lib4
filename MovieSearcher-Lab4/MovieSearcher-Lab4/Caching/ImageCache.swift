import UIKit

class ImageCache {
    static let shared = ImageCache()
    private init() {}

    private let cache = NSCache<NSString, UIImage>()
    private var activeTasks: [String: URLSessionDataTask] = [:]
    private let lock = NSLock()

    // MARK: - Synchronous Lookup
    func cachedImage(for urlString: String) -> UIImage? {
        return cache.object(forKey: urlString as NSString)
    }

    // MARK: - Load Image
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Cache hit
        if let cached = cache.object(forKey: urlString as NSString) {
            completion(cached)
            return
        }

        lock.lock()
        // Deduplicate in-flight requests
        if activeTasks[urlString] != nil {
            lock.unlock()
            // Poll briefly then retry — simplified: just enqueue another completion
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.loadImage(from: urlString, completion: completion)
            }
            return
        }

        guard let url = URL(string: urlString) else {
            lock.unlock()
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }

            self.lock.lock()
            self.activeTasks.removeValue(forKey: urlString)
            self.lock.unlock()

            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }

            self.cache.setObject(image, forKey: urlString as NSString)
            completion(image)
        }

        activeTasks[urlString] = task
        lock.unlock()
        task.resume()
    }

    // MARK: - Cancel
    func cancelLoad(for urlString: String) {
        lock.lock()
        activeTasks[urlString]?.cancel()
        activeTasks.removeValue(forKey: urlString)
        lock.unlock()
    }
}
