module AVS
  class SpeechSynthesizer
    def self.speak result
      IO.popen('bash -c "mpg321 -"', 'r+') do |io|
        io.puts result
      end #if false 
    end
  end
end
