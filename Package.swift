import PackageDescription

let package = Package(
    name: "monzo-swift",
    dependencies: [
        .Package(url: "https://github.com/marius-serban/S4.git", "0.12.2")
    ]
)
