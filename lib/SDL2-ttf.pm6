unit module SDL2-ttf:ver<0.0.3>:auth<zef:thundergnat>;

use NativeCall;

use SDL2::Raw;

my Str $lib;

BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $lib = 'SDL2_ttf'; #right name for Windows dll?
    } else {
        $lib = 'SDL2_ttf';
    }
}

class TTF_Font is export is repr('CPointer') { }

#`[[
###############################################################################
## Color handling doesn't work correctly at this point.
## Apparently need to pass the CStruct by value, and that doesn't seem possible
## in NativeCall right now. There have been a few abortive attempts but they
## haven't made it into a release (and were implemented for libffi but not
## dynCall; the _default_ foreign function interface in Moar).

# Color _should_ be a CStruct similar to:

class SDL_Color is export is repr('CStruct') {
    has uint8 $.r; # red
    has uint8 $.g; # green
    has uint8 $.b; # blue
    has uint8 $.a; # alpha
}

# That doesn't work right now so cheat and pass the CStruct as a packed uint32.
# Build the color struct in the TTF_Color routine.

###############################################################################
]]

sub TTF_Color (Int $r, Int $g, Int $b, Int $a = 255) is export {
    # Use bitmasks and shifts to build the "Struct"
    my uint32 $c = (($a +& 255) +< 24) +| (($b +& 255) +< 16) +| (($g +& 255) +< 8) +| ($r +& 255);
}

enum TTF_STYLE is export (
    :STYLE_NORMAL(0),
    :STYLE_BOLD(1),
    :STYLE_ITALIC(2),
    :STYLE_UNDERLINE(4),
    :STYLE_STRIKETHROUGH(8)
);


enum TTF_HINTING is export (
    :HINT_NORMAL(0),
    :HINT_LIGHT(1),
    :HINT_MONO(2),
    :HINT_NONE(3)
);


sub TTF_Init()
    returns int32
    is native($lib)
    is export
    {*}


sub TTF_WasInit()
    returns int16
    is native($lib)
    is export
    {*}


sub TTF_Quit()
    is native($lib)
    is export
    {*}


sub TTF_GetError()
    returns str
    is native($lib)
    is export
    {*}


# font file path, point size
sub TTF_OpenFont(str, int16)
    returns TTF_Font
    is native($lib)
    is export
    {*}


# font file path, point size, ordinal
sub TTF_OpenFontIndex(str, int16, int32)
    returns TTF_Font
    is native($lib)
    is export
    {*}


sub TTF_CloseFont(TTF_Font)
    is native($lib)
    is export
    {*}


# font
sub TTF_GetFontStyle(TTF_Font)
    returns int16
    is native($lib)
    is export
    {*}


# Sugar routine
sub TTF_GetFontStyles(TTF_Font $font)
    is export
    {
        my $style = TTF_GetFontStyle($font);
        (1,2,4,8).grep( { $_ +& $style } ).map( { TTF_STYLE.^enum_from_value($_) } )
        || ('STYLE_NORMAL').list
    }


# font, style code
sub TTF_SetFontStyle(TTF_Font, int16)
    is native($lib)
    is export
    {*}


# font
sub TTF_GetFontOutline(TTF_Font)
    returns int16
    is native($lib)
    is export
    {*}


# font, outline style
sub TTF_SetFontOutline(TTF_Font, int16)
    is native($lib)
    is export
    {*}


# font
sub TTF_GetFontHinting(TTF_Font)
    returns int16
    is native($lib)
    is export
    {*}


# font, hint (enum) code
sub TTF_SetFontHinting(TTF_Font, int16)
    is native($lib)
    is export
    {*}


# font
sub TTF_FontHeight(TTF_Font)
    returns int16
    is native($lib)
    is export
    {*}


# font
sub TTF_FontAscent(TTF_Font)
    returns int16
    is native($lib)
    is export
    {*}


# font
sub TTF_FontDescent(TTF_Font)
    returns int16
    is native($lib)
    is export
    {*}


