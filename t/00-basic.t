use Test;

use lib 'lib';
use SDL2-ttf;

plan 21;

TTF_Init();

is(TTF_Color(0x00, 0x00, 0xFF).fmt('%032b'), '11111111111111110000000000000000', 'Blue as expected');
is(TTF_Color(0x00, 0xC8, 0x00).fmt('%032b'), '11111111000000001100100000000000', 'Green as expected');
is(TTF_Color(0xFF, 0x1C, 0xAE).fmt('%032b'), '11111111101011100001110011111111', 'Pink as expected');
is(TTF_Color(0xFF, 0xFF, 0x00).fmt('%032b'), '11111111000000001111111111111111', 'Yellow as expected');

my $file = './t/font/Ubuntu-Medium.ttf';

fail "font file not found" unless $file.IO.e;

my $font = TTF_OpenFont($file, 65);

isa-ok(TTF_Font, $font);

is( TTF_FontFaces($font), 1, 'Correct number of Faces');

is( TTF_FontFaceFamilyName($font), 'Ubuntu', 'Correct Family name');

is( TTF_GetFontStyle($font), 0, 'Font style index returns sane value');

is-deeply( TTF_GetFontStyles($font), $("STYLE_NORMAL",), 'Font style enumeration returns sane value');

is( TTF_FontFaceStyleName($font), 'Medium', 'Style name is as expected');;

is-approx(TTF_FontHeight($font), 73, 1, 'Height is in sane range');

is-approx(TTF_FontAscent($font), 60, 1, 'Ascent is in sane range');

is-approx(TTF_FontDescent($font), -12, 1, 'Descent is in sane range');

is-approx(TTF_FontLineSkip($font), 74, 1, 'Line Skip Height is in sane range');

is(so TTF_GetFontKerning($font), True, 'Kerning is as expected');

is(TTF_GetFontHinting($font), 0, 'Hinting is as expected');

is(TTF_GetFontOutline($font), 0, 'Outline parameter is as expected');

TTF_SetFontOutline($font, 5);

is(TTF_GetFontOutline($font), 5, 'Changed outline parameter ok');

is(TTF_GlyphIsProvided($font, 'ö'), 209, 'Glyph index seems ok');

is(TTF_GlyphIsProvided($font, 453), 554, 'Glyph index seems ok');

is(TTF_GlyphIsProvided($font, '𐘀'), 0, 'Glyph index seems ok');

TTF_Quit;

done-testing;
