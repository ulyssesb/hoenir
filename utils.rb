# -*- coding: utf-8 -*-
## Coisas uteis

# Unifica um termo com o vetor de variárives
# Ex: foo(X, Y, bar), [[1,2], [3,4]]
#  -> [foo(1, 2, bar), foo(3, 4, bar)]
def unify(term, assigns)
  unified = []

  return [] unless assigns.is_a? Array

  assigns.each do |values|
    assigned = term.dup
    values.each_with_index do |value, index|
      # Substitui o parametro "PARAM$" pelo valor
      assigned.gsub!(/PARAM#{index}/, value)
    end
    unified << assigned
  end
  return unified.flatten
end

# Remove a chamada mais externa
# Ex: legal(Foo(bar)) -> Foo(bar)
def unpack(term)
  # Remove o tudo até o primeiro '('
  term.gsub!(/^[^(]*\(/, "")
  
  # Remove o ultimo ')'
  term.chop!
end

# Insere uma chamada mais externa
def pack(term, call)
  call + "(" + term + ")"
end
