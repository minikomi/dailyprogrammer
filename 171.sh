# http://www.reddit.com/r/dailyprogrammer/comments/2ao99p/7142014_challenge_171_easy_hex_to_8x8_bitmap/
# A 8x8 picture that represents the values you read in.
# For example say you got the hex value FF. This is 1111 1111 . "1" means the bitmap at that location is on and print something. "0" means nothing is printed so put a space. 1111 1111 would output this row:
# xxxxxxxx
# if the next hex value is 81 it would be 1000 0001 in binary and so the 2nd row would output (with the first row)
# xxxxxxxx
# x      x
#

echo "FF 81 BD A5 A5 BD 81 FF" | xxd -r -p | xxd -b -c 1 | awk '{print $2}' | sed 's/0/\ /g; s/1/X/g'

##  result:
##  XXXXXXXX
##  X      X
##  X XXXX X
##  X X  X X
##  X X  X X
##  X XXXX X
##  X      X
##  XXXXXXXX
