#!/usr/bin/env raku

use lib '.';
use SDL2::Raw;
use SDL2-ttf;


my $width  = 1000;
my $height = 800;

SDL_Init(VIDEO);

my $window = SDL_CreateWindow(
    'SDL_ttf Test',
    SDL_WINDOWPOS_CENTERED_MASK,
    SDL_WINDOWPOS_CENTERED_MASK,
    $width, $height, RESIZABLE
);

my $render = SDL_CreateRenderer($window, -1, ACCELERATED +| PRESENTVSYNC);



###############################################################################
############### Colors are not being handled correctly ########################
###############################################################################

 # Not being read / used correctly?

my $red = Color(255, 0, 0); # Red
my $grn = SDL_Color.new( :r(0x0), :g(0xFF), :b(0x0), :a(0xff) ); # Green

say $red;
say $grn;

###############################################################################
###############################################################################

TTF_Init();

# Select a ttf font: Run "fc-list" at a command prompt.
say my $f = run("fc-list", :out).out.lines.grep( /'.ttf'/ )\
            .map( {split(':', $_)[0]} ).grep( /'Mono'/ ).pick;

my $font = TTF_OpenFont($f, 1000);

#TTF_SetFontOutline($font, 6);

say TTF_FontFaceFamilyName $font;
say TTF_GetFontStyle $font;
say TTF_GetFontStyles($font);
say TTF_FontFaceStyleName($font);

say TTF_GlyphMetrics($font, 'M');

say TTF_FontHeight $font;
# Not really useful because we're scaling the font down later

my int ($twidth, $theight);

TTF_SizeText($font, 'Raku', $twidth, $theight);
say ($twidth, $theight);


my $raku = SDL_CreateTextureFromSurface(
    $render, TTF_RenderUTF8_Blended($font, ' Raku ', $red)
);

my $camelia = SDL_CreateTextureFromSurface(
    $render, TTF_RenderUTF8_Blended( $font, '»ö«', $grn )
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

my @swarm = [(^$width).roll, (^$height).roll, (-2..2).roll, (-2..2).roll] xx 30;

my $ch; # Camelia height

main: loop {
    handle-event($event) while SDL_PollEvent($event);

    given $dir cmp 0 {
        when More { $angle >= 360 ?? ($angle %= $step) !! $angle += $step }
        when Less { $angle < 0 ?? ($angle %= ($step + 360)) !! $angle -= $step }
        when Same { $angle = 0 }
    };

    # In front of Raku
    SDL_RenderCopy( $render, $camelia, Nil, SDL_Rect.new( $_[0].Int, $_[1].Int, 50, 40) ) for @swarm[^15];

    # Raku
    SDL_RenderCopyEx( $render, $raku, Nil, Nil, $angle.Num,
        SDL_Point.new( :x($width div 2), :y($height div 2) ),
        0
    );

    $ch = ($height / 3).round;

    # behind Raku
    SDL_RenderCopy( $render, $camelia, Nil, SDL_Rect.new( $_[0].Int, $_[1].Int, 50, 40) ) for @swarm[16..*];

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


    # Camelia
    SDL_RenderCopy( $render, $camelia, Nil, SDL_Rect.new( 0, 0, $ch, $ch) );
    SDL_RenderCopy( $render, $camelia, Nil, SDL_Rect.new( $width - $ch, 0, $ch, $ch) );
    SDL_RenderCopy( $render, $camelia, Nil, SDL_Rect.new( 0, $height - $ch, $ch, $ch) );
    SDL_RenderCopy( $render, $camelia, Nil, SDL_Rect.new( $width - $ch, $height - $ch, $ch, $ch) );

    SDL_RenderPresent($render);

    SDL_RenderClear($render);
}

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
