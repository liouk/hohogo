package main

import (
	"fmt"
	"math/rand"
	"os"
	"time"
)

func init() {
	rand.Seed(time.Now().Unix())
}

func main() {
	for {
		if doRaffle(os.Args[1:]) {
			break
		}
		fmt.Println("Need to run the raffle again...")
	}

	fmt.Println("Secret Santa raffle completed!")
}

func doRaffle(friends []string) bool {
	raffle := make([]string, len(friends))
	cntSelected := map[string]int{}
	copy(raffle, friends)

	for _, p := range friends {
		idx := rand.Intn(len(raffle))
		selected := raffle[idx]
		for p == selected {
			if len(raffle) == 1 {
				return false
			}

			idx = rand.Intn(len(raffle))
			selected = raffle[idx]
		}

		write(p, selected)
		raffle = append(raffle[:idx], raffle[idx+1:]...)

		if _, ok := cntSelected[selected]; !ok {
			cntSelected[selected] = 0
		}
		cntSelected[selected] += 1
	}

	for k, v := range cntSelected {
		if v != 1 {
			panic(fmt.Errorf("%s was selected %d number of times!", k, v))
		}
	}

	return true
}

func write(person, santa string) {
	if person == santa {
		panic(fmt.Errorf("%s cannot be the Secret Santa for themselves!"))
	}

	f, err := os.Create(fmt.Sprintf("Secret_Santa_for_%s.txt", person))
	if err != nil {
		panic(err)
	}
	defer f.Close()

	f.WriteString("Your Secret Santa is\n\n")
	f.WriteString(fmt.Sprintf("  *<|:-)\t %s\n\n", santa))
	f.WriteString("HO HO HO! MERRY CHRISTMAS!!!\n")
}
