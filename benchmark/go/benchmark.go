package main

import "C"
import "strconv"

var counter = 0

//export process
func process(method string, headers string, body string) string {
  counter = counter + 1
	return "lua2go" + strconv.Itoa(counter)
}

func main() {}
