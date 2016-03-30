# TOC #
  1. [Introduction](http://code.google.com/p/pdfcrop2/wiki/Introduction)
  1. [Installation](http://code.google.com/p/pdfcrop2/wiki/Installation)
  1. Usage
  1. [Changelog](http://code.google.com/p/pdfcrop2/wiki/Changelog)

# Modes #
The patch provides new option `--mode` which allows you to choose pdfcrop cropping approach. This option can have one of three values: `standard`, `absolute`, `auto`. Standard mode is default one.
## Standard ##
In standard mode pdfcrop act as orginal one, thus it measures bounding-box (the minimal area where actual visible objects fit in) for each page individually, add defined margins to measured dimensions and do a crop. Thus, each page has different size, **size of visible objects plus margins**.
Standar mode requires GhostScript and pdfTeX.
## Absolute ##
Absolute mode causes pdfcrop to get paper size of first page using **pdfinfo** tool. Then, it calculates cropping box by **subtracting given margins from page dimensions**. Thus, in this mode, `--margins` option provides information, how much to crop from page size from each side.
Absolute mode requires pdfinfo (part of Xpdf package) and pdfTeX.
## Auto ##
In auto mode pdfcrop gets bounding-box of each page. Then, cropping box is calculated to fit in every element of each page. This cropping box is common for all pages. Because of that, output pages have same size, suitable for printing with _Fit to page_ scaling.
_Cropping box is calculated as follows: if page elements sticks out from cropping box at specific side of cropping box, cropping box on this side is stretched to fit elements._
## Auto 2 ##
In auto2 mode pdfcrop gets bounding-box of each page. Then, cropping box is calculated to fit in every element of each page. This cropping box is common for all pages. Because of that, output pages have same size, suitable for printing with _Fit to page_ scaling.
_Cropping box is calculated as follows: Cropping box is aligned to a corner of the current bounding-box. If some elements still stick out, cropping box is resized to fit them in._

## Excluding pages for auto and auto2 mode ##
Because some PDFs are crippled, bad formated etc. and some text can flow out to margins, or there are annotations at margins of some pages which you do not want to keep, using auto mode you can exclude some pages from cropping-box calculations to avoid unncessary cropping-box enlargement. That is - the text which 'runs out' does not cause cropping-box to fit it, cropping whole document in more rational way.

### Manual exclusion ###
To exclude some pages manually use `--exclude` option with list of pages (separated by whitespace or comma and enclosed in doublequotes), for example
> `--exclude "12 43 48"`
will exclude pages 12, 43 and 48. The pages do not need to be ordered in exlude option.

### Automatic exclusion ###
Automatic exclusion feture is based on statistical calculations and automatically pick pages to exclude. To use auto exclusion enter word `auto` as `--exclude` argument, like:
> `--exclude auto`
User will be asked for confirmation before selected pages will be really excluded. To assume confirmation for all pages, use "fullauto" instead of "auto", like:
> `--exclude fullauto`
Now, all pages selected by script to exclusion will be automatically excluded without any further questions.

You can change sensitivity of auto-exclusion mechanism using `--sens` option. Default sensitivity value is 3, while lower values (down to 0) will raise sensitivity and higher values will lower it.

_Sensitivity is increased twice in Auto2 mode - this is done by purpose, as two bounding-box sides influences horizontal or vertical dimension of cropping box, while in auto mode only one side of bounding-box decide._

### Mixed exclusion ###
You can mix auto and manual mode. In such case, collections of pages from auto and manual selection will be logically sumed. Confirmation for pages selected in auto mode and simultaneously present in manually selected collection will not be asked (unless you use `fullauto` - then all pages will be assumed confirmed).


# Additional options #

## Units ##

`--unit` option indicates units of margin sizes provided by `--margins` option. You can specify one unit common for all margins. All units are internally converted to points. Accepted units:

|unit symbol|unit|units/point|
|:----------|:---|:----------|
|pt         |point|1          |
|mm         |milimeter|0.3527     |
|cm         |centimeter|0.03527    |
|in         |inch|0.0138     |
|P          |pica|0.083333   |

## Misc ##

  * `--verbose` - turns on information messages of cropping process
  * `--debug` - turns on debug messages. This option automatically forces `--verbose`

## Alignment ##
In auto2 mode you can decide to which corner of cropping box align pages which elements are smaller than it. Use option `--align` with one of parameters: `lt`, `rt`, `lb`, `rb` which means left-top, right-top, left-bottom, right-bottom corner of the cropping box.

# Usage remarks #
TBD

# Usage examples #
> `pdfcrop.pl --mode auto input.pdf output.pdf`
will crop your PDF to size which elements on every page fits in.
> `pdfcrop.pl --mode auto --margins 1 --unit cm input.pdf output.pdf`
this crops your PDF to size which elements on every page fits in with 1cm margins on each side.
> `pdfcrop.pl --mode auto --exclude fullauto input.pdf output.pdf`
will crop PDF to size which elements on every page fits in, trying to ignore broken margins without any questions.
> `pdfcrop.pl --mode absolute --margins "1 2" --unit cm input.pdf output.pdf `
will cut out 1cm from left and rigth and 2cm from top and bottom of the page.