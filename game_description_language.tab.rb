#
# DO NOT MODIFY!!!!
# This file is automatically generated by racc 1.4.5
# from racc grammer file "game_description_language.y".
#

require 'racc/parser'



require "#{File.dirname(__FILE__)}/game_description_language.rex"
require "#{File.dirname(__FILE__)}/logic.rb"


class GameDescriptionLanguage < Racc::Parser

module_eval <<'..end game_description_language.y modeval..idd39ee77aac', 'game_description_language.y', 67
def parse( str, debugger )
    @yydebug=debugger
    scan_evaluate( str )
    return do_parse
end

..end game_description_language.y modeval..idd39ee77aac

##### racc 1.4.5 generates ###

racc_reduce_table = [
 0, 0, :racc_error,
 1, 18, :_reduce_1,
 3, 19, :_reduce_2,
 1, 20, :_reduce_3,
 2, 20, :_reduce_4,
 4, 23, :_reduce_5,
 1, 21, :_reduce_6,
 2, 21, :_reduce_7,
 4, 24, :_reduce_8,
 3, 22, :_reduce_9,
 4, 22, :_reduce_10,
 1, 26, :_reduce_11,
 1, 26, :_reduce_12,
 2, 27, :_reduce_13,
 2, 27, :_reduce_14,
 3, 28, :_reduce_15,
 2, 28, :_reduce_16,
 4, 29, :_reduce_17,
 1, 29, :_reduce_18,
 1, 30, :_reduce_19,
 2, 30, :_reduce_20,
 1, 25, :_reduce_21,
 2, 25, :_reduce_22,
 4, 31, :_reduce_23,
 4, 31, :_reduce_24,
 4, 31, :_reduce_25,
 4, 31, :_reduce_26,
 4, 31, :_reduce_27,
 4, 31, :_reduce_28,
 4, 31, :_reduce_29,
 4, 31, :_reduce_30,
 4, 31, :_reduce_31,
 1, 31, :_reduce_32,
 1, 31, :_reduce_33 ]

racc_reduce_n = 34

racc_shift_n = 73

racc_action_table = [
    31,    12,    33,    34,    15,    36,    37,    38,     6,    14,
    57,    30,    32,    31,    35,    33,    34,    58,    36,    37,
    38,    13,    14,    18,    30,    32,    27,    35,    28,    29,
    22,    22,    19,    19,    68,     8,    21,    21,    22,    41,
    19,    67,     7,    22,    21,    19,    66,     6,    22,    21,
    19,    65,     1,    22,    21,    19,    64,   nil,    22,    21,
    19,   nil,   nil,    22,    21,    19,    72,   nil,    22,    21,
    19,   nil,   nil,    22,    21,    19,    39,   nil,    22,    21,
    19,    63,   nil,    22,    21,    19,   nil,   nil,    22,    21,
    19,    69,   nil,    22,    21,    44,    22,   nil,    19,    21,
   nil,    22,    21,    19,    22,   nil,    19,    21,   nil,    22,
    21,    19,    22,   nil,    19,    21,   nil,    22,    21,    19,
    61,   nil,    22,    21,    19,    22,   nil,    19,    21,   nil,
    22,    21,    19,   nil,   nil,    22,    21,    19,    62,   nil,
    22,    21,    19,    22,   nil,    19,    21,   nil,    22,    21,
    19,    22,   nil,    19,    21,   nil,    22,    21,    19,   nil,
   nil,    27,    21,    28,    29 ]

