// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TopTodo",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "TopTodo",
            targets: ["TopTodo"]
        )
    ],
    targets: [
        .executableTarget(
            name: "TopTodo",
            path: ".",
            exclude: [
                ".git",
                ".codex",
                ".DS_Store",
                ".cache",
                ".home",
                "TopTodo.command",
                "安装 TopTodo.command",
                "dist",
                "script"
            ],
            sources: [
                "App",
                "Models",
                "Stores",
                "Support",
                "Views"
            ]
        )
    ]
)
