This patch is intend to add following features:

# Main features #
  1. Units support for margin dimensions (pt, mm, in, cm, pica, know any other DTP units? :-) )
  1. Crop all pages to the same size, minimum which allows all content to fit in. This size is determined automatically from max bbox (auto mode).
  1. Crop all pages based on paper size, not bbox. In this mode, margins determine, how much each side of paper to cut out (absolute mode).
  1. User can exclude some pages from size calculations in auto mode
  1. Automatic exclusion of pages from size calculations in auto mode based on statistical analysis. User can confirm each page exclusion separately as well as confirm all exclusions at once. This mode can be mixed with manual page exclusion.

## New ##
  1. Auto2 mode - pdfcrop will try to fit page content by moving crop box before resizing it. This should result in bit smaller output dimensions (while still content fits in). In this mode additional option is supported to set page corner to which crop box should be aligned.

# TODO #
  1. Code optimization/rewriting - move from patch to application.
  1. More robust page size determination in absolute mode.
  1. Error checking
  1. GUI