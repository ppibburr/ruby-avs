module AVS
  class SpeechSynthesizer
    def speak directive, content
      AVS::Util.log :SPEAK, "#{self}"
    
      data = content[id=directive['payload']['audioContent'].gsub('cid:', '')]
      
      _perform_speak data
    end

    private    
    def _perform_speak data
    
    end
  end
end
