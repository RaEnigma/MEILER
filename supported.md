#MEILER
List of supported MEI elements and attributes

* `<arpeg>`
  * `@color`
  * `@order`
  * `@plist`
  * `@startid`

* `<artic>`
  * `@artic`
  * `@place`

* `<beam>`
  * `@color`

* `<chord>`
  * `@artic`
  * `@beam`
  * `@dur`
  * `@fermata`
  * `@grace`
  * `@oct`
  * `@ornam`
  * `@slur`
  * `@stem.dir`
  * `@tie`
  * `@visible`

* `<dynam>`
  * `@color`
  * `@endid`
  * `@place`
  * `@startid`

* `<ending>`
  * `@n`

* `<f>`

* `<fb>`

* `<fermata>`
  * `@place`
  * `@startid`

* `<fing>`
  * `@place`

* `<hairpin>`
  * `@endid`
  * `@form` (for values 'cres' and 'dim')
  * `@place`
  * `@startid`

* `<harm>`
  * `@place`
  * `@staff`
  * `@tstamp`

* `<measure>`
  * `@metcon`
  * `@n`
  * `@right`

* `<mordent>`
  * `@long`
  * `@place`
  * `@form`
  * `@startid`

* `<mRest>`
  * `@color`
  * `@dur`
  * `@fermata`
  * `@visible`

* `<mSpace>`
  * `@dur`

* `<note>`
  * `@accid`
  * `@accid.ges`
  * `@artic`
  * `@beam`
  * `@dur`
  * `@fermata`
  * `@grace`
  * `@head.color`
  * `@head.shape` (for value 'x')
  * `@oct`
  * `@ornam`
  * `@pname`
  * `@slur`
  * `@staff`
  * `@stem.dir`
  * `@stem.mod`  (for value '1slash')
  * `@tie`
  * `@visible`

* `<octave>`
  * `@color`
  * `@dis`
  * `@dis.place`
  * `@endid`
  * `@lform`
  * `@startid`

* `<pb>`
  * `@n`

* `<pedal>`
  * `@dir`
  * `@form` (for values 'line' and 'pedstar')
  * `@startid`

* `<rest>`
  * `@beam`
  * `@color`
  * `@dur`
  * `@fermata`
  * `@oloc`
  * `@ploc`
  * `@staff`
  * `@visible`

* `<sb>`
  * `@n`

* `<slur>`
  * `@color`
  * `@curvedir` (for values 'above' and 'below')
  * `@endid`
  * `@lform` (for values 'dashed', 'dotted', and 'solid')
  * `@startid`

* `<space>`
  * `@dur`

* `<staffDef>`
  * `@clef.dis`
  * `@clef.dis.place`
  * `@clef.line`
  * `@clef.shape`
  * `@key.accid`
  * `@key.mode`
  * `@key.pname`
  * `@key.sig` (unsupported for value 'mixed')
  * `@lines`
  * `@lines.visible`
  * `@lyric.fam`
  * `@lyric.name`
  * `@lyric.style`
  * `@lyric.weight`
  * `@meter.count`
  * `@meter.rend`
  * `@meter.sym`
  * `@meter.unit`
  * `@n`
  * `@pedal.style` (for values 'line' and 'pedstar')

* `<staffGrp>`
  * `@barthru`
  * `@label`
  * `@label.abbr`
  * `@symbol`

* `<tempo>`
  * `@color`
  * `@place`
  * `@staff`
  * `@startid`
  * `@tstamp` (for value '1')

* `<tie>`
  * `@curvedir` (for values 'above' and 'below')
  * `@startid`

* `<tuplet>`
  * `@bracket.place`
  * `@bracket.visible`
  * __`@num`__
  * __`@num.base`__
  * `@num.format`
  * `@num.visible`
  * `@lform`
  * `@startid`

`att.color` supports HTML 4.01 color names
