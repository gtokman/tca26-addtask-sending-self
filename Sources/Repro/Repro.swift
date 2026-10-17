import ComposableArchitecture2

protocol Client: Sendable {
    func answer(_ id: String) async
}

struct LiveClient: Client {
    func answer(_ id: String) async {}
}

extension FeatureEnvironmentValues {
    @FeatureEnvironmentEntry(liveValue: LiveClient())
    var client: any Client = LiveClient()
}

@Feature struct Repro {
    struct State {}
    enum Action { case requestReceived(String) }

    @FeatureEnvironment(\.client) var client

    var body: some Feature {
        Update { state, action in
            switch action {
            case .requestReceived(let id):
                store.addTask {
                    // error: sending 'self' risks causing data races
                    await answer(id)
                }
            }
        }
    }

    /// A helper that reads the environment, as the feature's own method.
    private func answer(_ id: String) async {
        await client.answer(id)
    }
}