# font
sub TTF_FontLineSkip(TTF_Font)
    returns int16
    is native($lib)
    is export
    {*}


# font
sub TTF_GetFontKerning(TTF_Font)
    returns int16
    is native($lib)
    is export
    {*}


# font, 0 / !0 (disable / enable)
sub TTF_SetFontKerning(TTF_Font, int16)
    is native($lib)
    is export
    {*}


# font
sub TTF_FontFaceIsFixedWidth(TTF_Font)
    returns int16
    is native($lib)
    is export
    {*}

# font
sub TTF_FontFaces(TTF_Font)
    returns int16
    is native($lib)
    is export
    {*}

# font
sub TTF_FontFaceFamilyName(TTF_Font)
    returns str
    is native($lib)
    is export
    {*}


# font
sub TTF_FontFaceStyleName(TTF_Font)
    returns str
    is native($lib)
    is export
    {*}


# font, unicode character
multi TTF_GlyphIsProvided(TTF_Font $font, Str $char) returns int16 is export {
    my uint16 $ch = $char.ord;
    TTF_GlyphIsProvided($font, $ch)
}

multi TTF_GlyphIsProvided(TTF_Font $font, Int $ord) returns int16 is export {
    my uint16 $ch = $ord;
    TTF_GlyphIsProvided($font, $ch)
}

multi TTF_GlyphIsProvided(TTF_Font, uint16)
    returns int16
    is native($lib)
    {*};


# font, character
sub TTF_GlyphMetrics(TTF_Font $font, str $ch) is export {
    my int16 $min-x;
    my int16 $max-x;
    my int16 $min-y;
    my int16 $max-y;
    my int16 $advance;

    # font, character min-x, max-x, min-y, max-y, advance
    sub TTF_GlyphMetrics(
        TTF_Font,
        uint16 $ch,
        int16 $min-x is rw,
        int16 $max-x is rw,
        int16 $min-y is rw,
        int16 $max-y is rw,
        int16 $advance is rw
        )
        returns int16
        is native($lib)
        {*}

    my $err = TTF_GlyphMetrics($font, $ch.substr(0,1).ord, $min-x, $max-x, $min-y, $max-y, $advance);

    fail(TTF_GetError()) if $err != 0;

    { :font(TTF_FontFaceFamilyName($font)), :style(TTF_FontFaceStyleName($font)),
      :char($ch), :$min-x, :$max-x, :$min-y, :$max-y, :$advance }
}


sub TTF_GetTextSize( TTF_Font $font, str $text ) is export {
    my int16 $width;
    my int16 $height;
    TTF_SizeUTF8($font, $text, $width, $height);
    (:$width, :$height);
}

sub TTF_SizeUTF8(
    TTF_Font,
    str,
    int16 $width is rw,
    int16 $height is rw,
    )
    returns int16
    is native($lib)
    {*}


sub TTF_Render_Solid( TTF_Font $font, str $text, uint32 $fg )
    returns SDL_Surface
    is export
    { TTF_RenderUTF8_Solid( $font, $text, $fg ) }

sub TTF_RenderUTF8_Solid(
    TTF_Font,
    str,
    uint32 # SDL_color
    )
    returns SDL_Surface
    is native($lib)
    {*}


sub TTF_Render_Shaded( TTF_Font $font, str $text, uint32 $fg, uint32 $bg )
    returns SDL_Surface
    is export
    { TTF_RenderUTF8_Shaded( $font, $text, $fg, $bg ) }


sub TTF_RenderUTF8_Shaded(
    TTF_Font,
    str,
    uint32, # SDL_color
    uint32  # SDL_color
    )
    returns SDL_Surface
    is native($lib)
    {*}



sub TTF_Render_Blended( TTF_Font $font, str $text, uint32 $fg )
    returns SDL_Surface
    is export
    { TTF_RenderUTF8_Blended( $font, $text, $fg ) }


sub TTF_RenderUTF8_Blended(
    TTF_Font,
    str,
    uint32, # SDL_color
    )
    returns SDL_Surface
    is native($lib)
    {*}


