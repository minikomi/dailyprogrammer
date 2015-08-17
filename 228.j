inorder =: [ -: /:~
inrevorder =: inorder&|.
ch228 =: ('IN ORDER';'IN REVERSE ORDER';'NOT IN ORDER') {~ (1 i.~ (inorder,inrevorder))

words =: ;: 'billowy biopsy chinos defaced chintz sponged bijoux abhors fiddle begins chimps wronged'
([;ch228)&> words

NB. ┌───────┬────────────────┐
NB. │billowy│IN ORDER        │
NB. ├───────┼────────────────┤
NB. │biopsy │IN ORDER        │
NB. ├───────┼────────────────┤
NB. │chinos │IN ORDER        │
NB. ├───────┼────────────────┤
NB. │defaced│NOT IN ORDER    │
NB. ├───────┼────────────────┤
NB. │chintz │IN ORDER        │
NB. ├───────┼────────────────┤
NB. │sponged│IN REVERSE ORDER│
NB. ├───────┼────────────────┤
NB. │bijoux │IN ORDER        │
NB. ├───────┼────────────────┤
NB. │abhors │IN ORDER        │
NB. ├───────┼────────────────┤
NB. │fiddle │NOT IN ORDER    │
NB. ├───────┼────────────────┤
NB. │begins │IN ORDER        │
NB. ├───────┼────────────────┤
NB. │chimps │IN ORDER        │
NB. ├───────┼────────────────┤
NB. │wronged│IN REVERSE ORDER│
NB. └───────┴────────────────┘
