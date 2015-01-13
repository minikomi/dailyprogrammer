(defn look-say [n-str]
  (->> (partition-by identity n-str)
       (mapcat #(list (count %) (first %)))
       (apply str)))