sub TTF_Render_Blended_Wrapped( TTF_Font $font, str $text, uint32 $fg, uint32 $wrap-length )
    returns SDL_Surface
    is export
    { TTF_RenderUTF8_Blended_Wrapped( $font, $text, $fg, $wrap-length ) }


sub TTF_RenderUTF8_Blended_Wrapped(
    TTF_Font,
    str,
    uint32, # SDL_color
    uint32
    )
    returns SDL_Surface
    is native($lib)
    {*}


################################################################################

=begin pod

=head1 NAME

SDL2-ttf - FreeType interface to render text in SDL2

=head1 SYNOPSIS

=begin code :lang<perl6>

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

=end code

The C<$raku> variable now contains a rendered texture that may be used in SDL2.

=head1 DESCRIPTION

Provides a convenient interface to FreeType to assist in loading and using TrueType fonts
as rendering textures in SDL2.

Needs to have the libsdl2-dev and libsdl2-ttf-dev development libraries installed.

On Debian derived distributions:

    sudo apt-get install libsdl2-dev libsdl2-ttf-dev

Similar for others.

Documentation for the SDL2_ttf library, which works very similar to, but not exactly
the same as these bindings: https://www.libsdl.org/projects/SDL_ttf/docs/index.html

Several routines are called slightly differently, and many are not exposed at due
to the different requirements and capabilities of the Raku runtime and the C library.

Try out the C<ttftest.p6> script in the examples folder to get a feel for how it can be used.

=head3 Enumerations

There are a few enumerations provided.

### <a name="TTF_STYLE"></a>

B<TTF_STYLE> - The various font styles that may be available and/or specified:

=begin table :caption< TTF_STYLE >
Name                | value
===========================
STYLE_NORMAL        |  0
STYLE_BOLD          |  1
STYLE_ITALIC        |  2
STYLE_UNDERLINE     |  4
STYLE_STRIKETHROUGH |  8
=end table

### <a name="TTF_HINTING"></a>

B<TTF_HINTING> - The various font hints that may be available and/or specified:
=begin table :caption< TTF_HINTING >
Name          | value
=====================
HINT_NORMAL   |  0
HINT_LIGHT    |  1
HINT_MONO     |  2
HINT_NONE     |  3
=end table


=head2 Subroutines:

=head4 General

