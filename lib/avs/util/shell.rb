require 'json'

module AVS
  module Util
    def self.shell cmd, json: false, verbose: false, err: nil, echo: true
      cmd += (err ? err : ' 2>/dev/null')
      
      log :SHELL, cmd, echo
      
      r = nil
      
      IO.popen(cmd, "rb+") do |io|
        io.close_write
        r = io.read
      end
      
      log :RESULT, r, verbose
      
      json ? JSON.parse(r) : r
    end
    
    def self.pipe cmd, &b
      log :SHELL, cmd
      
      IO.popen(cmd, "rb+") do |io|
        b.call io
        io.close_write
      end
    end
    
    def self.log realm, str, bool=true
      str.split("\n").each do |l|
        puts "#{"[Util.log (#{realm}:)]".ljust(25)} #{l}"
      end if bool
    end
  end
end
