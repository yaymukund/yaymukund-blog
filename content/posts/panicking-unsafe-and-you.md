+++
date = 2020-05-30
title = "Panicking, unsafe, and you"
+++

## Panicking, unsafe, and you

In Jon Gjengset's *Demystifying Unsafe Code* talk at Rust NYC, he gives a very
interesting example of unsafe code. [Here's the link-- please go and watch
it--][jonhoo_talk] but I've transcribed it here along with my paraphrased
explanation.

<!-- more -->

```rust
impl<T> Vec<T> {
  /// apply `f` to every element of `us`, and extend `self`
  /// with the result. for example:
  ///
  /// names.extend_map([user1, user2], |u| u.name())
  ///
  fn extend_map<U, F>(&mut self, us: &[U], mut f: F)
  where F: FnMut(&U) -> T {
    // reserve capacity in the Vec all at once, for perf (?)
    self.reserve(us.len());

    // set the length() manually.
    let cur_len = self.len();
    unsafe { self.set_len(cur_len + us.len()) };

    // insert the items by writing to the memory location
    let into = unsafe { self.as_mut_ptr().add(cur_len) };
    for u in us {
      unsafe { std::ptr::write(into, f(u)) }; into += 1;
    }
  }
}
```

If `f` panics, then Rust will unwind the stack and drop every item in `Vec`
before dropping the `Vec` itself. However, since you've unsafely set its length
with `set_len()`, *it will try to call drop on array indices that you haven't
written to yet!* In other words, it will just call garbage memory. Apparently,
this is why it can be challenging to write [`Vec::drain()`][drain]
implementations.

[jonhoo_talk]: https://www.youtube.com/watch?v=QAz-maaH0KM#t=13m28s
[drain]: https://doc.rust-lang.org/std/vec/struct.Vec.html#method.drain
