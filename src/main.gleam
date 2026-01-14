import day01
import gleam/int
import gleam/io
import simplifile

pub fn main() {
  case simplifile.read(from: "inputs/day01.txt") {
    Error(err) -> {
      io.println(
        "Failed to read inputs/day01.txt: " <> simplifile.describe_error(err),
      )
    }

    Ok(contents) -> {
      case day01.parse(contents) {
        Error(parse_err) ->
          io.println("Parse error: " <> day01.describe_parse_error(parse_err))
        Ok(instructions) -> {
          let #(part1, part2) = day01.solve(instructions)
          io.println("Day 01")
          io.println("Part 1: " <> int.to_string(part1))
          io.println("Part 2: " <> int.to_string(part2))
        }
      }
    }
  }
}
