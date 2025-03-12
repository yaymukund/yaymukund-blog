+++
date = 2025-03-12
title = "Hacking a GPO 746 rotary phone"

[extra]
meta_tags = [
  { property = "og:image", content = "/posts/hacking-a-gpo-746-rotary-phone/og-image.webp" },
  { property = "og:image:alt", content = "A topaz 1970s GPO 746 telephone sat on a desk." }
]
+++

Rotary dial telephones are a fantastic way to start learning about electronics. They're built to be disassembled and serviced [(because they were originally rented!)][rented-telephones]. There are online communities of engineers and enthusiasts who are happy to to share what they know. Most of all, they're beautiful objects that inspire curiosity and nostalgia.

Here's what I'll be making:

<div class="video-container">
    <video 
      controls
      src="/posts/hacking-a-gpo-746-rotary-phone/completed.mp4"
    />
</div>

It's a [GPO (General Post Office) 746 rotary dial telephone][gpo746] that plays
a random song each time you pick up the handset.

<style>
div.video-container {
    display: flex;
    justify-content: center;
}

div.video-container > video {
    width: 100%;
    max-width: 640px;
}
</style>

<!-- more -->

## Overview

The logical core of the GPO 746 is the D92732 circuit board. It connects all of
the different components--- the microphone, rotary dial, ringer bells, switch
hook, and handset speaker. 

For this project, I only cared about the last two:

1. The **switch hook** signals when the handset has been picked up.
2. The **handset receiver** plays music.

{{ image(src="essential-components.webp" title="The essential components" alt="A photo of a telephone with drawing over it. The phone is scribbled over with 'Teensy' written on it. There are arrows pointing to the switch hook and the handset speaker, and musical notes coming out of the handset speaker.") }}

Instead of the circuit board, I used the Teensy to drive all the logic. Instead
of powering it by a cord to the wall, I used a 3xAA battery pack to provide
4.5V, [as the Teensy docs suggest][teensy-power-docs].

## Getting inside the phone

I loosened the screw at the back of the telephone with a flathead screwdriver.
It was held in place with a spring and nut. [This is explained in more detail
here.][opening-the-case]

I took a photo of the circuit...

{{ image(src="inside-the-phone.webp" title="The GPO 746 uncased to show its terminals and all the components") }}

...and then disconnected all the wires!

## Brute-forcing the switch hook terminals

I found [the D92732 circuit diagrams][d92732], but eventually opted for a
brute-force approach.

From reading online, I learned that there are a pair of terminals that connect
to the switch hook. I used a multimeter to check connectivity between every
pair of terminals.

That's `19 choose 2 = 171` combinations.

In my phone, it happened to be terminals T3 and T6. They connected when the
switch hook was released, and disconnected when the switch hook was pressed. If
you're following along, they may be different terminals if you're on another
version of the GPO 746. The meaning may also be reversed (i.e. disconnected =
released, connected = pressed).

## The handset receiver

The handset cord has four wires leaving it: two for the receiver and two for
the microphone. To identify the wires for the receiver, I just unscrewed the
receiver-end of the handset and noted the colors.

{{ image(src="inside-the-handset.webp" title="GPO 746 handset unscrewed to reveal red and green wires") }}

## Wiring the terminals

Then I made the following four connections to the terminals:

{{ image(src="terminal-connections.webp" title="An image of the circuit board terminals") }}

1. The **red** and **green** handset receiver wires connect at **T11** and
   **T13** respectively.
2. The **brown** and **black** switch hook wires connect at **T3** and **T6**
   respectively.

I chose T11 and T13 for the handset receiver wires because they happened to be
"free." That is, they didn't seem to be connected to anything else.

## Wiring the audio breakout board

**Red** goes to the **sleeve** and **green** goes to the **tip**. You may be
able to switch these around--- I don't think they are polarised--- but I did
not test it.

{{ image(src="audio-breakout.webp" title="An image of the audio breakout board connections") }}

Then, I soldered the Teensy Audio Shield to the Teensy using [pins
headers][teensy-pin-headers] and connected the audio breakout board to the
Teensy Audio Shield using a short 3.5mm audio cable.

### Wiring the Teensy

{{ image(src="teensy-connections.webp" title="An image of the Teensy inputs") }}

1. **Red** and **white** connect the battery pack to Teensy's **ground** and
   **Vin (3.6 to 5.5 volts)** pins respectively.
2. **Brown** and **black** connect the switch hook terminals to Teensy's
   **Input 0** and **ground** respectively.

The [Teensy Pins reference][teensy4-pins] is excellent. The ground pins are
interchangeable, but be sure to use the **Vin (3.6 to 5.5 volts)** and **not**
the 3.3V input because the battery pack will exceed 3.3V.

### Battery pack

