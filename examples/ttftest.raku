#!/usr/bin/env raku

use SDL2::Raw;
use SDL2-ttf;

my $width  = 1000;
my $height = 800;

SDL_Init(VIDEO);

my $window = SDL_CreateWindow(
    'SDL2-ttf',
    SDL_WINDOWPOS_CENTERED_MASK,
    SDL_WINDOWPOS_CENTERED_MASK,
    $width, $height, RESIZABLE
);

my $render = SDL_CreateRenderer($window, -1, ACCELERATED +| PRESENTVSYNC);

my $blue   = TTF_Color(0x00, 0x00, 0xFF);
my $green  = TTF_Color(0x00, 0xC8, 0x00);
my $pink   = TTF_Color(0xFF, 0x1C, 0xAE);
my $yellow = TTF_Color(0xFF, 0xFF, 0x00);

TTF_Init();

# Select a ttf font: Run "fc-list" at a command prompt.
my $f = run("fc-list", :out).out.lines.grep( /'.ttf'/ )\
        .map( {split(':', $_)[0]} ).grep( /'Mono'/ ).pick;

say "Font file: ", $f;

die "Unable to open a font file" unless $f.defined and $f.IO.e;

my $font = TTF_OpenFont($f, 600);

#TTF_SetFontOutline($font, 6);

say 'Font Family: ', TTF_FontFaceFamilyName $font;
say 'Font Style (by value): ', TTF_GetFontStyle $font;
say 'Font Style (by enumeration): ',TTF_GetFontStyles($font);
say 'Font Style Name: ',TTF_FontFaceStyleName($font);

say 'Glyph Metrics: ', TTF_GlyphMetrics($font, 'M');

say 'Font Height): ',TTF_FontHeight $font;
# Not really useful because we're scaling the font down later


say 'Text Size for "Raku": ', TTF_GetTextSize($font, 'Raku');

my $raku = SDL_CreateTextureFromSurface(
    $render, TTF_Render_Blended($font, ' Raku ', $pink)
);

my @butterflies = ( SDL_CreateTextureFromSurface(
    $render, TTF_Render_Blended( $font, '»ö«', TTF_Color((64..255).roll,(64..255).roll,(64..255).roll) ) ) xx 60;
);

my $space = SDL_CreateTextureFromSurface(
    $render, TTF_Render_Solid( $font, 'Press the space bar', TTF_Color(255,255,255) )
);

TTF_CloseFont($font);
TTF_Quit();

enum KEY_CODES (
    K_SPACE  => 44,
    K_Q      => 20,
);

my $event = SDL_Event.new;

my $angle = 0;
my $step  = 1;
my $dir   = 0;

my @swarm = [(^$width).roll, (^$height).roll, (-2..2).roll, (-2..2).roll,
             @butterflies.pick] xx +@butterflies;

my $ch; # Camelia height

main: loop {
    handle-event($event) while SDL_PollEvent($event);

    given $dir cmp 0 {
        when More { $angle >= 360 ?? ($angle %= $step) !! $angle += $step }
        when Less { $angle < 0 ?? ($angle %= ($step + 360)) !! $angle -= $step }
        when Same { $angle = 0 }
    };

    SDL_RenderCopy( $render, $space, Nil, SDL_Rect.new( ($width / 3).Int, 750, ($width / 3).Int, 50) );

    # Behind Raku
    SDL_RenderCopy( $render, $_[4], Nil, SDL_Rect.new( $_[0].Int, $_[1].Int, 50, 40) ) for @swarm[^(@swarm/2)];

    # Raku
    SDL_RenderCopyEx( $render, $raku, Nil, Nil, $angle.Num,
        SDL_Point.new( :x($width div 2), :y($height div 2) ), 0
    );

    # In front of Raku
    SDL_RenderCopy( $render, $_[4], Nil, SDL_Rect.new( $_[0].Int, $_[1].Int, 50, 40) ) for @swarm[(@swarm/2)..*];

    for ^@swarm {
        (@swarm[$_][0] += @swarm[$_][2]) %= $width;
        (@swarm[$_][1] += @swarm[$_][3]) %= $height;
        @swarm[$_][2] += (2.rand - 1);
        @swarm[$_][3] += (2.rand - 1);
        @swarm[$_][2] max= -5;
        @swarm[$_][2] min= 5;
        @swarm[$_][3] max= -5;
        @swarm[$_][3] min= 5;
    }

    $ch = ($height / 3).round;

    # Camelia
    SDL_RenderCopy( $render, @butterflies[0], Nil, SDL_Rect.new( 0, 0, $ch, $ch) );
    SDL_RenderCopy( $render, @butterflies[1], Nil, SDL_Rect.new( $width - $ch, 0, $ch, $ch) );
    SDL_RenderCopy( $render, @butterflies[2], Nil, SDL_Rect.new( 0, $height - $ch, $ch, $ch) );
    SDL_RenderCopy( $render, @butterflies[3], Nil, SDL_Rect.new( $width - $ch, $height - $ch, $ch, $ch) );

    SDL_RenderPresent($render);

    SDL_RenderClear($render);
    print fps;
}

say '';
SDL_Quit();

sub handle-event ($event) {
    my $casted_event = SDL_CastEvent($event);
    given $casted_event {
        when .type == KEYDOWN {
            if KEY_CODES(.scancode) -> $comm {
                given $comm {
                    when 'K_SPACE'  { $dir -= 1; $dir += 3 if $dir < -1; }
                    when 'K_Q'   { last main }
                }
            }
        }
        when .type == QUIT    { last main }
        when .type == WINDOWEVENT {
            when .event == SIZE_CHANGED {
                $width  = .data1;
                $height = .data2;
            }
        }
    }
}

sub fps {
    state $fps-frames = 0;
    state $fps-now    = now;
    state $fps        = '';
    $fps-frames++;
    if now - $fps-now >= 1 {
        $fps = [~] "\r", ' ' x 20, "\r",
            sprintf "FPS: %5.1f  ", ($fps-frames / (now - $fps-now));
        $fps-frames = 0;
        $fps-now = now;
    }
    $fps
}
