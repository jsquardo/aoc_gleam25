import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub const dial_size: Int = 100

pub const start_position: Int = 50

pub type Direction {
  Left
  Right
}

pub type Instruction {
  Instruction(direction: Direction, steps: Int)
}

pub type ParseError {
  EmptyLine
  InvalidDirection(found: String)
  InvalidSteps(found: String)
}

pub fn parse(input: String) -> Result(List(Instruction), ParseError) {
  input
  |> string.trim
  |> string.split(on: "\n")
  |> list.filter(fn(line) { !string.is_empty(string.trim(line)) })
  |> list.map(parse_line)
  |> result.all
}

pub fn describe_parse_error(err: ParseError) -> String {
  case err {
    EmptyLine -> "Empty line"
    InvalidDirection(found: found) -> "Invalid direction: " <> found
    InvalidSteps(found: found) -> "Invalid steps: " <> found
  }
}

pub fn solve(instructions: List(Instruction)) -> #(Int, Int) {
  let Acc(_, part1, part2) =
    list.fold(
      over: instructions,
      from: Acc(position: start_position, part1: 0, part2: 0),
      with: step,
    )

  #(part1, part2)
}

type Acc {
  Acc(position: Int, part1: Int, part2: Int)
}

fn step(acc: Acc, instruction: Instruction) -> Acc {
  let hits = hits_during(acc.position, instruction)
  let new_position = apply_instruction(acc.position, instruction)

  let new_part1 = case new_position == 0 {
    True -> acc.part1 + 1
    False -> acc.part1
  }

  Acc(position: new_position, part1: new_part1, part2: acc.part2 + hits)
}

fn parse_line(line: String) -> Result(Instruction, ParseError) {
  let line = string.trim(line)

  case string.first(line) {
    Error(_) -> Error(EmptyLine)
    Ok(dir) -> {
      let steps_str =
        line
        |> string.drop_start(up_to: 1)
        |> string.trim

      case int.parse(steps_str) {
        Error(_) -> Error(InvalidSteps(found: steps_str))
        Ok(steps) -> {
          case dir {
            "L" -> Ok(Instruction(direction: Left, steps: steps))
            "R" -> Ok(Instruction(direction: Right, steps: steps))
            _ -> Error(InvalidDirection(found: dir))
          }
        }
      }
    }
  }
}

fn apply_instruction(position: Int, instruction: Instruction) -> Int {
  let Instruction(direction: direction, steps: steps) = instruction

  let delta = case direction {
    Right -> steps
    Left -> -steps
  }

  wrap_dial(position + delta)
}

fn hits_during(position: Int, instruction: Instruction) -> Int {
  let Instruction(direction: direction, steps: steps) = instruction

  case direction {
    Right -> {
      let total = position + steps
      total / dial_size
    }
    Left -> {
      let total = wrap_dial(dial_size - position) + steps
      total / dial_size
    }
  }
}

fn wrap_dial(value: Int) -> Int {
  let r = value % dial_size
  case r < 0 {
    True -> r + dial_size
    False -> r
  }
}
