(ns cljsolutions.dp246-letterspacing)

(defn decode [ch]
  (->> ch
       (read-string)
       (+ 64)
       (char)))

(defn build-chains [s]
  (if (empty? s) '()
      (let [ch1 (apply str (take 1 s))
            ch2 (apply str (take 2 s))]
        (concat
         (if (>= 0 (read-string ch1)) []
             (map #(cons (decode ch1) %) (build-chain (drop 1 s))))
         (if (or
              (> 10 (read-string ch2))
              (< 26 (read-string ch2))) []
             (map #(cons (decode ch2) %) (build-chain (drop 2 s))))))
      ))

(defn solve [s]
  (->>
   (build-chain s)
   (map #(apply str %))
   ))

(defn add-to-trie [trie word]
  (assoc-in trie
            (clojure.string/trim word)
            {:terminal true}))

(defn is-word? [trie w]
  (:terminal (get-in trie w)))

(def word-trie
  (->>
   (clojure.string/split (slurp "/usr/share/dict/words") #"\n")
   (filter #(<= 3 (count %)))
   (map clojure.string/upper-case)
   (reduce add-to-trie {})))

(defn is-good-answer? [ans]
  (loop [w ans t word-trie]
    (cond
      (empty? w) (:terminal t)
      (get t (first w)) (recur (rest w) (get t (first w)))
      (:terminal t) (is-good-answer? w)
      :else false)))

(defn solve-bonus [s]
  (->>
   (build-chain s)
   (map #(apply str %))
   (filter is-good-answer?)
   ))