Finally, I connected the **red** and **black** wires from the Teensy to a
3xAA (4.5V) battery pack and toggle switch.

{{ image(src="battery-pack.webp" title="An image of the toggle switch connected to the battery pack") }}

### The complete circuit

{{ image(src="complete-circuit.webp" title="An illustration of the complete circuit on a photo of the GPO 746.") }}

## Software considerations

[I've appended the code for reference](#code).

The PJRC website has [instructions on flashing the Teensy 4][teensy4-flashing].
I disconnected the Teensy from the battery pack. Then, I used a micro-B USB
cable to connect it to my computer and used `teensy-loader-cli` to transfer a
compiled image.

I [wrapped everything in a Nix flake][teensyphone] so you can see exactly what
is needed.

## Costs

I ended up spending about £300 for everything, but it could definitely be a lot
cheaper:

```
  £54 TS101 soldering iron
+ £52 Omnifixo "third hand" tool
+ £42 Ratcheted crimper
+ £11 Wirestrippers
+ £6 Wirecutters

= £165 for tools

  £65 GPO 746
+ £22 Teensy
+ £14 Audio adapter
+ £11 microSD card
+ £10 22 AWG Wire
+ £7 Heat shrink Tubing
+ £6 3xAA Battery packs
+ £5 Audio breakout board
+ £5 Toggle switches
+ £1 Header pins

= £311 total
```

If you're trying to save money, another option is to visit a local hackerspace.
They may provide tools and components for free or very cheap.

## Final thoughts

After starting this project, I also felt emboldened to fix some things around
the house: a damaged power cord on my hand blender, an electric toothbrush, the
battery on my headphone amp.

As for the telephone, I'd like to get the rotary dial, ringer, and microphone
working. The ringer may need a 9V battery. It seems like a hassle to require
two kinds of batteries, so that's an open question.

Overall, I'm very pleased with how it turned out. 

{{ image(src="gpo746-posing.webp" title="A GPO 746 on a table in front of a pile of books.") }}

## Inspiration & resources

* [britishtelephones.com: "TELEPHONE No. 746 &
8746"][british-telephones-gpo746]: Website about the history of British
telephones. Includes circuit diagrams, part numbers, instructions to modify
them, and so on.
* [YouTube: "Make your own wedding audio guestbook - a step-by-step guide!"
(Playful Technology)][playful-tutorial]: The excellent tutorial that inspired
this.
* [YouTube: "Beginner's Guide to Soldering Electronics Part 1 (Branchus
Creations)][soldering-tutorial]: There are a million and one guides to
soldering, but this is my favorite.
* [YouTube: "Shenzhen: The Silicon Valley of Hardware" by Andrew "bunnie"
Huang][bunnie-documentary]: I love all of bunnie's talks. If this topic
interests you, you might too.

## Appendix

### Tools

- [TS101 Soldering Iron][ts101]
- [Omnifixo Third Hand Tool][omnifixo]
- Multimeter
- Wirestrippers: Make sure it matches your wire gauge.
- Wire Cutters: Make sure it matches your wire gauge.
- A Flathead Screwdriver

### Materials

- [GPO 746][gpo746]: I'm in the UK. For an American phone, try the
[Western Electric 500][we500].
- [Teensy 4.0][teensy4]: The Teensy 4.1 is also fine.
- [Teensy Audio Shield (for Teensy 4.0)][audioshield]
- A microSD card to hold the music.
- 22 AWG solid-core wire: Initially used 28 AWG wire, but it snaps too easily.
- Soldering materials--- solder, heat shrink tubing, ventilation.
- [Micro-B USB Cable][usbcable]
- 3.5mm audio cable to connect the Teensy to the handset receiver. 

### Optional

- 3xAA Battery pack: To power it without a USB cable.
- Toggle switch for the battery: Why drain the battery when it's not in use?
- [Pin headers][teensy-pin-headers] and jumper cable: These let me easily
switch the inputs/outputs.
of the Teensy without soldering - useful for reuse and experimentation.
- [3.5mm jack breakout board][breakout-board]: Lets you avoid cutting an audio cable.
- [Fork terminals][fork-terminals]: Connects wire to terminals. Must match
wire and terminal sizes.

### Code

For the latest version of this code, please check [the
repository][teensyphone].

```cpp
#include <Arduino.h>
#include <Audio.h>
#include <AudioStream.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <Bounce2.h>

#define DEBOUNCE_INTERVAL_MS 40
#define SERIAL_WAIT_TIMEOUT_MS 5000
#define SERIAL_BAUD_RATE 9600

// Pins
#define SDCARD_CS_PIN 10
#define SDCARD_MOSI_PIN 11
#define SDCARD_SCK_PIN 14
#define HOOK_PIN 0

#define DEBUG false

#define debug_printf(...) \
  do { if (DEBUG) Serial.printf(__VA_ARGS__); } while (0)

// Handset audio output.
AudioOutputI2S audio_out;
// Play files from the SD card.
AudioPlaySdWav play_wav;
// 
// There are two connections for L and R speakers.
AudioConnection wav_out_0(play_wav, 0, audio_out, 0);
AudioConnection wav_out_1(play_wav, 0, audio_out, 1);

// The chip on the Teensy Audio Shield that lets you control the microphone
// input and headphone output.
AudioControlSGTL5000 sgtl5000;

// A debounced "button" for the hook switch.
Bounce2::Button hook_switch_button = Bounce2::Button();

// Upload these to the SD card.
const char* FILENAMES[] = { "foo.wav", "bar.wav", "baz.wav" };

void setup_debugging() {
  if (!DEBUG) {
    return;
  }

  Serial.begin(SERIAL_BAUD_RATE);

  while (!Serial && millis() < SERIAL_WAIT_TIMEOUT_MS) {
    // Wait for the serial port to connect.
  }

  debug_printf("AUDIO_BLOCK_SAMPLES is %d.\n", AUDIO_BLOCK_SAMPLES);

  if (CrashReport) {
    /* print info (hope Serial Monitor windows is open) */
    Serial.print(CrashReport);
  }
}

extern "C" void setup(void) {
  setup_debugging();

  // Initialise random.
  uint32_t seed = micros();
  debug_printf("random seed is %d.\n", seed);
  randomSeed(seed);

  // 120 blocks of audio memory from which you construct audio_block_t.
  AudioMemory(120);

  // Enable headphone/mic.
  sgtl5000.enable();
  sgtl5000.volume(0.5);

  // Setup SD card.
  SPI.setMOSI(SDCARD_MOSI_PIN);
  SPI.setSCK(SDCARD_SCK_PIN);

  hook_switch_button.attach(HOOK_PIN, INPUT_PULLUP);
  hook_switch_button.interval(DEBOUNCE_INTERVAL_MS);
  hook_switch_button.setPressedState(HIGH);


  if (!(SD.begin(SDCARD_CS_PIN))) {
    while (1) {
      debug_printf("Unable to access the SD card.\n");
      delay(1000);
    }
  }

  debug_printf("HIGH is %d\n", HIGH);
  debug_printf("LOW is %d\n", LOW);
}

extern "C" int main(void) {
  setup();

  while (1) {
    hook_switch_button.update();

    if (hook_switch_button.changed()) {
      debug_printf("Hook switch is now %d.\n", hook_switch_button.read());
    }

    if (hook_switch_button.isPressed() && play_wav.isPlaying()) {
      play_wav.stop();
    }

    if (hook_switch_button.fell() && play_wav.isStopped()) {
      int index = random(std::size(FILENAMES));
      debug_printf("Playing track #%d: %s.\n", index, FILENAMES[index]);
      play_wav.play(FILENAMES[index]);
    }
  }
}
```

[audioshield]: https://www.pjrc.com/store/teensy3_audio.html
[breakout-board]: https://thepihut.com/products/sparkfun-trrs-3-5mm-jack-breakout
[british-telephones-gpo746]: https://www.britishtelephones.com/t746.htm
[bunnie-documentary]: https://www.youtube.com/watch?v=SGJ5cZnoodY
[d92732]: https://www.britishtelephones.com/telunitd.htm
[fork-terminals]: https://uk.rs-online.com/web/p/fork-terminals/1788693
[gpo746]: https://en.wikipedia.org/wiki/GPO_telephones#Type_746
[omnifixo]: https://omnifixo.com/
[opening-the-case]: https://www.britishtelephones.com/t746.htm#case
[playful-tutorial]: https://www.youtube.com/watch?v=dI6ielrP1SE
[rented-telephones]: https://www.britishtelephones.com/histtr.htm
[soldering-tutorial]: https://www.youtube.com/watch?v=M2Jf8cebwCs
[teensy-pin-headers]: https://www.pjrc.com/store/header_24x1.html
[teensy-power-docs]: https://www.pjrc.com/teensy/external_power.html
[teensy4-flashing]: https://www.pjrc.com/teensy/first_use.html
[teensy4-pins]: https://www.pjrc.com/store/teensy40.html#pins
[teensy4]: https://www.pjrc.com/store/teensy40.html
[teensyphone]: https://git.sr.ht/~yaymukund/teensyphone
[ts101]: https://www.tomshardware.com/reviews/miniware-ts101-smart-soldering-iron-review-lots-of-options
[usbcable]: https://www.pjrc.com/store/cable_usb_micro_b.html
[we500]: https://en.wikipedia.org/wiki/Model_500_telephone

<style>
div.post img {
    max-width: 640px;
    padding-left: 1.25rem;
}

pre.language-cpp {
    max-height: 400px;
}
</style>