racc_action_check = [
    19,     6,    19,    19,    11,    19,    19,    19,     8,     8,
    41,    19,    19,    44,    19,    44,    44,    44,    44,    44,
    44,     7,    15,    12,    44,    44,    15,    44,    15,    15,
    28,    54,    28,    54,    54,     5,    28,    54,    53,    24,
    53,    53,     3,    52,    53,    52,    52,     1,    51,    52,
    51,    51,     0,    50,    51,    50,    50,   nil,    14,    50,
    14,   nil,   nil,    70,    14,    70,    70,   nil,    58,    70,
    58,   nil,   nil,    20,    58,    20,    20,   nil,    49,    20,
    49,    49,   nil,    27,    49,    27,   nil,   nil,    55,    27,
    55,    55,   nil,    29,    55,    29,    30,   nil,    30,    29,
   nil,    31,    30,    31,    32,   nil,    32,    31,   nil,    33,
    32,    33,    34,   nil,    34,    33,   nil,    47,    34,    47,
    47,   nil,    36,    47,    36,    37,   nil,    37,    36,   nil,
    38,    37,    38,   nil,   nil,    48,    38,    48,    48,   nil,
    42,    48,    42,    43,   nil,    43,    42,   nil,    59,    43,
    59,    45,   nil,    45,    59,   nil,    35,    45,    35,   nil,
   nil,    57,    35,    57,    57 ]

racc_action_pointer = [
    41,    45,   nil,    42,   nil,    24,    -8,    21,     6,   nil,
   nil,    -7,    11,   nil,    49,    19,   nil,   nil,   nil,    -2,
    64,   nil,   nil,   nil,    27,   nil,   nil,    74,    21,    84,
    87,    92,    95,   100,   103,   147,   113,   116,   121,   nil,
   nil,    -1,   131,   134,    11,   142,   nil,   108,   126,    69,
    44,    39,    34,    29,    22,    79,   nil,   154,    59,   139,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
    54,   nil,   nil ]

racc_action_default = [
   -34,   -34,    -3,   -34,    -1,   -34,   -34,   -34,   -34,    -4,
    -6,   -34,   -34,    73,   -34,   -34,    -2,    -7,    -5,   -34,
   -34,   -32,   -33,   -21,   -34,   -11,   -12,   -34,   -34,   -34,
   -34,   -34,   -34,   -34,   -34,   -34,   -34,   -34,   -34,    -8,
   -22,    -9,   -14,   -13,   -34,   -16,   -18,   -34,   -34,   -34,
   -34,   -34,   -34,   -34,   -34,   -34,   -10,   -34,   -34,   -15,
   -19,   -30,   -27,   -25,   -23,   -26,   -24,   -28,   -29,   -31,
   -34,   -20,   -17 ]

racc_goto_table = [
    40,    10,    11,     2,     5,     4,    16,    17,     9,    46,
    45,    59,     3,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,    40,    40,    20,    60,   nil,    40,    40,    40,
    40,    40,    40,    40,    40,    40,    56,    42,    43,    71,
    47,    48,    49,    50,    51,    52,    53,    54,    55,   nil,
    40,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    70 ]

racc_goto_check = [
    14,     7,     4,     6,     3,     2,     5,     7,     6,    14,
    12,    13,     1,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,    14,    14,     8,    14,   nil,    14,    14,    14,
    14,    14,    14,    14,    14,    14,     5,     8,     8,    14,
     8,     8,     8,     8,     8,     8,     8,     8,     8,   nil,
    14,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,     8 ]

racc_goto_pointer = [
   nil,    12,     5,     4,    -3,    -5,     3,    -4,    10,   nil,
   nil,   nil,   -19,   -34,   -20 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    24,
    25,    26,   nil,   nil,    23 ]

racc_token_table = {
 false => 0,
 Object.new => 1,
 :ROLE => 2,
 :INIT => 3,
 :TRUE => 4,
 :DOES => 5,
 :NEXT => 6,
 :LEGAL => 7,
 :GOAL => 8,
 :ATOM => 9,
 :RELATION => 10,
 :OP => 11,
 :CP => 12,
 :DIST => 13,
 :OR => 14,
 :TERMINAL => 15,
 :NOT => 16 }

racc_use_result_var = true

racc_nt_base = 17

