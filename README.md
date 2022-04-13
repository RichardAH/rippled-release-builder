# Rippled Release Builder
This is a cross-distro staticly linked release builder for rippled. It is designed to produce rippled binaries that will "run anywhere with no dependencies."
It is built on [The Holy Build Box](https://github.com/phusion/holy-build-box).

## Requirements
- Docker
- Linux

## How to use
First clone the rippled repo into a directory on your system if you haven't already.
```bash
git clone https://github.com/ripple/rippled.git rippled
```

Now checkout the commit or branch you want to build, e.g.
```bash
cd rippled
git fetch
git checkout develop
git reset --hard HEAD
```

Now run the release builder:
*Note: This **will** remove `./release-build` directory if it already exists.*
```bash
bash <(curl -s https://raw.githubusercontent.com/RichardAH/rippled-release-builder/main/release-builder.sh)
```

Wait patiently for the build to complete, and inspect the results.

```bash
cd release-build
cat release.info
cat test.log
./rippled --version
```

This `rippled` binary should be highly portable and can be copied directly onto most x64 linux systems without any further dependencies.
