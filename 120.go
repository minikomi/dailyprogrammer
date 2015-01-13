// Challenge #120 [Easy] Log throughput counter
// http://www.reddit.com/r/dailyprogrammer/comments/17uw4s/020413_challenge_120_easy_log_throughput_counter/

package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
	"time"
)

func countsec(ch chan int, delay int, output string) {
	count := 0
	for {
		select {
		case <-ch:
			count = count + 1
		case <-time.After(time.Duration(delay) * time.Second):
			outputFile, err := os.Create(output)
			if err != nil {
				log.Fatal(err)
			}
			defer outputFile.Close()
			fmt.Fprintf(outputFile, "%d", count)
			count = 0
		}
	}
}

var delay int
var output string

func init() {
	const (
		delayDefault  = 3
		delayUsage    = "Seconds Delay for writing to output file."
		outputDefault = "out.txt"
		outputUsage   = "Output file"
	)
	flag.IntVar(&delay, "d", delayDefault, delayUsage)
	flag.StringVar(&output, "o", outputDefault, outputUsage)
}

func main() {
	flag.Parse()
	ch := make(chan int)
	go countsec(ch, delay, output)

	r := bufio.NewReader(os.Stdin)
	for {
		_, err := r.ReadString('\n')
		if err != nil {
			log.Fatal(err)
		}
		ch <- 1
	}
}
