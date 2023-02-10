require 'syntax_tree'
require 'securerandom'
require 'open3'
require 'byebug'

module Sakura
  class Runner
    def initialize
      @ast_queue = AstQueue.new
      @mutated_ast_queue = AstQueue.new
    end
    
    def read_and_parse_seed_files
      dir = Dir.new("input")
      file = dir.read
      while(!file.nil?)
        if file == '.' || file == '..'
          file = dir.read
          next
        end

        source_string = SyntaxTree.read("./input/#{file}")
        ast = Ast.new(SyntaxTree.parse(source_string), source_string)
        @ast_queue.push(ast)
        file = dir.read
      end
    end

    def generate_mutated_ast
      puts "GENERATE MUTATED AST"
			puts @ast_queue.index
      ast_obj = @ast_queue.pop
			#raise "all done!" unless !ast_obj.nil?
      return unless ast_obj
      random_operator_swap(ast_obj)
			all_operator_swap(ast_obj)
    end
  
    def all_operator_swap(ast_obj)
      operators = [:-, :+, :/, :~, :<<, :>>, :%, :**,
                   :==, :>, :<, :!=, :>=, :<=, :<=>,
                   :===, ":-=".to_sym, "**=".to_sym]
      visitor = SyntaxTree::Visitor::MutationVisitor.new
 			operators.map {|op|
				visitor.mutate("SyntaxTree::Binary") {|node| node.copy(operator: op) }
				@mutated_ast_queue.push(Ast.new(visitor.visit(ast_obj.ast), ast_obj.source))
			}
    end

    def random_operator_swap(ast_obj)
      operators = [:-, :+, :/, :~, :<<, :>>, :%, :**,
                   :==, :>, :<, :!=, :>=, :<=, :<=>,
                   :===, ":-=".to_sym, "**=".to_sym]
      prng = Random.new
      
			formatter = SyntaxTree::Formatter.new(ast_obj.source, [])
      ast_obj.ast.format(formatter)
      formatter.flush
      puts "ORIGINAL: #{formatter.output.join}"
			pp ast_obj.ast
      
			visitor = SyntaxTree::Visitor::MutationVisitor.new
      visitor.mutate("SyntaxTree::Binary") {|node| node.copy(operator: operators[prng.rand(operators.length)]) }
      @mutated_ast_queue.push(Ast.new(visitor.visit(ast_obj.ast), ast_obj.source))
    end

    def run_mutated_sample
      puts "RUN MUTATED SAMPLE"
			puts @mutated_ast_queue.index
      id = SecureRandom.hex(10)
      ast = @mutated_ast_queue.pop
			raise "no more samples :(" unless !ast.nil?

      formatter = SyntaxTree::Formatter.new(ast.source, [])
      ast.ast.format(formatter)
      formatter.flush
      puts "MODIFIED: #{formatter.output.join}"
      File.binwrite("output/sakura_test_case_#{id}.rb", formatter.output.join)
      std_out, status = Open3.capture2("ruby output/sakura_test_case_#{id}.rb")
			puts status      
 
      if status.exitstatus == 0
        @ast_queue.push(ast)
      elsif status.exitstatus == 139
        @ast_queue.push(ast)
        File.binwrite("output/sakura_crash_case#{id}.rb", formatter.output.join)
      end
      # we should save the 10 latest like a ring buffer
      # this could provide a cool window into the format
      # of the samples your mutators is generating.
      std_out, status = Open3.capture2("rm -f output/sakura_test_case_#{id}.rb")
    end

    def compile_ast_to_yarv(ast=nil)
      raise StandardError unless ast
    end
  end
end
