unit module SDL2-ttf:ver<0.1>;

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

###############################################################################
## Color handling doesn't work correctly at this point.
## Apparently need to pass the CStruct by value, and that doesn't seem possible
## in NativeCall right now. There have been a few abortive attempts but they
## haven't made it into a release (and were implemented for libffi but not
## dynCall; the _default_ foreign function interface in Moar).

class SDL_Color is export is repr('CStruct') {
    has uint8 $.r; # red
    has uint8 $.g; # green
    has uint8 $.b; # blue
    has uint8 $.a; # alpha
}

sub Color (uint8 $r, uint8 $g, uint8 $b, uint8 $a = 255) is export {
    SDL_Color.new( :r($r), :g($g), :b($b), :a($a) );
}

###############################################################################


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


# swapped (0 /!0 - not swapped / swapped )
sub TTF_ByteSwappedUNICODE(int16)
    is native($lib)
    is export
    {*}


sub TTF_Init()
    returns int32
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


# font
sub TTF_GetFontStyle(TTF_Font)
    returns int16
    is native($lib)
    is export
    {*}


# sugar routine
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
sub TTF_GlyphIsProvided(TTF_Font, uint16)
    returns int16
    is native($lib)
    is export
    {*}


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


sub TTF_SizeText(
    TTF_Font,
    str,
    int16 $width is rw,
    int16 $height is rw,
    )
    returns int16
    is native($lib)
    is export
    {*}


sub TTF_SizeUTF8(
    TTF_Font,
    str,
    int16 $width is rw,
    int16 $height is rw,
    )
    returns int16
    is native($lib)
    is export
    {*}


sub TTF_SizeUNICODE(
    TTF_Font,
    uint16 $ord,
    int16 $width is rw,
    int16 $height is rw,
    )
    returns int16
    is native($lib)
    is export
    {*}


sub TTF_RenderText_Solid(
    TTF_Font,
    str,
    SDL_Color is copy
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderUTF8_Solid(
    TTF_Font,
    str,
    SDL_Color is copy
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderUNICODE_Solid(
    TTF_Font,
    uint16 $ord,
    SDL_Color is copy
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderGlyph_Solid(
    TTF_Font,
    uint16 $ord,
    SDL_Color is copy
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderText_Shaded(
    TTF_Font,
    str,
    SDL_Color is copy,
    SDL_Color is copy
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderUTF8_Shaded(
    TTF_Font,
    str,
    SDL_Color is copy,
    SDL_Color is copy
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderUNICODE_Shaded(
    TTF_Font,
    uint16 $ord,
    SDL_Color is copy,
    SDL_Color is copy
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderGlyph_Shaded(
    TTF_Font,
    uint16 $ord,
    SDL_Color is copy,
    SDL_Color is copy
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderText_Blended(
    TTF_Font,
    str,
    SDL_Color is copy,
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderUTF8_Blended(
    TTF_Font,
    str,
    SDL_Color is copy,
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderUNICODE_Blended(
    TTF_Font,
    uint16 $ord,
    SDL_Color is copy,
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderGlyph_Blended(
    TTF_Font,
    uint16 $ord,
    SDL_Color is copy,
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderText_Blended_Wrapped(
    TTF_Font,
    str,
    SDL_Color is copy,
    uint32 $wrap-length
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderUTF8_Blended_Wrapped(
    TTF_Font,
    str,
    SDL_Color is copy,
    uint32 $wrap-length
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_RenderUNICODE_Blended_Wrapped(
    TTF_Font,
    uint16 $ord,
    SDL_Color is copy,
    uint32 $wrap-length
    )
    returns SDL_Surface
    is native($lib)
    is export
    {*}


sub TTF_CloseFont(TTF_Font)
    is native($lib)
    is export
    {*}


sub TTF_Quit()
    is native($lib)
    is export
    {*}


sub TTF_WasInit()
    returns int16
    is native($lib)
    is export
    {*}


sub TTF_GetFontKerningSizeGlyphs(
    TTF_Font,
    uint16 $previous-char is rw,
    uint16 $char is rw,
    )
    returns int16
    is native($lib)
    is export
    {*}
