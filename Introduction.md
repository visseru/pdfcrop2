# TOC #
  1. Introduction
  1. [Installation](http://code.google.com/p/pdfcrop2/wiki/Installation)
  1. [Usage](http://code.google.com/p/pdfcrop2/wiki/Usage)
  1. [Changelog](http://code.google.com/p/pdfcrop2/wiki/Changelog)

# Introduction #

## What is pdfcrop? ##
pdfcrop is a perl script written by Heiko Oberdiek which crops pages of PDF documents to the size of visible page elements. In addition it can add some user-defined margins. pdfcrop needs [GhostScript](http://www.cs.wisc.edu/~ghost/) and [pdfTeX](http://en.wikipedia.org/wiki/PdfTeX) to work.

## What is this patch for? ##
pdfcrop measures and crops each page individually. This approach is not suitable when you would like to print using some automatic scaling feature like "Fit to page" because it causes pages to be scaled with different scale ratio. Thus, at output fonts or other elements can differ between pages where they should be same size.

The patch (pdfcrop2) provides different cropping approach which solve problems mentioned above while preserving orginal mode. It also add some minor features.

# Features #

## Three cropping modes ##
  1. **Standard** - the way in which orginal pdfcrop works
  1. **Auto** - the script calculates minimum bounding-box for whole document. Each page is cropped to the same dimensions, minimum which can fit elements on each page of document. The cropping box is resized every time one of bounding-box coordinates sticks out of current cropping box coordinates.
  1. **Auto2** - the script calculates minimum bounding-box for whole document like in Auto mode, however, for each page cropping box is first moved to cover as much bounding-box as it can. If some elements still do not fit in, cropping-box is resized.
  1. **Absolute** - the way in which Free PDF Tools (on Windows) works - the script gets paper dimensions via pdfinfo tool (available with xpdf). Values provided by margin option are subtracted from paper dimensions, thus they means how much to cut out from each side of the page.

## Intelligent auto and semi-auto mode ##
Because some PDFs are crippled, for example text flows out into the margins on some pages or some pages have more elements than average and you are not interested in keeping them, you can specify pages which will not be taken into accout in calculations of **Auto** and **Auto2** mode.
  * User can exclude pages manually
  * Pages can be excludend automatically based on statistical analysis.
  * User can confirm each page exclusion separately as well as confirm all exclusions at once.
  * Both modes (manual and automatic) can be mixed.

## Units support ##
In addition to orginal **point** units in margin dimensions you can use milimeters, centimeters, inches and pica.