NAME
====

SDL2-ttf - FreeType interface to render text in SDL2

[![Build Status](https://travis-ci.org/thundergnat/SDL2-ttf.svg?branch=master)](https://travis-ci.org/thundergnat/SDL2-ttf)

SYNOPSIS
========

```perl6
use SDL2::Raw;
use SDL2-ttf;

# initialize
TTF_Init();

# set a render color
my $color = TTF_Color(255, 28, 174); # Pink

# select a font file
my $font-file = '/path/to/font/my_Font.ttf';

# open it at a certain point size (May be scaled later by SDL2)
my $font = TTF_OpenFont($font-file, 64);

# render text using the selected font and color as a SDL2 texture
my $raku = SDL_CreateTextureFromSurface(
    SDL_CreateRenderer(), TTF_Render_Blended($font, ' Raku ', $color)
);

# Clean up afterwords
TTF_CloseFont($font);
TTF_Quit();
```

The `$raku` variable now contains a rendered texture that may be used in SDL2.

DESCRIPTION
===========

Provides a convenient interface to FreeType to assist in loading and using TrueType fonts as rendering textures in SDL2.

Needs to have the libsdl2-dev and libsdl2-ttf-dev development libraries installed.

On Debian derived distributions:

    sudo apt-get install libsdl2-dev libsdl2-ttf-dev

Similar for others.

Documentation for the SDL2_ttf library, which works very similar to, but not exactly the same as these bindings: https://www.libsdl.org/projects/SDL_ttf/docs/index.html

Several routines are called slightly differently, and many are not exposed at due to the different requirements and capabilities of the Raku runtime and the C library.

Try out the `ttftest.p6` script in the examples folder to get a feel for how it can be used.

### Enumerations

There are a few enumerations provided.

### <a name="TTF_STYLE"></a>

**TTF_STYLE** - The various font styles that may be available and/or specified:

<table class="pod-table">
<caption>TTF_STYLE</caption>
<thead><tr>
<th>Name</th> <th>value</th>
</tr></thead>
<tbody>
<tr> <td>STYLE_NORMAL</td> <td>0</td> </tr> <tr> <td>STYLE_BOLD</td> <td>1</td> </tr> <tr> <td>STYLE_ITALIC</td> <td>2</td> </tr> <tr> <td>STYLE_UNDERLINE</td> <td>4</td> </tr> <tr> <td>STYLE_STRIKETHROUGH</td> <td>8</td> </tr>
</tbody>
</table>

### <a name="TTF_HINTING"></a>

**TTF_HINTING** - The various font hints that may be available and/or specified:

<table class="pod-table">
<caption>TTF_HINTING</caption>
<thead><tr>
<th>Name</th> <th>value</th>
</tr></thead>
<tbody>
<tr> <td>HINT_NORMAL</td> <td>0</td> </tr> <tr> <td>HINT_LIGHT</td> <td>1</td> </tr> <tr> <td>HINT_MONO</td> <td>2</td> </tr> <tr> <td>HINT_NONE</td> <td>3</td> </tr>
</tbody>
</table>

Subroutines:
------------

#### General

* [TTF_Init](#TTF_Init)

* [TTF_WasInit](#TTF_WasInit)

* [TTF_Quit](#TTF_Quit)

* [TTF_GetError](#TTF_GetError)

* [TTF_OpenFont](#TTF_OpenFont)

* [TTF_OpenFontIndex](#TTF_OpenFontIndex)

* [TTF_CloseFont](#TTF_CloseFont)

#### Attributes

* [TTF_GetFontStyle](#TTF_GetFontStyle)

* [TTF_GetFontStyles](#TTF_GetFontStyles)

* [TTF_SetFontStyle](#TTF_SetFontStyle)

* [TTF_GetFontOutline](#TTF_GetFontOutline)

* [TTF_SetFontOutline](#TTF_SetFontOutline)

* [TTF_GetFontHinting](#TTF_GetFontHinting)

* [TTF_SetFontHinting](#TTF_SetFontHinting)

* [TTF_GetFontKerning](#TTF_GetFontKerning)

* [TTF_SetFontKerning](#TTF_SetFontKerning)

* [TTF_FontHeight](#TTF_FontHeight)

* [TTF_FontAscent](#TTF_FontAscent)

* [TTF_FontDescent](#TTF_FontDescent)

* [TTF_FontLineSkip](#TTF_FontLineSkip)

* [TTF_FontFaces](#TTF_FontFaces)

* [TTF_FontFaceIsFixedWidth](#TTF_FontFaceIsFixedWidth)

* [TTF_FontFaceFamilyName](#TTF_FontFaceFamilyName)

* [TTF_FontFaceStyleName](#TTF_FontFaceStyleName)

* [TTF_GlyphIsProvided](#TTF_GlyphIsProvided)

* [TTF_GlyphMetrics](#TTF_GlyphMetrics)

* [TTF_GetTextSize](#TTF_GetTextSize)

#### Rendering

* [TTF_Color](#TTF_Color)

* [TTF_Render_Solid](#TTF_Render_Solid)

* [TTF_Render_Shaded](#TTF_Render_Shaded)

* [TTF_Render_Blended](#TTF_Render_Blended)

* [TTF_Render_Blended_Wrapped](#TTF_Render_Blended_Wrapped)

### Rendering modes

  * Solid - Quick and Dirty

    * <p>Create an 8-bit palettized surface and render the given text at fast quality with the given font and color. The pixel value of 0 is the colorkey, giving a transparent background when blitted. Pixel and colormap value 1 is set to the text foreground color. This results in no box around the text, but the text is not as smooth.</p>

  * Shaded - Slow and Nice, but with a Solid Box

    * <p>Create an 8-bit palettized surface and render the given text at high quality with the given font and colors. The 0 pixel value is background, while other pixels have varying degrees of the foreground color from the background color. This results in a box of the background color around the text in the foreground color. The text is antialiased. This will render slower than Solid, but in about the same time as Blended mode.</p>

  * Blended - Slow Slow Slow, but Ultra Nice over another image

    * <p>Create a 32-bit ARGB surface and render the given text at high quality, using alpha blending to dither the font with the given color. This results in a surface with alpha transparency, so you don’t have a solid colored box around the text. The text is antialiased. This will render slower than Solid, but in about the same time as Shaded mode. Use this when you want high quality, and the text isn’t changing too fast.</p>

    *  *  *  *  *

### <a name="TTF_Init"></a> `TTF_Init()`

  * Initialize the truetype font API.

  * Must be called before using other functions in this library, except TTF_WasInit or TTF_Color.

  * SDL does not have to be initialized before this call.

  * Takes: Nothing.

  * Returns: 0 on success, -1 on any error

### <a name="TTF_WasInit"></a> `TTF_WasInit`

  * Query the initilization status of the truetype font API.

  * Takes: Nothing.

  * Returns: 1 if already initialized, 0 if not initialized.

### <a name="TTF_Quit"></a> `TTF_Quit`

  * Shutdown and cleanup the truetype font API.

  * Takes: Nothing.

  * Returns: Nothing.

### <a name="TTF_GetError"></a> `TTF_GetError`

  * Returns the last error set as a string.

  * Takes: Nothing

  * Returns: String.

### <a name="TTF_OpenFont"></a> `TTF_OpenFont($file, $ptsize)`

  * Load file for use as a font, at ptsize size.

  * Takes:

    * $file - File name to load font from.

    * $ptsize - Point size (based on 72DPI) to load font as. Basically pixel height.

  * Returns: Pointer to the font as a TTF_Font. NULL is returned on error.

### <a name="TTF_OpenFontIndex"></a> `TTF_OpenFontIndex($file, $ptsize, $index)`

  * Load file for use as a font, at ptsize size, selecting $index face.

  * Takes:

    * $file - File name to load font from.

    * $ptsize - Point size (based on 72DPI) to load font as. Basically pixel height.

    * $index - Choose a font face from a file containing multiple font faces. The first face is always index 0.

  * Returns: Pointer to the font as a TTF_Font. NULL is returned on error.

### <a name="TTF_CloseFont"></a> `TTF_CloseFont($font)`

  * Free the memory used by font, and free font itself as well.

  * Takes: $font - Pointer to loaded font.

  * Returns: Nothing.

### <a name="TTF_GetFontStyle"></a> `TTF_GetFontStyle($font)`

  * Get the rendering style of the loaded font.

  * Takes: $font - Pointer to loaded font.

  * Returns: The bitwise or of the set styles codes. See [the TTF_STYLE ENUM](#TTF_STYLE)

### <a name="TTF_GetFontStyles"></a> `TTF_GetFontStyles($font)`

  * Get the rendering style of the loaded font, enumerated list.

  * Takes: $font - Pointer to loaded font.

  * Returns: An enumerated list of the set styles. See [the TTF_STYLE ENUM](#TTF_STYLE)

### <a name="TTF_SetFontStyle"></a> `TTF_SetFontStyle($font, $style)`

  * Set the rendering style of the loaded font.

  * Takes:

    * $font - Pointer to loaded font.

    * $style - The bitwise or of the desired styles codes. See [the TTF_STYLE ENUM](#TTF_STYLE)

  * Returns: Nothing

### <a name="TTF_GetFontOutline"></a> `TTF_GetFontOutline($font)`

  * Get the current outline size of the loaded font.

  * Takes: $font - Pointer to loaded font.

  * Returns: The size of the outline currently set on the font, in pixels.

### <a name="TTF_SetFontOutline"></a> `TTF_SetFontOutline($font, $outline)`

  * Get the current outline size of the loaded font.

  * Takes:

    * $font - Pointer to loaded font.

    * $outline - The size of outline desired, in pixels.

  * Returns: Nothing.

### <a name="TTF_GetFontHinting"></a> `TTF_GetFontHinting($font)`

  * Get the current hinting setting of the loaded font.

  * Takes: $font - Pointer to loaded font.

  * Returns: The hinting type matching one of the enumerated values. See [the TTF_HINTING ENUM](#TTF_HINTING)

### <a name="TTF_SetFontHinting"></a> `TTF_SetFontHinting($font, $hint)`

  * Set the current hinting setting of the loaded font.

  * Takes:

    * $font - Pointer to loaded font.

    * $hint - One of the enumerated Hint values. See [the TTF_HINTING ENUM](#TTF_HINTING)

  * Returns: Nothing.

### <a name="TTF_GetFontKerning"></a> `TTF_GetFontKerning($font)`

  * Get the current kerning setting of the loaded font.

  * Takes: $font - Pointer to loaded font.

  * Returns: Returns: 0(zero) if kerning is disabled; a non-zero value when enabled.

### <a name="TTF_SetFontKerning"></a> `TTF_SetFontKerning($font, $allowed)`

  * Set the current hinting setting of the loaded font.

  * Takes:

    * $font - Pointer to loaded font.

    * $allowed - 0 to disable kerning; non-zero to enable kerning. The default is 1, enabled.

  * Returns: Nothing.

### <a name="TTF_FontHeight"></a> `TTF_FontHeight($font)`

  * Get the maximum pixel height of all glyphs of the loaded font. Minimum size for adjacent rows of text to not overlap.

  * Takes: $font - Pointer to loaded font.

  * Returns: The maximum pixel height of all glyphs in the font.

### <a name="TTF_FontAscent"></a> `TTF_FontAscent($font)`

  * Get the maximum pixel ascent of all glyphs of the loaded font. - The maximum distance from the baseline to the top.

  * Takes: $font - Pointer to loaded font.

  * Returns: The maximum pixel ascent of all glyphs in the font.

### <a name="TTF_FontDescent"></a> `TTF_FontDescent($font)`

  * Get the maximum pixel descent of all glyphs of the loaded font. - The maximum distance from the baseline to the bottom.

  * Takes: $font - Pointer to loaded font.

  * Returns: The maximum pixel descent of all glyphs in the font.

### <a name="TTF_FontLineSkip"></a> `TTF_FontLineSkip($font)`

  * Get the recommended pixel height of a rendered line of text of the loaded font. - Usually larger than the TTF_FontHeight of the font.

  * Takes: $font - Pointer to loaded font.

  * Returns: The maximum pixel height of all glyphs in the font.

### <a name="TTF_FontFaces"></a> `TTF_FontFaces($font)`

  * Get the number of faces ("sub-fonts") available in the loaded font.

  * Takes: $font - Pointer to loaded font.

  * Returns: The number of faces in the font.

### <a name="TTF_FontFaceIsFixedWidth"></a> `TTF_FontFaceIsFixedWidth($font)`

  * Test if the current font face of the loaded font is a fixed width font.

  * Takes: $font - Pointer to loaded font.

  * Returns: >0 if $font is a fixed width font. 0 if not a fixed width font.

### <a name="TTF_FontFaceFamilyName"></a> `TTF_FontFaceFamilyName($font)`

  * Get the current font face family name from the loaded font.

  * Takes: $font - Pointer to loaded font.

  * Returns: The current family name of the face of the font, or NULL if not available.

### <a name="TTF_FontFaceStyleName"></a> `TTF_FontFaceStyleName($font)`

  * Get the current font face style name from the loaded font.

  * Takes: $font - Pointer to loaded font.

  * Returns: The current style name of the face of the font, or NULL if not available.

### <a name="TTF_GlyphIsProvided"></a> `TTF_GlyphIsProvided($font, $character or $ordinal)`

  * Get the status of the availability of the glyph for $character from the loaded font.

  * Takes:

    * $font - Pointer to loaded font.

    * Either: $character - String containing the $character to check for.

    * Or: $ordinal - Integer $ordinal of character.

  * Returns: The index of the glyph location in the font for $character, or 0 for an undefined character code. (Note: returns the font file index, NOT the character ordinal.)

### <a name="TTF_GlyphMetrics"></a> `TTF_GlyphMetrics($font, $character)`

  * Get the metrics of the char given in $character from the loaded font.

  * Takes:

    * $font - Pointer to loaded font.

    * $character - String containing the character to get metrics for.

  * Returns: A hash containing the following information:

    * :font(TTF_FontFaceFamilyName($font)) - The Family Face name

    * :style(TTF_FontFaceStyleName($font)) - The style

    * :char($character) - The charcter checked

    * :$min-x - The minimum X offset into the character.

    * :$max-x - The maximum X offset into the character.

    * :$min-y - The minimum Y offset into the character.

    * :$max-y - The maximum Y offset into the character.

    * :$advance - The distance from the end of the previous glyph to the start of the next.

Glyph Metrics explained: (image copyright libsdl.org)

![Font Metrics][glyph-metric-image]

[glyph-metric-image]: https://www.libsdl.org/projects/SDL_ttf/docs/metrics.png "Glyph metrics"

### <a name="TTF_GetTextSize"></a> `TTF_GetTextSize($font, $text)`

  * Get the width and height in pixels of the given text in the currently loaded font.

  * Takes:

    * $font - Pointer to loaded font.

    * $text - Text string to get the dimensions.

  * Returns: A list of Pairs

    * :width(width)

    * :height(height)

### <a name="TTF_Color"></a> `TTF_Color($red, $green, $blue, $alpha = 255)`

  * Generate a packed ARGB TTF_color suitable to pass to the rendering routines.

  * Takes:

    * $red - 0-255 integer value for red.

    * $green - 0-255 integer value for green.

    * $blue - 0-255 integer value for blue.

    * $alpha - 0-255 integer value for alpha. Optional, default 255

  * Returns: The packed TTF_Color.

### <a name="TTF_Render_Solid"></a> `TTF_Render_Solid($font, $fg)`

  * Render the passed $text using $font with $fg color onto a new surface, using Solid mode.

  * Takes:

    * $font - Pointer to loaded font.

    * $text - Text string to render.

    * $fg - TTF_Color to use as the foreground color.

  * Returns: A pointer to a new SDL Surface.

### <a name="TTF_Render_Shaded"></a> `TTF_Render_Shaded($font, $fg, $bg)`

  * Render the passed $text using $font with $fg color onto a new $bg colored surface, using Shaded mode.

  * Takes:

    * $font - Pointer to loaded font.

    * $text - Text string to render.

    * $fg - TTF_Color to use as the foreground color.

    * $bg - TTF_Color to use as the background color.

  * Returns: A pointer to a new SDL Surface.

### <a name="TTF_Render_Blended"></a> `TTF_Render_Blended($font, $fg)`

  * Render the passed $text using $font with $fg color onto a new surface, using Blended mode.

  * Takes:

    * $font - Pointer to loaded font.

    * $text - Text string to render.

    * $fg - TTF_Color to use as the foreground color.

  * Returns: A pointer to a new SDL Surface.

### <a name="TTF_Render_Blended_Wrapped"></a> `TTF_Render_Blended_Wrapped($font, $fg, $length)`

  * A convenience routine to render wrapped text, in Blended mode.

  * Takes:

    * $font - Pointer to loaded font.

    * $text - Text string to render.

    * $fg - TTF_Color to use as the foreground color.

    * $length - Length in pixels to use as a wrap threshold.

  * Returns: A pointer to a new SDL Surface.

AUTHOR
======

SDL2_ttf library: Sam Lantinga

Raku bindings: Steve Schulze (thundergnat)

COPYRIGHT AND LICENSE
=====================

Copyright 2020 Steve Schulze (thundergnat)

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

