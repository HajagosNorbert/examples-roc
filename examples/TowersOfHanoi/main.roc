Rod : [A, B, C]

Moves : List((Rod, Rod))

State : {
	num_disks : U64, # number of disks in the Tower of Hanoi problem
	from : Rod, # identifier of the source rod
	to : Rod, # identifier of the target rod
	using : Rod, # identifier of the auxiliary rod
}

PrintState : {
	rod_a : List(Num),
	rod_b : List(Num),
	rod_c : List(Num),
}

to_print_state = |{ num_disks, from, to }| {
	var $disks = List.with_capacity(num_disks)
	var $i = num_disks
	while $i > 0 {
		$disks = $disks.append($i)
		$i = $i - 1
	}

	zero_state = { rod_a: [], rod_b: [], rod_c: [] }
	match from {
		A => { ..zero_state, rod_a: $disks }
		B => { ..zero_state, rod_b: $disks }
		C => { ..zero_state, rod_c: $disks }
	}
}

main! : List(Str) => Try({}, _)
main! = |_args| {
	state = { ..start, num_disks: 3 }
	var $print_state = to_print_state(state)

	moves = hanoi(state)

	echo!("Initial state:")
	echo!(illustrate($print_state))
	for m in moves {
		$print_state = apply_move($print_state, m)?
		echo!(illustrate($print_state))
	}
	echo!("Finished!")
	Ok({})
}

apply_move = |var $rods, (from, to)| {

	item = match from {
		_ => {
			itm = $rods.rod_a.last()?
			$rods = { ..$rods, rod_a: $rods.rod_a.drop_last(1) }
			itm
		}
	}

	Ok($rods)
}

illustrate = |rods| {
	Str.inspect(rods)
}

hanoi : State -> Moves
hanoi = |state| {
	## Solves the Tower of Hanoi problem using recursion. Returns a list of moves
	## which represent the solution.
	help : State, Moves -> Moves
	help = |{ num_disks, from, to, using }, var $moves| {
		if num_disks == 1 {
			return $moves.append((from, to))
		}
		$moves = help(
			{
				num_disks: num_disks - 1,
				from,
				to: using,
				using: to,
			},
			$moves,
		)
		$moves = $moves.append((from, to))
		help(
			{
				num_disks: num_disks - 1,
				from: using,
				to,
				using: from,
			},
			$moves,
		)
	}

	help(state, [])
}

start = { num_disks: 0, from: A, to: B, using: C }

## Test Case 1: Tower of Hanoi with 1 disk
expect {
	actual = hanoi({ ..start, num_disks: 1 })
	actual == [(A, B)]
}

## Test Case 2: Tower of Hanoi with 2 disks
expect {
	actual = hanoi({ ..start, num_disks: 2 })
	actual == [
		(A, C),
		(A, B),
		(C, B),
	]
}

## Test Case 3: Tower of Hanoi with 3 disks
expect {
	actual = hanoi({ ..start, num_disks: 3 })
	actual == [
		(A, B),
		(A, C),
		(B, C),
		(A, B),
		(C, A),
		(C, B),
		(A, B),
	]
}
