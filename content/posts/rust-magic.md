+++
date = 2021-02-02
title = "Rust Magic"
+++

## Rust magic

This is a list of places in Rust where implementing a trait or using a struct
affects the syntax of your code. I think of these features as "magical" because
using them can change the behavior of very basic Rust code (`let`, `for-in`,
`&`, etc.).

What follows is a small list of (hopefully) illustrative examples, and a short
epilogue pointing you to more articles if this topic interests you.

<!-- more -->

----------

### Contents

- [`trait Drop`](#trait-drop-playground-link)
- [`trait IntoIterator` and `for-in`](#trait-intoiterator-and-for-in-playground-link)
- [`trait Deref`, `DerefMut`, and `&`](#trait-deref-derefmut-and-playground-link)
- [`trait Display`, `Debug`, and `{}`](#trait-display-debug-and-playground-link)
- [`trait Copy`](#trait-copy-playground-link)
- [`Option`, `Result`, and `?`](#option-result-and-playground-link)
- [Epilogue](#epilogue)

----------

#### `trait Drop` ([Playground Link][trait-drop-playground])

```rust
struct Foo {
    text: String,
}

impl Drop for Foo {
    fn drop(&mut self) {
        println!("{} was dropped", self.text);
    }
}

fn main() {
    let mut foo = Some(Foo {
        text: String::from("the old value"),
    });

    // this calls the drop() we wrote above
    foo = None;
}
```

#### `trait IntoIterator` and `for-in` ([Playground Link][intoiterator-playground])

```rust
struct MyCustomStrings(Vec<String>);

impl IntoIterator for MyCustomStrings {
    type Item = String;
    type IntoIter = std::vec::IntoIter<Self::Item>;

    fn into_iter(self) -> Self::IntoIter {
        self.0.into_iter()
    }
}

fn main() {
    let my_custom_strings = MyCustomStrings(vec![
        String::from("one"),
        String::from("two"),
        String::from("three"),
    ]);

    // We can use for-in with our struct
    //
    // prints "one", "two", "three"
    for a_string in my_custom_strings {
        println!("{}", a_string);
    }
}
```

#### `trait Deref`, `DerefMut`, and `&` ([Playground Link][deref-playground])

```rust
use std::ops::Deref;

struct Smart<T> {
    inner: T,
}

// You can implement `DerefMut` to coerce exclusive references (&mut).
impl<T> Deref for Smart<T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        &self.inner
    }
}

fn main() {
    let text = Smart {
        inner: String::from("what did you say?"),
    };

    // The `impl Deref` lets us invoke the `&str` method
    // `to_uppercase()` on a `&Smart<String>`
    println!("{}", &text.to_uppercase());
}
```

#### `trait Display`, `Debug`, and `{}` ([Playground Link][display-debug-playground]]

```rust
use std::fmt;

struct Goat {
    name: String,
}

impl fmt::Display for Goat {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "a goat named {}", self.name)
    }
}

fn main() {
    let goat = Goat {
        name: String::from("Yagi"),
    };

    // This invokes our `Display`'s `fmt()`
    println!("{}", goat);
}
```

#### `trait Copy` ([Playground Link][copy-playground])

```rust
#[derive(Clone, Copy, Debug)]
struct Point {
    x: usize,
    y: usize,
}

fn main() {
    let point_a = Point { x: 1, y: 2 };
    let point_b = point_a;

    // point_a is still valid because it was copied rather than moved.
    println!("{:?}", point_a);
}
```

#### `Option`, `Result`, and `?` ([Playground Link][option-result-playground])

```rust
// Notes:
// * This works very similarly with Option<T>
// * We need to derive(Debug) to use the error in a Result.
//
#[derive(Debug)]
struct SomeError;

fn uh_oh() -> Result<(), SomeError> {
    Err(SomeError)
}

fn main() -> Result<(), SomeError> {
    // The following line desugars to:
    //
    // match uh_oh() {
    //     Ok(v) => v,
    //     Err(SomeError) => return Err(SomeError),
    // }
    //
    uh_oh()?;

    Ok(())
}
```

### Epilogue

When I first started compiling this list, I asked around in the Rust community
discord. [scottmcm][scottmcm] from the Rust Language team introduced me to the
concept of [lang items][lang_items_list]. If you search for articles on this
topic, you get some fantastic resources:

> So what is a lang item? Lang items are a way for the stdlib (and libcore) to
> define types, traits, functions, and other items which the compiler needs to
> know about.

-- [Rust Tidbits: What is a Lang Item?][lang_items_article] by *Manish
Goregaokar*

Not all lang items are magical, but most magical things are lang items. If you
want a deeper or more comprehensive understanding, I recommend reading Manish's
article in its entirety.

[scottmcm]: https://github.com/scottmcm
[lang_items_list]: https://doc.rust-lang.org/nightly/nightly-rustc/rustc_hir/lang_items/enum.LangItem.html
[lang_items_article]: https://manishearth.github.io/blog/2017/01/11/rust-tidbits-what-is-a-lang-item/
[trait-drop-playground]: https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=793227d3d259143b8ede5da72cdd5636
[intoiterator-playground]: https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=e80adaaa7340646557926b002e770c56
[option-result-playground]: https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=8ad2ed69e17930c4caeda354035e0e94
[display-debug-playground]: https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=e372485a774e64a496b987aef90dfad5
[copy-playground]: https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=29ddc381d68854b231622d8ac90d8266
[deref-playground]: https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=71e06c0c677b4df17831702877e4cb8a
