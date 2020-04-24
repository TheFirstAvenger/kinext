Kinext is an Elixir wrapper for the [OpenKinect](https://www.openkinect.org) library. OpenKinect allows access to the
XBOX 360 Kinect peripheral. Since the Kinect has a proprietary connector, you will need a
[USB adapter](https://www.amazon.com/IDS-Xbox-Kinect-Sensor-Adapter/dp/B073GY3C7Z) to connect your computer to the Kinect.

## Project Status

This project is currently in functioning state. I have no current plans to actually use the library for anything specific,
it was more of an exercize for me to learn NIFs and have some fun. If you are using this library in your own project,
I would love any feedback you have about it, and would be happy to dive deeper, just open a Github issue.

## Installation

The Kinext library can be installed by adding `kinext` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kinext, "~> 0.2.0"}
  ]
end
```

You will also need to install [OpenKinect](https://openkinect.org/wiki/Getting_Started).

On OSX this might be as simple as running `brew install libfreenect`. I also found I needed to `brew cask install quartz`.


## Documentation

The docs can be found at [https://hexdocs.pm/kinext](https://hexdocs.pm/kinext).

