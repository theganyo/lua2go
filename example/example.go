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
func concat(elements []string, separator string) *C.char {
	// This CString must be released by caller!
	return C.CString(strings.Join(elements, separator))
}

//export increment
func increment(value *int) {
	*value = *value + 1
}

//export reverse
func reverse(value []int) {
	for i, j := 0, len(value) - 1; i < j; i, j = i + 1, j - 1 {
		value[i], value[j] = value[j], value[i]
	}
}

func main() {}
