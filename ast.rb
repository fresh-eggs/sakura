module Sakura
  class Ast
    attr_accessor :ast
    attr_accessor :source

    def initialize(ast, source)
      @ast = ast
      @source = source
    end
  end
end