* [TTF_Init](#TTF_Init)

* [TTF_WasInit](#TTF_WasInit)

* [TTF_Quit](#TTF_Quit)

* [TTF_GetError](#TTF_GetError)

* [TTF_OpenFont](#TTF_OpenFont)

* [TTF_OpenFontIndex](#TTF_OpenFontIndex)

* [TTF_CloseFont](#TTF_CloseFont)

=head4 Attributes

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

=head4 Rendering

* [TTF_Color](#TTF_Color)

* [TTF_Render_Solid](#TTF_Render_Solid)

* [TTF_Render_Shaded](#TTF_Render_Shaded)

* [TTF_Render_Blended](#TTF_Render_Blended)

* [TTF_Render_Blended_Wrapped](#TTF_Render_Blended_Wrapped)

=head3 Rendering modes

=item1 Solid - Quick and Dirty

=item2 <p>Create an 8-bit palettized surface and render the given text at fast quality
with the given font and color. The pixel value of 0 is the colorkey, giving a
transparent background when blitted. Pixel and colormap value 1 is set to the
text foreground color. This results in no box around the text, but the text is not
as smooth.</p>

=item1 Shaded - Slow and Nice, but with a Solid Box

=item2 <p>Create an 8-bit palettized surface and render the given text at high quality
with the given font and colors. The 0 pixel value is background, while other
pixels have varying degrees of the foreground color from the background color.
This results in a box of the background color around the text in the foreground
color. The text is antialiased. This will render slower than Solid, but in about
the same time as Blended mode.</p>

=item1 Blended - Slow Slow Slow, but Ultra Nice over another image

=item2 <p>Create a 32-bit ARGB surface and render the given text at high quality, using
alpha blending to dither the font with the given color. This results in a surface
with alpha transparency, so you don’t have a solid colored box around the text.
The text is antialiased. This will render slower than Solid, but in about the
same time as Shaded mode. Use this when you want high quality, and the text
isn’t changing too fast.</p>

  *  *  *  *  *

### <a name="TTF_Init"></a>
C<TTF_Init()>
=item Initialize the truetype font API.
=item Must be called before using other functions in this library, except TTF_WasInit or TTF_Color.
=item SDL does not have to be initialized before this call.
=item Takes: Nothing.
=item Returns: 0 on success, -1 on any error


### <a name="TTF_WasInit"></a>
C<TTF_WasInit>
=item Query the initilization status of the truetype font API.
=item Takes: Nothing.
=item Returns: 1 if already initialized, 0 if not initialized.


### <a name="TTF_Quit"></a>
C<TTF_Quit>
=item Shutdown and cleanup the truetype font API.
=item Takes: Nothing.
=item Returns: Nothing.


### <a name="TTF_GetError"></a>
C<TTF_GetError>
=item Returns the last error set as a string.
=item Takes: Nothing
=item Returns: String.


### <a name="TTF_OpenFont"></a>
C<TTF_OpenFont($file, $ptsize)>
=item Load file for use as a font, at ptsize size.
=item Takes:
=item2 $file - File name to load font from.
=item2 $ptsize - Point size (based on 72DPI) to load font as. Basically pixel height.
=item Returns: Pointer to the font as a TTF_Font. NULL is returned on error.


### <a name="TTF_OpenFontIndex"></a>
C<TTF_OpenFontIndex($file, $ptsize, $index)>
=item Load file for use as a font, at ptsize size, selecting $index face.
=item Takes:
=item2 $file - File name to load font from.
=item2 $ptsize - Point size (based on 72DPI) to load font as. Basically pixel height.
=item2 $index - Choose a font face from a file containing multiple font faces. The first face is always index 0.
=item Returns: Pointer to the font as a TTF_Font. NULL is returned on error.


### <a name="TTF_CloseFont"></a>
C<TTF_CloseFont($font)>
=item Free the memory used by font, and free font itself as well.
=item Takes: $font - Pointer to loaded font.
=item Returns: Nothing.


### <a name="TTF_GetFontStyle"></a>
C<TTF_GetFontStyle($font)>
=item Get the rendering style of the loaded font.
=item Takes: $font - Pointer to loaded font.
=item Returns: The bitwise or of the set styles codes. See [the TTF_STYLE ENUM](#TTF_STYLE)


### <a name="TTF_GetFontStyles"></a>
C<TTF_GetFontStyles($font)>
=item Get the rendering style of the loaded font, enumerated list.
=item Takes: $font - Pointer to loaded font.
=item Returns: An enumerated list of the set styles. See [the TTF_STYLE ENUM](#TTF_STYLE)


### <a name="TTF_SetFontStyle"></a>
C<TTF_SetFontStyle($font, $style)>
=item Set the rendering style of the loaded font.
=item Takes:
=item2 $font - Pointer to loaded font.
=item2 $style - The bitwise or of the desired styles codes. See [the TTF_STYLE ENUM](#TTF_STYLE)
=item Returns: Nothing


### <a name="TTF_GetFontOutline"></a>
C<TTF_GetFontOutline($font)>
=item Get the current outline size of the loaded font.
=item Takes: $font - Pointer to loaded font.
=item Returns: The size of the outline currently set on the font, in pixels.


### <a name="TTF_SetFontOutline"></a>
C<TTF_SetFontOutline($font, $outline)>
=item Set the current outline size of the loaded font.
=item Takes:
=item2 $font - Pointer to loaded font.
=item2 $outline - The size of outline desired, in pixels.
=item Returns: Nothing.


### <a name="TTF_GetFontHinting"></a>
C<TTF_GetFontHinting($font)>
=item Get the current hinting setting of the loaded font.
=item Takes: $font - Pointer to loaded font.
=item Returns: The hinting type matching one of the enumerated values. See [the TTF_HINTING ENUM](#TTF_HINTING)


### <a name="TTF_SetFontHinting"></a>
C<TTF_SetFontHinting($font, $hint)>
=item Set the current hinting setting of the loaded font.
=item Takes:
=item2 $font - Pointer to loaded font.
=item2 $hint - One of the enumerated Hint values. See [the TTF_HINTING ENUM](#TTF_HINTING)
=item Returns: Nothing.


### <a name="TTF_GetFontKerning"></a>
C<TTF_GetFontKerning($font)>
=item Get the current kerning setting of the loaded font.
=item Takes: $font - Pointer to loaded font.
=item Returns: Returns: 0(zero) if kerning is disabled; a non-zero value when enabled.


### <a name="TTF_SetFontKerning"></a>
C<TTF_SetFontKerning($font, $allowed)>
=item Set the current hinting setting of the loaded font.
=item Takes:
=item2 $font - Pointer to loaded font.
=item2 $allowed - 0 to disable kerning; non-zero to enable kerning. The default is 1, enabled.
=item Returns: Nothing.


### <a name="TTF_FontHeight"></a>
C<TTF_FontHeight($font)>
=item Get the maximum pixel height of all glyphs of the loaded font. Minimum size for adjacent rows of text to not overlap.
=item Takes: $font - Pointer to loaded font.
=item Returns: The maximum pixel height of all glyphs in the font.


### <a name="TTF_FontAscent"></a>
C<TTF_FontAscent($font)>
=item Get the maximum pixel ascent of all glyphs of the loaded font. - The maximum distance from the baseline to the top.
=item Takes: $font - Pointer to loaded font.
=item Returns: The maximum pixel ascent of all glyphs in the font.


### <a name="TTF_FontDescent"></a>
C<TTF_FontDescent($font)>
=item Get the maximum pixel descent of all glyphs of the loaded font. - The maximum distance from the baseline to the bottom.
=item Takes: $font - Pointer to loaded font.
=item Returns: The maximum pixel descent of all glyphs in the font.


### <a name="TTF_FontLineSkip"></a>
C<TTF_FontLineSkip($font)>
=item Get the recommended pixel height of a rendered line of text of the loaded font. - Usually larger than the TTF_FontHeight of the font.
=item Takes: $font - Pointer to loaded font.
=item Returns: The maximum pixel height of all glyphs in the font.


### <a name="TTF_FontFaces"></a>
C<TTF_FontFaces($font)>
=item Get the number of faces ("sub-fonts") available in the loaded font.
=item Takes: $font - Pointer to loaded font.
=item Returns: The number of faces in the font.


### <a name="TTF_FontFaceIsFixedWidth"></a>
C<TTF_FontFaceIsFixedWidth($font)>
=item Test if the current font face of the loaded font is a fixed width font.
=item Takes: $font - Pointer to loaded font.
=item Returns: >0 if $font is a fixed width font. 0 if not a fixed width font.


### <a name="TTF_FontFaceFamilyName"></a>
C<TTF_FontFaceFamilyName($font)>
=item Get the current font face family name from the loaded font.
=item Takes: $font - Pointer to loaded font.
=item Returns: The current family name of the face of the font, or NULL if not available.


### <a name="TTF_FontFaceStyleName"></a>
C<TTF_FontFaceStyleName($font)>
=item Get the current font face style name from the loaded font.
=item Takes: $font - Pointer to loaded font.
=item Returns: The current style name of the face of the font, or NULL if not available.


### <a name="TTF_GlyphIsProvided"></a>
C<TTF_GlyphIsProvided($font, $character or $ordinal)>
=item Get the status of the availability of the glyph for $character from the loaded font.
=item Takes:
=item2 $font - Pointer to loaded font.
=item2 Either: $character - String containing the $character to check for.
=item2 Or: $ordinal - Integer $ordinal of character.
=item Returns: The index of the glyph location in the font for $character, or 0 for an undefined character code.
(Note: returns the font file index, NOT the character ordinal.)


### <a name="TTF_GlyphMetrics"></a>
C<TTF_GlyphMetrics($font, $character)>
=item Get the metrics of the char given in $character from the loaded font.
=item Takes:
=item2 $font - Pointer to loaded font.
=item2 $character - String containing the character to get metrics for.
=item Returns: A hash containing the following information:
=item2 :font(TTF_FontFaceFamilyName($font)) - The Family Face name
=item2 :style(TTF_FontFaceStyleName($font)) - The style
=item2 :char($character) - The character checked
=item2 :$min-x - The minimum X offset into the character.
=item2 :$max-x - The maximum X offset into the character.
=item2 :$min-y - The minimum Y offset into the character.
=item2 :$max-y - The maximum Y offset into the character.
=item2 :$advance - The distance from the end of the previous glyph to the start of the next.


Glyph Metrics explained: (image copyright libsdl.org)

![Font Metrics][glyph-metric-image]

[glyph-metric-image]: https://www.libsdl.org/projects/SDL_ttf/docs/metrics.png "Glyph metrics"


### <a name="TTF_GetTextSize"></a>
C<TTF_GetTextSize($font, $text)>
=item Get the width and height in pixels of the given text in the currently loaded font.
=item Takes:
=item2 $font - Pointer to loaded font.
=item2 $text - Text string to get the dimensions.
=item Returns: A list of Pairs
=item2 :width(width)
=item2 :height(height)


### <a name="TTF_Color"></a>
C<TTF_Color($red, $green, $blue, $alpha = 255)>
=item Generate a packed ARGB TTF_color suitable to pass to the rendering routines.
=item Takes:
=item2 $red   - 0-255 integer value for red.
=item2 $green - 0-255 integer value for green.
=item2 $blue  - 0-255 integer value for blue.
=item2 $alpha - 0-255 integer value for alpha. Optional, default 255
=item Returns: The packed TTF_Color.


### <a name="TTF_Render_Solid"></a>
C<TTF_Render_Solid($font, $text, $fg)>
=item Render the passed $text using $font with $fg color onto a new surface, using Solid mode.
=item Takes:
=item2 $font - Pointer to loaded font.
=item2 $text - Text string to render.
=item2 $fg   - TTF_Color to use as the foreground color.
=item Returns: A pointer to a new SDL Surface.


### <a name="TTF_Render_Shaded"></a>
C<TTF_Render_Shaded($font, $text, $fg, $bg)>
=item Render the passed $text using $font with $fg color onto a new $bg colored surface, using Shaded mode.
=item Takes:
=item2 $font - Pointer to loaded font.
=item2 $text - Text string to render.
=item2 $fg   - TTF_Color to use as the foreground color.
=item2 $bg   - TTF_Color to use as the background color.
=item Returns: A pointer to a new SDL Surface.


### <a name="TTF_Render_Blended"></a>
C<TTF_Render_Blended($font, $text, $fg)>
=item Render the passed $text using $font with $fg color onto a new surface, using Blended mode.
=item Takes:
=item2 $font - Pointer to loaded font.
=item2 $text - Text string to render.
=item2 $fg   - TTF_Color to use as the foreground color.
=item Returns: A pointer to a new SDL Surface.


### <a name="TTF_Render_Blended_Wrapped"></a>
C<TTF_Render_Blended_Wrapped($font, $text, $fg, $length)>
=item A convenience routine to render wrapped text, in Blended mode.
=item Takes:
=item2 $font - Pointer to loaded font.
=item2 $text - Text string to render.
=item2 $fg   - TTF_Color to use as the foreground color.
=item2 $length - Length in pixels to use as a wrap threshold.
=item Returns: A pointer to a new SDL Surface.


=head1 AUTHOR

SDL2_ttf library: Sam Lantinga

Raku bindings: Steve Schulze (thundergnat)

=head1 COPYRIGHT AND LICENSE

Copyright 2020 Steve Schulze (thundergnat)

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
