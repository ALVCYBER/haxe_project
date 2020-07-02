
class Main {
	static function main() {
		var cars:Map<String, Car> = new Map();
		cars["red"] = new Car("red", Horizontal, 2);
		cars["blue"] = new Car("blue", Vertical, 3);
		cars["green"] = new Car("green", Horizontal, 2);
		cars["yellow"] = new Car("yellow", Vertical, 4);

		final board = new Board(new Coord(5,2));
		board.boardState = [
			[null, null, null, null, null, null],
			[null, null, null, null, null, "blue"],
			["red", "red", null, null, null, "blue"],
			[null, null, null, "yellow", null, "blue"],
			[null, null, null, "yellow", "green", "green"],
			[null, null, null, "yellow", null, null],
			[null, null, null, "yellow", null, null],
		];

		trace('Starting from:');
		trace(board.state());

		final solution = Solver.solve(board, cars, "red");
		if(solution == null) {
			trace("No solution found");
		} else {
			// squash similar moves together
			final squashedMoves = new List<Move>();
			var currentMove: Move = null;
			for(move in solution.moveList) {
				if (currentMove == null) {
					currentMove = move;
					continue;
				}
				if (currentMove.carName == move.carName && currentMove.move == move.move) {
					currentMove.count++;
					continue;
				}
				trace(currentMove.description());
				currentMove = move;
			}
			if (currentMove != null) {
				trace(currentMove.description());
			}
		}

	}
}

class Solver {

	private static final printBoards = false;


	public static function solve(initialState:Board, cars:Map<String, Car>, goalCarName: String):Board {
		var boardStates: List<Board> = new List();
		boardStates.add(initialState);

		var visitedStates = new Array<String>();

		while (boardStates.isEmpty() == false) {
			var board = boardStates.pop();

			if (board.isSolved(goalCarName)) {
				return board;
			}
			
			// skip board states we have already processed
			if(visitedStates.contains(board.state())) {
				continue;
			}
			if (printBoards) {
				trace(board.state());
			}
			visitedStates.insert(0, board.state());
			branch(board, cars).map(boardStates.add);
		}
		return null;
	}

	static function branch(board: Board, cars: Map<String, Car>): List<Board> {
		var carsChecked = new Array<String>();
		var newBoards = new List<Board>();

		for (y in 0...board.boardState.length) {
			for (x in 0...board.boardState[y].length) {
				var carName = board.boardState[y][x];
				if(carName == null || carsChecked.contains(carName)) {
					continue;
				}
				carsChecked.insert(0, carName);
				final carData = cars[carName];
				if(carData == null) {
					continue;
				}
				if (carData.moveDirection == Vertical) {
					if(y - 1 >= 0 && board.boardState[y-1][x] == null) {
						final newBoard = board.clone();
						newBoard.boardState[y-1][x] = carName;
						newBoard.boardState[y-1+carData.size][x] = null;
						newBoard.moveList.add(new Move(carName, "Up"));
						newBoards.add(newBoard);
					}
					if (y + carData.size < board.boardState.length && board.boardState[y + carData.size][x] == null) {
						final newBoard = board.clone();
						newBoard.boardState[y][x] = null;
						newBoard.boardState[y + carData.size][x] = carName;
						newBoard.moveList.add(new Move(carName, "Down"));
						newBoards.add(newBoard);
					}
				} else {
					if (x - 1 >= 0 && board.boardState[y][x - 1] == null) {
						final newBoard = board.clone();
						newBoard.boardState[y][x - 1] = carName;
						newBoard.boardState[y][x - 1 + carData.size] = null;
						newBoard.moveList.add(new Move(carName, "Left"));
						newBoards.add(newBoard);
					}
					if (x + carData.size < board.boardState.length && board.boardState[y][x + carData.size] == null) {
						final newBoard = board.clone();
						newBoard.boardState[y][x] = null;
						newBoard.boardState[y][x + carData.size] = carName;
						newBoard.moveList.add(new Move(carName, "Right"));
						newBoards.add(newBoard);
					}
				}
			}
		}

		return newBoards;
	}

}

class Move {
	public final carName: String;
	public final move: String;
	public var count: Int = 1;

	public function new (carName: String, move: String) {
		this.carName = carName;
		this.move = move;
	}

	public function description(): String {
		return '$carName $move $count';
	}
}

class Board {

	var previousBoard: Board;

	public var boardState: Array<Array<String>>;
	public var moveList: List<Move>;

	public var goal: Coord;

	public function new(goal: Coord) {
		this.previousBoard = null;
		this.moveList = new List<Move>();
		this.goal = goal;
	}

	public function clone(): Board {
		final newBoard:Board = new Board(this.goal);
		newBoard.boardState = this.boardState.map(function (row) return row.copy());
		newBoard.previousBoard = this;
		newBoard.moveList = this.moveList.map(function(x) return x); // psuedo-copy
		return newBoard;
	}

	public function state(): String {
		return this.boardState.map(function (row) return row.join(",")).join(";");
	}

	public function isSolved(carName: String): Bool {
		return boardState[goal.y][goal.x] == carName;
	}

}

class Coord {
	public final x:Int;
	public final y:Int;

	public function new(x: Int, y: Int) {
		this.x = x;
		this.y = y;
	}

	public function setX(x:Int):Coord {
		return new Coord(x, this.y);
	}

	public function setY(y:Int):Coord {
		return new Coord(this.x, y);
	}

	public function add(x:Int, y:Int):Coord {
		return new Coord(this.x + x, this.y + y);
	}

	public function addX(x:Int):Coord {
		return add(x, 0);
	}

	public function addY(y:Int):Coord {
		return add(0, y);
	}

}

enum Direction {
	Vertical;
	Horizontal;
}

class Car {

	public final name: String;
	public final moveDirection: Direction;
	public final size: Int;

	public function new(name:String, moveDirection:Direction, size: Int) {
		this.name = name;
		this.moveDirection = moveDirection;
		this.size = size;
	}

}
