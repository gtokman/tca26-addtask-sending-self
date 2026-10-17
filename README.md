# TCA26: "sending 'self' risks causing data races" calling a feature's own async helper from `addTask`

A repro for [pointfreeco/TCA26#263](https://github.com/pointfreeco/TCA26/issues/263), point 2.

```sh
swift build
```

```
Sources/Repro/Repro.swift:28:27: error: sending 'self' risks causing data races
  note: sending 'self' to @concurrent instance method 'answer' risks causing data races
        between @concurrent code and code in the current isolation context
```

```swift
store.addTask {
    await answer(id)      // error: sending 'self' risks causing data races
}

private func answer(_ id: String) async { … }
```

## What it depends on

- **Swift 6 language mode without `NonisolatedNonsendingByDefault`.** In that mode a
  nonisolated `async` method of the feature is `@concurrent`, so calling it from the task
  sends the (non-`Sendable`) feature value off the store's isolation. Turn the upcoming
  feature on (`.enableUpcomingFeature("NonisolatedNonsendingByDefault")`, or Xcode 26's
  *Approachable Concurrency* build setting) and the error goes away — probably why it didn't
  reproduce for you. Packages default to it being off.
- **Not the environment:** the helper reads `@FeatureEnvironment(\.client)` here, as ours did,
  but an empty `private func answer(_ id: String) async {}` errors the same way.

Toolchain: Xcode 27 (Swift 6.4, swiftlang-6.4.0.34.1), TCA26 `main`, macOS 15 / iOS 18 targets.

Our workaround was a `Sendable` helper struct built from the environment values outside the
task, so the task captures that instead of `self`.
