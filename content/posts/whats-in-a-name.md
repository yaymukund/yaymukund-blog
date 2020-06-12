+++
date = 2020-06-09
title = "What's in a name?"
+++

I decided to catalogue examples of engineers-- primarily software developers--
being asked to change a name to avoid being racist, sexist, transphobic,
ableist, or otherwise bigoted.  About half of these examples come from
responses to [my AskMetaFilter question][ask_mefi].

<!-- more -->

-----

- **?????** ✓ PCI bus uses "target" instead of "slave" after reviewer of the specification objects.
- **2003** ~ [LA County asks manufacturers, suppliers and vendors to stop using "master/slave"][la_county]
- **2011** ✓ [Rename Mozilla libpr0n to image][libpr0n]
- **2011** ✓ [The C Markdown library Upskirt renamed to Sundown][sundown]
- **2013** ~ ["the Pidora name bears an unfortunate similarity to another word in Russian"][pidora]
- **2013** ✓ [Rename Feedzirra to Feedjira.][feedjira]
- **2013** ✓ [Rename teabag.js to teaspoon][teaspoon]
- **2013** ✓ [Rename testacular to karma][karma]
- **2013** ✓ [Use gender-neutral pronouns in the lubuv repository.][lubuv]
- **2013** ✓ [The SCRUM guide renames backlog "grooming" to backlog "refining."][refining]
- **2014** ✓ [Django stops using "master/slave"][django]
- **2014** ✓ [Drupal stops using "master/slave"][drupal]
- **2014** ✗ [Attempt to rename the PHP library ColorJizz.][colorjizz]
- **2015** ✓ [Rename moron.js to objection.js][objectionjs]
- **2015** ~ [Rose Eveleth recommends changing "male/female" connectors to "muffin/pan".][muffinpan]
- **2016** ✓ [Redis stops using master/slave][redis]
- **2017** ✗ [Attempt to rename voluptuous][voluptuous]
- **2017** ✓ [The Ruby gem factory_girl becomes factory_bot.][factory_bot]
- **2018** ✗ [Richard Stallman refuses to remove an abortion joke in the glibc manual.][abortion_joke]
- **2018** ✓ [IETF publishes "Terminology, Power and Oppressive Language"][ietf]
- **2018** ✗ [Rename "pydor," which is a derogatory term for homosexual in Russian.][pydor]
- **2018** ✓ [Rename Erlang library "coon" to "enot."][enot]
- **2018** ✗ [Attempt to rename nipple.js][nipplejs]
- **2018** ✓ [ContributorCovenant: Consider renaming the master branch][contributor_covenant]
- **2019** ✓ [yellowbrick renames `poof()` method to `show()`][yellowbrick]
- **2019** ✓ [Angular.js - Rename blacklist/whitelist to more accurate and appropriate names.][angularjs]
- **2019** ~ [GIMP forked as Glimpse][glimpse] after [GIMP devs refuse to change the name.][gimp]
- **2019** ✗ [Gnome: Replacing "master" reference in git branch names.][gnome]
- **2020** ✗ [RuboCop asked to change its name to avoid casually referencing the police.][rubocop]
- **2020** ✓ [The Go programming language eliminates usages of whitelist/blacklist and master/slave.][golang]
- **2020** ~ [PHP asked to replace whitelist/blacklist with allowlist/blocklist][php]

[ask_mefi]: https://ask.metafilter.com/345497/Help-me-find-all-the-naming-controversies-in-programming
[la_county]: https://www.snopes.com/fact-check/masterslave/
[libpr0n]: https://bugzilla.mozilla.org/show_bug.cgi?id=66984
[sundown]: https://github.com/vmg/sundown/issues/36
[pidora]: https://wiki.cdot.senecacollege.ca/wiki/Pidora_Russian
[feedjira]: https://github.com/feedjira/feedjira/issues/135
[teaspoon]: https://github.com/jejacks0n/teaspoon/issues/40
[karma]: https://github.com/karma-runner/karma/issues/376
[lubuv]: https://github.com/joyent/libuv/pull/1015
[refining]: https://pm.stackexchange.com/a/24134
[django]: https://github.com/django/django/pull/2692
[drupal]: https://www.drupal.org/project/drupal/issues/2275877
[colorjizz]: https://github.com/mikeemoo/ColorJizz-PHP/issues/7
[objectionjs]: https://github.com/Vincit/objection.js/issues/10
[muffinpan]: https://www.lastwordonnothing.com/2015/11/27/a-modest-proposal-for-re-naming-connectors-and-fasteners/
[redis]: https://github.com/antirez/redis/issues/3185
[voluptuous]: https://github.com/alecthomas/voluptuous/issues/287
[factory_bot]: https://thoughtbot.com/blog/factory_bot
[abortion_joke]: https://lwn.net/Articles/770966/
[ietf]: https://tools.ietf.org/id/draft-knodel-terminology-00.html
[pydor]: https://github.com/dohnto/pydor/issues/5
[enot]: https://github.com/comtihon/enot/issues/59
[nipplejs]: https://github.com/yoannmoinet/nipplejs/issues/80
[contributor_covenant]: https://github.com/ContributorCovenant/contributor_covenant/issues/569
[yellowbrick]: https://github.com/DistrictDataLabs/yellowbrick/releases/tag/v1.0.1
[angularjs]: https://github.com/angular/angular/pull/28529
[glimpse]: https://glimpse-editor.github.io/about/#what-is-wrong-with-the-gimp-name
[gimp]: https://web.archive.org/web/20190705135842/https://gitlab.gnome.org/GNOME/gimp/issues/3617
[gnome]: https://mail.gnome.org/archives/desktop-devel-list/2019-May/msg00050.html
[rubocop]: https://metaredux.com/posts/2020/06/08/the-rubocop-name-drama-redux.html
[golang]: https://go-review.googlesource.com/c/go/+/236857/
[php]: https://github.com/php/php-src/pull/5685

<script>
  var items = document.getElementsByTagName("li");
  for (var i=0; i<items.length; i++) {
    items[i].innerHTML = items[i].innerHTML.replace("✓", "<span class=\"green-hl\">✓</span>");
    items[i].innerHTML = items[i].innerHTML.replace("✗", "<span class=\"red-hl\">✗</span>");
  }
</script>

<style>
  .green-hl { color: green; }
  .red-hl { color: red; }
</style>
