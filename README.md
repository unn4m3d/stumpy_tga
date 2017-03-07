# stumpy_tga

**WORK IN PROGRESS**

TGA (Targa) files reader <s>and writer</s> designed for use with [stumpy_core](https://github.com/l3kn/stumpy_core)

Supports only types 1, 2, 9 and 10 (Color mapped or RGB, with RunLength encoding or without) with pixel depth 16, 24 and 32.

Only reading is supported.

## Interface

* `StumpyTGA.read(file) : Canvas` - Read TGA file
* `StumpyTGA.read_raw(file) : StumpyTGA::TGA` - Read a TGA file into special structure

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  stumpy_tga:
    github: unn4m3d/stumpy_tga
```

## Usage

```crystal
require "stumpy_tga"
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/unn4m3d/stumpy_tga/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [unn4m3d](https://github.com/unn4m3d) - creator, maintainer
