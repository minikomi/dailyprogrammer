NB. Challenge 213 [Easy] - Rule 90

slidingwindow =: 4 : 0
  ([{~(;@<@(+&(i.x)"0)@:i.@:-&(x-1)@:#)) y
)

NB. This creates a dyad which takes a windowsize, and an array, and slides along the array eg:

   3 slidingwindow 'abcdefg'
abc
bcd
cde
def
efg

NB. Then, we need to pad with zeros:

padwithzeros =: 0,~0, ]

NB. And xor the neighbouring bits (eg, in a group of 3, the 0th and 2nd position values):

xor02 =:  (0{])~:(2{])

NB. We now have all the parts to create a solution:

   challenge213 =: xor02"1  (3 & slidingwindow @: padwithzeros)
   challenge213 1 1 0 1 0 1 0
1 1 0 0 0 0 1
   challenge213 1 1 0 0 0 0 1
1 1 1 0 0 1 0
   challenge213 1 1 1 0 0 1 0
1 0 1 1 1 0 1

NB. Using suggestions from godspiral to clean up Sliding Window..

challenge213 =: (3 ({.~:{:)\ (0,~0,]))

' x' {~  challenge213^:(<50) 0"."0 '00000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000'
                                                 x                                                
                                                x x                                               
                                               x   x                                              
                                              x x x x                                             
                                             x       x                                            
                                            x x     x x                                           
                                           x   x   x   x                                          
                                          x x x x x x x x                                         
                                         x               x                                        
                                        x x             x x                                       
                                       x   x           x   x                                      
                                      x x x x         x x x x                                     
                                     x       x       x       x                                    
                                    x x     x x     x x     x x                                   
                                   x   x   x   x   x   x   x   x                                  
                                  x x x x x x x x x x x x x x x x                                 
                                 x                               x                                
                                x x                             x x                               
                               x   x                           x   x                              
                              x x x x                         x x x x                             
                             x       x                       x       x                            
                            x x     x x                     x x     x x                           
                           x   x   x   x                   x   x   x   x                          
                          x x x x x x x x                 x x x x x x x x                         
                         x               x               x               x                        
                        x x             x x             x x             x x                       
                       x   x           x   x           x   x           x   x                      
                      x x x x         x x x x         x x x x         x x x x                     
                     x       x       x       x       x       x       x       x                    
                    x x     x x     x x     x x     x x     x x     x x     x x                   
                   x   x   x   x   x   x   x   x   x   x   x   x   x   x   x   x                  
                  x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x x                 
                 x                                                               x                
                x x                                                             x x               
               x   x                                                           x   x              
              x x x x                                                         x x x x             
             x       x                                                       x       x            
            x x     x x                                                     x x     x x           
           x   x   x   x                                                   x   x   x   x          
          x x x x x x x x                                                 x x x x x x x x         
         x               x                                               x               x        
        x x             x x                                             x x             x x       
       x   x           x   x                                           x   x           x   x      
      x x x x         x x x x                                         x x x x         x x x x     
     x       x       x       x                                       x       x       x       x    
    x x     x x     x x     x x                                     x x     x x     x x     x x   
   x   x   x   x   x   x   x   x                                   x   x   x   x   x   x   x   x  
  x x x x x x x x x x x x x x x x                                 x x x x x x x x x x x x x x x x 
 x                               x                               x                               x
