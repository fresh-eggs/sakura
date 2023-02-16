module Sakura
  class AstQueue
    def initialize
      @index = 0
      @ast_queue = Array.new(10)
    end
    
    def push(ast)
      ast_queue.unshift(ast)
      @index += 1
    end

    def pop
      ast = ast_queue.at(index - 1)
      ast_queue[index - 1] = nil
      @index -= 1 unless @index == 0
      ast
    end

    def print_queue
      puts ast_queue.to_s
    end


    attr_accessor :index
    attr_accessor :ast_queue
  end
end

