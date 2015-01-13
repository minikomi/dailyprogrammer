(->> "proogrrrammminggg" 
            (partition-by identity) 
            (filter #(< 1 (count %))) 
            (map first))