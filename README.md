# Monzo Swift Client

[![Swift][swift-badge]][swift-url]
![Linux][linux]
[![License][mit-badge]][mit-url]
[![Travis][travis-badge]][travis-url]
[![Codebeat][codebeat-badge]][codebeat-url]

A Monzo client that provides a simple Swift interface to the Monzo API. This package is targeted towards server side use on Linux; if you're looking for a Monzo client for iOS then have a look at [MondoKit](https://github.com/pollarm/MondoKit).

API documentation, user guides and setup information can be found at [monzo.com/docs](https://monzo.com/docs/).

## Installation

**Note:** the minimum required Swift version is `DEVELOPMENT-SNAPSHOT-2016-11-08-a`
```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/marius-serban/monzo-swift.git"),
    ]
)
```

## Getting started
The library is compatible with [Open Swift][open-swift] so you can use it with any server side framework that supports this standards. It relies upon a [S4][s4] `Responder` to perform the HTTP calls over the network. Luckly, [Vapor][vapor]'s `Droplet` and [Zewo][zewo]'s' `Client` conform to this protocol for example.

### Initialize your client

```swift
let myHttpClient = ...
let monzo = Monzo.Client(httpClient: myHttpClient)
```

### Create authorization URI

Create a URI that points to the Monzo login page for your app.

```swift
let uri = Monzo.Client.authorizationUri(clientId: "aClientId", redirectUri: "http://host.com/?param=[]#fragment", nonce: "abc123")
// redirect user to URI
```

### Authenticate

```swift
let credentials = try monzo.authenticate(withCode: " ", clientId: " ", clientSecret: " ")
```

### Ping

```swift
do {
  try monzo.ping()
} catch {
  // try again later
}
```

### Whoami

```swift
let accessTokenInfo = try monzo.whoami(accessToken: "a_token")
```


## Support

You can create a Github [issue](https://github.com/marius-serban/monzo-swift/issues/new) in this repository. When stating your issue be sure to add enough details about what's causing the problem and reproduction steps.


Also, you can get in touch with me on [Twitter][my-twitter].

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
[open-swift]: https://github.com/open-swift
[s4]: https://github.com/open-swift/S4
[vapor]: http://vapor.codes/
[zewo]: http://www.zewo.io/
[my-twitter]: https://www.twitter.com/smarius
