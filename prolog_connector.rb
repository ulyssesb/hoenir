# -*- coding: utf-8 -*-

##
## Apenas uma interface C para chamar theorem_prover.yap
##
class YapProlog
  require 'rubygems'
  require 'inline'

  inline do |builder|
    builder.add_compile_flags %q{ -I../YAP4.3.0}
    builder.add_link_flags  %q{ -lYap -lreadline -lm -lgmp -lgmpxx}
    builder.c '''
      #include <stdio.h>
      #include "Yap/YapInterface.h"

      static void start() {
        if (YAP_FastInit(NULL) == YAP_BOOT_ERROR)
            return -1;

        YAP_Term vars[1] = {YAP_MkAtomTerm(YAP_LookupAtom("theorem_prover.yap"))};
        YAP_Functor consult_func = YAP_MkFunctor(YAP_LookupAtom("consult"), 1);
        YAP_Term appl_consult = YAP_MkApplTerm(consult_func, 1, vars);

        if (YAP_RunGoal(appl_consult))
          return 0;
        else
          return -1;
      }
    '''
  end
end


##
## Envia e recebe mensagens do prolog 
##
class PrologConnector
  require 'socket'

  attr_accessor :status
  
  @@hostname = 'localhost'
  @@port = '43210'
  @socket = nil


  private
  def connect
    # Faz um fork (threads nao estavam funcionando) para o prolog
    fork { YapProlog.new.start }

    sleep(1)
    @socket = UNIXSocket.open('/tmp/prolog.sock') rescue nil
    @status = @socket.nil?? :disconneted : :connected
  end

  # Transforma a mensagem recebida em um array, ou booleano
  def parser_message(message)
    return nil if message == ""

    message.gsub! "\n", ""

    case message
    when 'true'
      message = true
    when 'false'
      message = false
    else
      # eval para transformar a string em um array
      message = eval(message.gsub(/(\w+?)/, "'\\1'"))
    end

    return message
  end

  public
  def initialize(host=nil, port=nil)
    @@hostname = host unless host.nil?
    @@port = port unless port.nil?
    connect
  end

  def send(message)
    if @status == :connected

      # Envia a mensagem
#      print "Player::Sending -> "
#      puts(message)

      # Envia a mensagem
      @socket.write(message) 
      @socket.flush

      # Lê uma resposta
      return self.recv
    else 
      return nil
    end
  end

  def recv
#    stime=Time.now
    response = ""
    partial = @socket.readpartial(1024)
    response << partial

    while not partial[-1] == 10
      partial = @socket.readpartial(1024)
      response << partial
    end

#    etime=Time.now
#    print "Player::Delay::"
#    puts (etime-stime)
#    print "Player::Received ->"
#    puts response

    return parser_message(response)
  end

  def close
    @status = :disconnected
    @socket.close unless @socket.nil?
  end

  # Manda fatos
  def assert(facts)
    facts.each { |fact| send("assert(" + fact + ").\n") }
  end

  # Remove-os
  def retract(facts)
    facts.each { |fact| send("retract(" + fact + ").\n") }
  end
end


## 
## Interface para prova de teoremas com o prolog
##
class PrologGGPInterface
  require 'game_description'

  @@prolog  = nil
  @@game_description = nil

  def initialize(prolog, game_description)
    @@prolog = prolog
    @@game_description = game
  end

  private:
  ## Prova alguma coisa em um determinado estado
  def prove(state, query)
    # Envia para o prolog o estado atual
    @@prolog.assert(state)

    values = []
    if query.is_a? String
      values = @@prolog.send(query + ".\n")
    else
      query.each do |term|
        answer = @@prolog.send(term + ".\n")
        values << unify(term, answer)
      end
    end

    # Remove o estado atual
    @@prolog.retract(@statements)

    if values.is_a? Array
      return values.flatten
    else 
      return values
    end
  end

  public:
  ## Encontra as jogadas possíveis no estado atual
  def legals(state)

    moves = []
    unified = prove(@@game_description.legals, state)

    # Retira o "legal()" e poe um "does()"
    unified.each {|new_move| moves << pack(unpack(new_move), "does") }
    
    return moves
  end

  ## Calcula o novo estado, dada a ação realizada
  def next(state, action)
    @@prolog.assert(action)

    new_state = []
    unified = prove(@@game_description.nexts)
    unified.uniq!
    unified.each { |new| new_state << unpack(new)}

    @@prolog.retract(action)

    return new_state
  end

  ## Auto explicativa
  def is_terminal?(state)
    query = "terminal"
    answer = prove(query, state)

    return answer
  end

  ## Calcula a recompensa (o estado deve ser terminal)
  def reward(state)
    query = "goal(Player, Score)"
    scores = prove(query, state)
    
    return false unless scores

    if scores.first.is_a? String
      return [scores.last.to_i]
    else
      slist = []
      scores.each do |score|
        slist << score.scan(/\d+/).first.to_i
      end
      return slist.sort
    end
  end

end
