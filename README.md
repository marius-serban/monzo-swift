# Monzo Swift Client

[![Swift][swift-badge]][swift-url]
![Linux][linux]
[![License][mit-badge]][mit-url]
[![Travis][travis-badge]][travis-url]
[![Codebeat][codebeat-badge]][codebeat-url]

A Monzo client written in Swift that provides a simple interface to the Monzo API. This package is targeted towards server side use on Linux; if you're looking for a Monzo client for iOS then have a look at [MondoKit](https://github.com/pollarm/MondoKit).

API documentation, user guides and setup information can be found at [monzo.com/docs](https://monzo.com/docs/).

## Installation

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/marius-serban/monzo-swift.git"),
    ]
)
```

## Support

You can create a Github [issue](https://github.com/marius-serban/monzo-swift/issues/new) in this repository. When stating your issue be sure to add enough details about what's causing the problem and reproduction steps.

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.

[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat
[swift-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[travis-badge]: https://api.travis-ci.org/marius-serban/monzo-swift.svg?branch=master
[travis-url]: https://travis-ci.org/marius-serban/monzo-swift
[codebeat-badge]: https://codebeat.co/badges/b5c058fb-f26d-4a8d-82f9-82904b542c33
[codebeat-url]: https://codebeat.co/projects/github-com-marius-serban-monzo-swift
[linux]: https://img.shields.io/badge/Platform-linux-orange.svg
