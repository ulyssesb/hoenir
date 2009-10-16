# -*- coding: utf-8 -*-

# Apenas uma interface C para chamar theorem_prover.yap
class YapProlog
  require 'rubygems'
  require 'inline'

  inline do |builder|
    builder.add_compile_flags %q{ -I../YAP4.3.0}
    builder.add_link_flags  %q{ -lYap -lreadline -lm}
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
    @socket = TCPSocket.open(@@hostname, @@port) rescue nil
    @status = @socket.nil?? :disconneted : :connected
  end

  # Transforma a mensagem recebida em um array, ou booleano
  def parser_message(message)
    # Retira o "\n" enviado
    message.gsub! "\n", ""

    case message
    when 'true'
      return true
    when 'false'
      return false
    else
      # eval para transformar a string em um array
      return eval(message.gsub(/(\w+?)/, "'\\1'"))
    end
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
      puts(message)
      @socket.puts(message) 
      
      # Lê uma resposta
      return parser_message @socket.gets
    else 
      return nil
    end
  end

  def close
    @status = :disconnected
    @socket.close unless @socket.nil?
  end
end
