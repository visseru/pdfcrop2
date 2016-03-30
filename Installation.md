# TOC #
  1. [Introduction](http://code.google.com/p/pdfcrop2/wiki/Introduction)
  1. Installation
  1. [Usage](http://code.google.com/p/pdfcrop2/wiki/Usage)
  1. [Changelog](http://code.google.com/p/pdfcrop2/wiki/Changelog)

# Installation files #

Installation files can be obtained from [Downloads section](http://code.google.com/p/pdfcrop2/downloads/list).

## Naming scheme ##
Because all files are provided as patches which must match exactly patched file, naming scheme of files is important. Example below provide description:

  * `patch_0.3_pdfcrop_1.5.gz` - patch version 0.3 which should be applied to orginal, unmodified pdfcrop version 1.5
  * `patch_0.3_patch_0.1_pdfcrop_1.5.gz` - patch version 0.3 which should be applied to pdfcrop v.1.5 already patched by patch version 0.1

## Depreciated files ##
Files in depreciated section shall not be used. They are recalled because some bugs have been discovered in them.

# Installation manual #

  1. Download patch file appropriate for your version of pdfcrop
  1. Place the patch in directory where `pdfcrop.pl` resides
  1. Apply the patch by:

> `zcat patchfile.gz | patch `