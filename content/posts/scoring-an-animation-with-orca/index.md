+++
date = 2022-02-18
title = "Scoring an animation with Orca"
description = "I'll demonstrate step-by-step how I scored an animation using the Orca esoteric programming language."

[extra]
meta_tags = [
  { property = "og:image", content = "/posts/scoring-an-animation-with-orca/og-image.png" },
  { property = "og:image:alt", content = "A screenshot of an Orca program, consisting of various instruments, many commented: 'Melody Glockenspiel', 'Main beat', 'Mean beat: drums', 'Intro beat', 'Pluck', 'Worm taps'" }
]
+++

In this post, I'll demonstrate how to score an animation using [Orca][orca].

- [What is Orca?](#what-is-orca)
- [The final score](#the-final-score)
- [What is a score?](#what-is-a-score)
- [Learning how to wait](#learning-how-to-wait)
- [Wiring up sounds](#wiring-up-sounds)
- [Timers in practice](#timers-in-practice)
- [Conclusion](#conclusion)

<!-- more -->

## What is Orca?

[Orca][orca] is an [esoteric programming language][esolang] for composing
music. An Orca program is somewhere between a circuit diagram and an ASCII
roguelike. But you don't need to know either of those things to get started---
in an interview with its creator Devine Lu Linvega of the programming duo
[Hundred Rabbits][100rabbits]:

>  I was always kind of aiming, I guess, at children. I was like, if you can
>  just open the page and put that in front of a kid, could they figure it out?
>  It wouldn’t take that many keystrokes until they figure out which… like [the
>  operator] `E` will start moving, and through the act of playing they'll find
>  their way without having to read the documentation.
> 
> --- from [Devine's interview on the Future of Coding podcast][orca_interview]

[orca]: https://wiki.xxiivv.com/site/orca.html
[esolang]: https://en.wikipedia.org/wiki/Esoteric_programming_language
[100rabbits]: https://100r.co
[orca_interview]: https://futureofcoding.org/episodes/045#89

Some resources to get started:

- [Orca Sequencer Intro (Experimental Livecoding!) by Allieway Audio on
  YouTube](https://www.youtube.com/watch?v=RaI_TuISSJE): This is how I got
  interested in Orca. It's an excellent introduction--- jumps to the good stuff
  without getting lost in the details. Note: Some of the operators have changed
  since this video was made, but the core principles haven't.
- [Official Documentation](https://wiki.xxiivv.com/site/orca.html)
- [Making a song in
  1h](https://www.twitch.tv/videos/1024098887?collection=Alz0SKVffxam4w):
  Beginning with a blank canvas, I try to learn Orca and make a tune in an
  hour.

## The final score

<video 
  controls
  width="640"
  aria-describedby="example-11-desc"
  src="/posts/scoring-an-animation-with-orca/11-completed-score.mp4"
  class="completed-animation"
/>
<p id="example-11-desc" class="aria-description">
  The completed score, consisting of all the techniques described in this post.
</p>

Although it might seem complicated--- especially if you're not familiar with
Orca--- this program is actually the result of building on a few core ideas.
As you read this, I hope it will feel like a natural progression to go from one
step to the next.

Ok, now let's start at the beginning.

## What is a score?

Scoring an animation requires timing sounds to events on screen. For example,
when a piece of glass shatters in the animation, there should be a crash sound.
Let's say this happens on frame 21. Using Orca, how do you play a sound on the
21st frame and then never again?

The answer to this was not obvious to me. Most Orca compositions, at the time
of writing this, consisted of loops. I could not find any examples that did
what I wanted. But since we have access to the clock frame using the `C`
operator, this feels like it *should* be possible.

Here's one way to do it:

## Learning how to wait

**Note**: Throughout this post, I will refer to hexadecimal numbers using the
prefix `0x`. For example, `0x10` is decimal 16.

**Note 2**: I will refer to the last digit in a hexadecimal number as the
"ones' digit" and the second-to-last digit as the "sixteens' digit." For
example, `0x10`'s ones' digit is `0` and its sixteens' digit is `1`.

Ok, let's begin.

<div class="first orca-example"> <div>

  First, use a pair of hexadecimal clocks `Cf` and `fCf`:

  - The *frame count* is at the bottom right, a monotonically increasing
    number.
  - `Cf` mods the frame count by `0xf`, or 16, to output the ones' digit, a
    number from `0x0` to `0xe`.
  - `fCf` also divides the frame count by `0xf`, or 16, to output the sixteens'
    digit. </div> <video aria-describedby="example-1-desc" playsinline autoplay
    loop muted src="/posts/scoring-an-animation-with-orca/01-clock.mp4" /> <p
    id="example-1-desc" class="aria-description"> A hexadecimal clock in
    Orca--- written `Cf`--- that outputs an increasing number from `0x0` to
    `0xe`. Upon reaching `0xe`, it starts over from `0x0`. Also, a second clock
    written `fCf` that produces a similar output, but which increases at 1/16
    the rate of the first clock. </p> </div> <div class="orca-example"> <div>

  Next, check the outputs using `F`. The `F` operator will output
  a bang (`*`) if their inputs on either side are equal.

  </div>
  <video 
    aria-describedby="example-2-desc"
    playsinline
    autoplay
    loop
    muted
    src="/posts/scoring-an-animation-with-orca/02-clock-with-if.mp4"
  />
  <p id="example-2-desc" class="aria-description">
    There are now two `F`s. The first `F` compares the sixteens' digit and
    outputs a `*` if it is `1`. The second `F` checks if the ones' digit is
    `5`.
  </p>
</div>
<div class="orca-example">
  <div>

  Finally, `AND` the outputs of both the `F`s into a single `*`:

  - `Y`, the 'yumper' operator, just copies the input horizontally.
  - `f` here is a lowercase `F` that only operates on a bang.
  
  On frame `0x15`, the `f` outputs a bang.

  **Note:** If the `f` were uppercase, it would incorrectly output a bang when
  both inputs are empty (i.e. when neither ones' nor sixteens' digits matched.)

  </div>
  <video 
    aria-describedby="example-3-desc"
    playsinline
    autoplay
    loop
    muted
    src="/posts/scoring-an-animation-with-orca/03-completed.mp4"
  />
  <p id="example-3-desc" class="aria-description">
    A `Y` carries the output of the sixteens' match to the right. A `f`
    compares both the outputs and bangs on frame 15 when both digits match.
  </p>
</div>

<div class="orca-example">
  <div>

  At this point, I [posted my timer to the Orca thread on
  lines][orca_thread], asking the community if there was a simpler way to do
  this. Devine responded, suggesting this condensed version that uses one fewer
  operator.

  [orca_thread]: https://llllllll.co/t/orca-livecoding-tool/17689/1703

  </div>
  <video 
    aria-describedby="example-4-desc"
    playsinline
    autoplay
    loop
    muted
    src="/posts/scoring-an-animation-with-orca/04-succinct.mp4"
  />
  <p id="example-4-desc" class="aria-description">
    A rearranged version of the previous timer. Now, the ones' output is
    connected directly to the `f` (lowercase), skipping the `F` (uppercase)
    entirely.
  </p>
</div>

### Limitations

Here, it is important to note that this timer does not actually "bang once and
then never again" as originally promised. Since the timer only checks the ones'
and sixteens' digits of the frame number, it will bang at `0x015`, `0x115`,
`0x215`, ...--- every `0x100` or 256 frames. This ends up being about 25
seconds at 120 bpm.

My animation happens to be 15s long, so this was not a problem for me. If
anyone finds an elegant solution to the original problem as stated, I'd love to
see it.

## Wiring up sounds

Now, the fun part. Use this timer to schedule different sounds.

### Playing a note

<div class="first orca-example">
  <div>

  This can be used to play a single midi note.

  </div>
  <video 
    aria-describedby="example-5-desc"
    playsinline
    autoplay
    loop
    muted
    src="/posts/scoring-an-animation-with-orca/05-midi-note.mp4"
  />
  <p id="example-5-desc" class="aria-description">
    Like the previous video, but with a midi note (`:01a`) next to bang. It's
    triggered at frame `0x15`.
  </p>
</div>

### Toggling a loop

<div class="first orca-example">
  <div>

  First, consider a simple drum loop.

  </div>
  <video 
    aria-describedby="example-6-desc"
    playsinline
    autoplay
    loop
    muted
    src="/posts/scoring-an-animation-with-orca/06-drum.mp4"
  />
  <p id="example-6-desc" class="aria-description">
    A simple drum loop, consisting of a `D` wired up to a midi note (`:01a`).
  </p>
</div>
<div class="orca-example">
  <div>

  Then, use an `X` to set the note's velocity, effectively turning the loop
  on or off. Here, it sets the velocity to `0x7`.

  It's a bit silly to use `X` to set a constant value like this, but it should
  make sense in the next step.

  </div>
  <video 
    aria-describedby="example-7-desc"
    playsinline
    autoplay
    loop
    muted
    src="/posts/scoring-an-animation-with-orca/07-drum-switch.mp4"
  />
  <p id="example-7-desc" class="aria-description">
    The same drum loop, but there is now an `X` operator that sets the velocity
    of the midi note to `0x7`.
  </p>
</div>
<div class="orca-example">
  <div>

  Finally, automate this using timers:

  - The drum loop begins muted, its velocity `0x0`.
  - The first timer at frame `0x15` turns on the drum loop by setting its
    velocity to `0xa`.
  - The second timer at frame `0x28` turns it off again by setting the velocity
    to `0x0`.

  </div>
  <video 
    aria-describedby="example-8-desc"
    playsinline
    autoplay
    loop
    muted
    src="/posts/scoring-an-animation-with-orca/08-drum-timers.mp4"
  />
  <p id="example-8-desc" class="aria-description">
    There are two timers. Each activates a lowercase `x` operator to set the
    velocity as described.
  </p>
</div>

### Timing a sequence of notes

<div class="first orca-example">
  <div>

  Play a sequence of notes by combining operators `Z` and `T`:

  - The `Z` counts up from 1 to 5, exactly once.
  - This determines the note output by `T`.
  - The output of `T` is fed to `:`, the midi operator.

  </div>
  <video 
    aria-describedby="example-9-desc"
    playsinline
    autoplay
    loop
    muted
    src="/posts/scoring-an-animation-with-orca/09-sequence.mp4"
  />
  <p id="example-9-desc" class="aria-description">
    The `Z` counts up from 1 to 5. This is fed to `T`, which chooses notes `a`,
    `b`, `c`, `d`, and a blank, in that order. The output of `T` is finally fed
    to a midi operator, which is powered by a `*` held down by `H`.
  </p>
</div>
<div class="orca-example">
  <div>

  Use a timer to control when the sequence plays:

  - `Z` starts at `5`, unlike the previous example, so it doesn't immediately play.
  - The timer fires at frame `0x15` to activate `x`.
  - `x` sets the `Z` back to 0 and causes it to play.

  </div>
  <video 
    aria-describedby="example-10-desc"
    playsinline
    autoplay
    loop
    muted
    src="/posts/scoring-an-animation-with-orca/10-sequence-timer.mp4"
  />
  <p id="example-10-desc" class="aria-description">
    A timer fires at frame `0x15`, which activates the `x`, which sets the
    output of `Z` to `1`, causing it to restart. Then, the sequence plays a
    note as with the previous example.
  </p>
</div>

## Timers in practice

At this point, if you go back to the beginning and see the final composition,
you may notice some differences from the examples. I omitted details to keep
the examples small and easy to understand:

- Instead of repeating `fCf` and `Cf`, the sixteens' and ones' digits are
  stored in variables `a` and `b` and read using `Va` and `Vb`, respectively.
- I often use a timer triggered at frame `0x00` to reset the initial state of
  timed sequences or loops. This allows me to easily replay the composition
  from the beginning using `Ctrl+R`.

## Conclusion

Here's the completed looping animation:

<video 
  controls
  height="500"
  loop
  aria-describedby="example-12-desc"
  src="/posts/scoring-an-animation-with-orca/12-completed-animation.mp4"
  class="completed-animation"
/>
<p id="example-12-desc" class="aria-description">
  A hand reaches to water a plant but drops the cup, which shatters. The plant
  droops, the mug pieces rise and hover in the air above the plant, before
  falling into the pot which we now see contains a worm. The worm is sliced in
  half by a piece of mug, its worm blood spreading around the dirt, before
  gathering and traveling up the stalk of the plant. Zooming in, we see a new
  stem emerge. Its bud sprouts, revealing it has grown pieces of the same mug
  fragments. Zooming out all the way, we see the plant is standing up once
  again. It has an extra stem, which the hand plucks. A worm squirms out of the
  pot and offscreen, and the entire animation loops.
</p>

(If you want to see more of my art, please follow my
[instagram][art_instagram].)

This is only a small taste of what Orca's capable of doing, but I hope it's a
fun read. If you notice any mistakes in this article or want to share feedback,
please reach out. I'd like to do more of these in the future.

[art_instagram]: https://instagram.com/yaymukund.art

<style>
.aria-description { display: none; }
div.orca-example {
  display: flex;
  flex-direction: column-reverse;
  justify-content: space-between;
  align-items: center;
  background-color: var(--color-light);
  margin-bottom: 0.25rem;
  padding: 1rem 1rem 0 0;
}

div.orca-example.first {
  margin-top: 1rem;
}

div.orca-example p {
  margin-top: 0;
}

div.orca-example video {
  margin: 0 0 1rem 1rem;
}

video.completed-animation {
  width: 100%;
}

@media screen and (min-width: 650px) {
  div.orca-example {
    flex-direction: row;
    align-items: flex-start;
  }
}
</style>
