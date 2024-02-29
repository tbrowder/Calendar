unit module PDF-Subs;

use PDF::Content::FontObj;
use PDF::Content::Page :PageSizes;
use PDF::Content::Color :ColorName, :color;

# Routines to create text and graphics blocks on
# a PDF::Content::Page.

# use: start-page :$page, :orient<landscape>, :media<Letter>; 
sub start-page(
    PDF::Content::Page :$page!,
    Bool :$landscape = False,
    :$media where { /:i [Letter|A4]/ } = "letter",
) is export {

    # For this document, always use internal landscape, "right-side up"
    # i.e, NOT upside-down

    # Set the media here
    with $media {
        when /:i letter/ {
            $page.media-box = Letter;
        }
        when /:i a4/ {
            $page.media-box = A4;
        }
    }

    $page.graphics: {
        # always save the CTM
        .Save;
        #===================================
        my ($w, $h);

        # Set the landscape if needed
        if $landscape {
            #    if not $upside-down {
            # Normal landscape
            # translate from: lower-left corner to: lower-right corner
            # LLX, LLY -> URX, LLY
            .transform: :translate($page.media-box[2], $page.media-box[1]);
            # rotate: left (ccw) 90 degrees
            .transform: :rotate(90 * pi/180); # left (ccw) 90 degrees
            #    for upside-down:
            #        MAKE ONE MORE TRANSLATION IN Y=0 AT TOP OF PAPER
            #        THEN Y DIMENS ARE NEGATIVE AFTER THAT
            #        LLX, LLY -> LLX, URY
            #    }
            .transform: :translate(0, $page.media-box[2]);
        }

        $w = $page.media-box[3] - $page.media-box[1];
        $h = $page.media-box[2] - $page.media-box[0];
    }
}

sub finish-page(
    PDF::Content::Page :$page!,
) is export {
    $page.graphics: {
        .Restore;
    }
}

sub put-text(
    $text = "",
    PDF::Content::Page :$page!,
    :$x0, :$y0, :$width, :$height,
) is export {
}

sub draw-box(
    PDF::Content::Page :$page!,
    Bool :$inside = True,
    :$x0, :$y0, :$width, :$height,
    :$border-width = 1,
) is export {
}

