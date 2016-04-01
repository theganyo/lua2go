package main

import (
  "C"
  "strings"
)

//export add
func add(operand1 int, operand2 int) int {
	 return operand1 + operand2
}

//export concat
func concat(elements []string, separator string) string {
	 return strings.Join(elements, separator)
}

func main() {}
