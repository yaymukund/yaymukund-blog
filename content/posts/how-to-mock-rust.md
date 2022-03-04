+++
date = 2019-03-01
title = "How to spy on your Rust code"
+++

In the following code, how can you test that `Player` is making the correct API
calls?

```rs
struct Player<'a> {
  api: &'a Api,
}

impl<'a> Player<'a> {
  pub fn new(api: &'a Api) -> Player<'a> {
    Player { api }
  }

  pub fn play(&self, song: &str) {
    self.api.sing(song);
  }

  pub fn stop(&self) {
    self.api.shush();
  }
}
```

<!-- more -->

The answer? Make it generic!

```rs
struct Player<'a, T> {
  api: &'a T,
}

impl<'a, T> Player<'a, T>
where
  T: PlayerApi,
{
  pub fn new(api: &'a T) -> Player<'a, T> {
    Player { api }
  }

  // ...
}

trait PlayerApi {
  // Default trait implementation uses `Api`
  fn sing(&self, url: &str);
  fn shush(&self);
}

impl PlayerApi for Api {
  fn sing(&self, url: &str) {
    Api::sing(self, url)
  }

  fn shush(&self) {
    Api::shush(self)
  }
}
```

Then you can easily spy on it:

```rs
#[cfg(test)]
module Test {
  struct ApiSpy {
    pub invocations: Vec<String>,
    api: Api,
  }

  impl ApiSpy {
    pub fn new() -> ApiSpy {
      ApiSpy { api: Api::New() }
    }
  }

  impl PlayerApi for ApiSpy {
    fn sing(&self, url: &str) {
      self.invocations.push('play');
      self.api.sing(url)
    }
  }

  #[test]
  fn test_play() {
    let api = ApiMock::new();
    let player = Player::new(&api);
    player.play("my_url");
    assert_eq!(api.invocations[0], "play");
  }
}
```

That's it!

### How can I assert that I passed the correct arguments?

You can store the arguments in the `ApiSpy`. For example, here's [how I mocked
the mpv api][roja_mpv_api] and [used it in a test][roja_player].

### I don't want to define a trait for my API just for tests!

Defining a trait for your external APIs is good for reasons beyond testing. But
if you still still don't want to make your API generic, then you could [use
conditional compilation instead.][conditional_compilation].

### What if I don't want to execute API code in tests?

If you want to mock instead of spy, you have a couple options:

* If your API's return types are easy to mock, then just return mock responses
  instead of proxying.
* You could also [use a mocking library][mock_shootout]. Just a caveat: I had
  trouble with many of the crates, but maybe you'll have better luck.
* Finally, you could try conditional compilation as mentioned above. This lets
  let you get around type checking.

[conditional_compilation]: https://klausi.github.io/rustnish/2019/03/31/mocking-in-rust-with-conditional-compilation.html
[mock_shootout]: https://asomers.github.io/mock_shootout/
[roja_player]: https://github.com/yaymukund/roja/blob/57ed629b9cc9446993361a13dc05de4f9057d1d3/src/player.rs#L90
[roja_mpv_api]: https://github.com/yaymukund/roja/blob/57ed629b9cc9446993361a13dc05de4f9057d1d3/src/player/mpv_api.rs#L42