Racc_arg = [
 racc_action_table,
 racc_action_check,
 racc_action_default,
 racc_action_pointer,
 racc_goto_table,
 racc_goto_check,
 racc_goto_default,
 racc_goto_pointer,
 racc_nt_base,
 racc_reduce_table,
 racc_token_table,
 racc_shift_n,
 racc_reduce_n,
 racc_use_result_var ]

Racc_token_to_s_table = [
'$end',
'error',
'ROLE',
'INIT',
'TRUE',
'DOES',
'NEXT',
'LEGAL',
'GOAL',
'ATOM',
'RELATION',
'OP',
'CP',
'DIST',
'OR',
'TERMINAL',
'NOT',
'$start',
'target',
'game_desc',
'roles',
'inits',
'rules',
'role',
'init',
'arg_list',
'rules_aux',
'statement',
'relation',
'rel_head',
'rel_body',
'term']

Racc_debug_parser = true

##### racc system variables end #####

 # reduce 0 omitted

module_eval <<'.,.,', 'game_description_language.y', 6
  def _reduce_1( val, _values, result )
 result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 8
  def _reduce_2( val, _values, result )
 result = [val[0], val[1], val[2]].flatten
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 11
  def _reduce_3( val, _values, result )
 result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 12
  def _reduce_4( val, _values, result )
 result = [val[0], val[1]].flatten
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 14
  def _reduce_5( val, _values, result )
 result = Term.new(:role, [Term.new(val[2])])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 17
  def _reduce_6( val, _values, result )
 result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 18
  def _reduce_7( val, _values, result )
 result = [val[0], val[1]].flatten
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 19
  def _reduce_8( val, _values, result )
 result = val[2]
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 22
  def _reduce_9( val, _values, result )
 result = val[1]
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 23
  def _reduce_10( val, _values, result )
 result = [val[1], val[3]].flatten
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 24
  def _reduce_11( val, _values, result )
 result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 25
  def _reduce_12( val, _values, result )
 result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 28
  def _reduce_13( val, _values, result )
 result = Term.new(val[0], val[1])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 29
  def _reduce_14( val, _values, result )
 result = Term.new(val[0], val[1])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 33
  def _reduce_15( val, _values, result )
 result = Predicate.new(val[1].name, val[1].args, val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 35
  def _reduce_16( val, _values, result )
 result = Predicate.new(val[1].name, [], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 36
  def _reduce_17( val, _values, result )
 result = Term.new(val[1], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 37
  def _reduce_18( val, _values, result )
 result = val[0]
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 38
  def _reduce_19( val, _values, result )
 result = [val[0]]
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 39
  def _reduce_20( val, _values, result )
 result = [val[0], val[1]].flatten
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 42
  def _reduce_21( val, _values, result )
 result = [val[0]]
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 43
  def _reduce_22( val, _values, result )
 result = [val[0], val[1]].flatten
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 45
  def _reduce_23( val, _values, result )
 result = Term.new(val[1], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 46
  def _reduce_24( val, _values, result )
 result = Term.new(val[1], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 47
  def _reduce_25( val, _values, result )
 result = Term.new(val[1], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 48
  def _reduce_26( val, _values, result )
 result = Term.new(val[1], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 49
  def _reduce_27( val, _values, result )
 result = Term.new(val[1], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 50
  def _reduce_28( val, _values, result )
 result = Term.new(val[1], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 51
  def _reduce_29( val, _values, result )
 result = Term.new(val[1], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 52
  def _reduce_30( val, _values, result )
 result = Term.new(val[1], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 53
  def _reduce_31( val, _values, result )
 result = Term.new(val[1], val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 54
  def _reduce_32( val, _values, result )
 result = Term.new(val[0], val[1])
   result
  end
.,.,

module_eval <<'.,.,', 'game_description_language.y', 55
  def _reduce_33( val, _values, result )
 result = Term.new(val[0])
   result
  end
.,.,

 def _reduce_none( val, _values, result )
  result
 end

end   # class GameDescriptionLanguage
