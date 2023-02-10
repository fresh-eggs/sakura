require_relative 'runner'
require_relative 'ast_queue'
require_relative 'ast'

runner = Sakura::Runner.new
runner.read_and_parse_seed_files

while(1)
  runner.generate_mutated_ast
  runner.run_mutated_sample
end

