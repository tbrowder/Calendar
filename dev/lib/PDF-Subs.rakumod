unit module PDF-Subs;

# Routines to create text and graphics blocks on
# a PDF::Content::Page.

sub write-text-box(
    $text = "",
    PDF::Content::Page :$page!,
    :$x0, :$y0, :$width, :$height,
) is export {
}

sub draw-border(
    PDF::Content::Page :$page!,
    :$location { where /[inner|outer]/ } = "inner",
    :$x0, :$y0, :$width, :$height,
    :$border-width = 1,
) is export {
}

