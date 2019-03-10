+++
date = 2019-03-10
title = "How to mock Rust"
+++

## How to mock Rust

In the following code, how can you ensure `Player` is making the correct API calls?

```rs
struct Player<'a> {
  api: &'a Api,
}

impl<'a> Player<'a> {
  pub fn new(api: &'a Api) -> Player<'a> {
    Player { api }
  }

  pub fn sing(&self, song: &str) {
    self.api.play(song);
  }

  pub fn shush(&self) {
    self.api.stop();
  }
}
```

The answer? Make it generic!

```rs
struct Player<'a, T> {
  api: &'a T,
}

impl<'a, T> Player<'a, T>
where
  T: impl PlayerApi,
{
  pub fn new(api: &'a T) -> Player<'a, T> {
    Player { api }
  }

  // ...
}

trait PlayerApi {
  // Default trait implementation uses `Api`
  fn play(&self, url: &str) {
    Api::play(self, url)
  }

  fn stop(&self) {
    Api::stop(self)
  }
}
```

Then you can easily mock it:

```rs
#[cfg(test)]
module Test {
  struct ApiMock {
    invocations: Vec<Vec<&str>>,
  }

  impl PlayerApi for ApiMock {
    fn play(&self, url: &str) {
      self.invocations.push(vec!["play", url.to_string()]);
  }

  #[test]
  fn test_play() {
    let api = ApiMock::new();
    let player = Player::new(&api);
    player.play("my_url");
    assert_eq!(api.invocations[0][0], "play");
    assert_eq!(api.invocations[0][1], "my_url");
  }
}
```

It should be possible to make this much nicer with macros and derives, but
that's for another post.
