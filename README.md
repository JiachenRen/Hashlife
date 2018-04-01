# Hashlife

```
   ▄█    █▄       ▄████████    ▄████████    ▄█    █▄          ▄█        ▄█     ▄████████    ▄████████ 
  ███    ███     ███    ███   ███    ███   ███    ███        ███       ███    ███    ███   ███    ███ 
  ███    ███     ███    ███   ███    █▀    ███    ███        ███       ███▌   ███    █▀    ███    █▀  
 ▄███▄▄▄▄███▄▄   ███    ███   ███         ▄███▄▄▄▄███▄▄      ███       ███▌  ▄███▄▄▄      ▄███▄▄▄     
▀▀███▀▀▀▀███▀  ▀███████████ ▀███████████ ▀▀███▀▀▀▀███▀       ███       ███▌ ▀▀███▀▀▀     ▀▀███▀▀▀     
  ███    ███     ███    ███          ███   ███    ███        ███       ███    ███          ███    █▄  
  ███    ███     ███    ███    ▄█    ███   ███    ███        ███▌    ▄ ███    ███          ███    ███ 
  ███    █▀      ███    █▀   ▄████████▀    ███    █▀         █████▄▄██ █▀     ███          ██████████ 
                                                             ▀                                        
```

Source code of Hashlife, an implementation of Conway's Game of Life using swift and Xcode that is accelerated with the famous hashlife algorithm.

It is a free software available on the [AppStore](https://itunes.apple.com/us/app/hashlife/id1271258065?mt=8). You can also find more about it [here](https://appadvice.com/app/hashlife/1271258065).

## Introduction

### Gesture Controls
* long press to start/stop the simulation
* swipe up with two fingers to accelerate/decelerate the simulation
* pinch to zoom in and out (current cols * rows is displayed on the upper right corner)
* generation and population statistics overlay (could be disabled through Instrumentation tab)
* pan to move around (note that pan gesture could also be treated as draw/erase depending on the context).
* when loaded pattern with "insert" option, tap to drop pattern, press discard to discard loaded pattern.
* when the view disappears, timed refresh automatically stops, because otherwise it would slow down UI performance.
* to enable timed refresh when not in the simulation tab, press "start" in the segmented control provided in Instrumentation tab.

### Patterns
* more than 1000 pattern files from wikipedia
* app supports pattern files with different rule configuration (actually all of them). Default is 23/3
* if config is not default, then the different rule set is displayed to the right in blue.
* press on any of them to segue to the overview
* press "Network" located in the nav bar to do network fetch.

### Inspector
* name, author, rule, source, description and the properly scaled preview of the pattern is provided.
* press on the link to see more details on wikipedia
* press on the pattern preview to segue to Editor view controller.
* press load to choose between overriding the existing universe or insert multiple copies into the current one.
* if a universe is overridden, then the rule for the current pattern is applied, if not, the current rule will not be changed.

### Editor
* rotate and flipping capabilities are supported.
* segmented control for pan, draw, erase. Brush size could be controlled through Instrumentation tab.
* when back to the overview, any edits are saved for the current session
* click on save copy to save your own copy, you can also set the rule

### Instrumentation
* customizing color for grid, cells, and background. 
* customizing the rule
* customizing overlays on the instrumentation tab
* overriding the auto speed to make calculation even faster
* enabling/disabling stats update(turn this off to save some power...). NOTE: stats will update only if this switch is enabled

### Statistics
* Three graphs for population, calculation duration, and empty nodes (since the universe is infinite)
* cached results: the size of the hash map that I use to do save tremendous amount of computation (memoized, not hash life)
* every time when the rule changes, the hash map is emptied because cached results only work with uniform rules.

## Acknowledgements

### Loading large patterns
* large patterns include OTCA cells for "life in life", Turing Machine, a bunch of prime calculators, etc
* it will take about 15 seconds for the hash map to cache enough results to accelerate the calculation
* once warmed up, calculation time will back to normal (this could be confirmed by checking the stats tab)
* rendering large amount of cells take time, adjust the rendering quality in Instrumentation > Cell > [Faster, Balanced, Better] and in Instrumentation > Auto Speed > Max Allowed Rendering Duration to achieve speed boost if needed.

### Compatibility
* Iphone 5s and up. Any versions of ios before 5s will crash the app due to integer overflow. 
* It is not possible to fix because my hashValue generation algorithm produces an oversized int on Iphone 5 and below.

### CoreData
* When the app is opened up for the first time, the app will transcribe all of its rle files into CoreData for the following reasons:
   1) faster performance when loading patterns
   2) better & easier management.
* However, if the user decided to quit during the process in which the app is building up the data base, it is no big deal, because the app will start from where it left off the next time the user opens up the app.


### Known Error
* pressing "Load" on an iPad kills it due to an AlertViewController error that I do not understand.
* update: could be fixed through altering the style of the alert view controller.

