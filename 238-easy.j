NB. A random lowercase string of letters in which consonants (bcdfghjklmnpqrstvwxyz) occupy the given 'c' indices and vowels (aeiou) occupy the given 'v' indices.

    vowels =: 'aeiou'
    consts =: 'bcdfghjklmnpqrstvwxyz'
    sets =: vowels ; consts ; (toupper vowels) ; (toupper consts)
    ch238 =: [: , ;@:(] {~ ?@#)&>@(sets {~ 'vcVC'&i.)
    ch238  'vvVcVc'

NB. ieUqUy
